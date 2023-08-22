resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt s3 bucket objects"
  deletion_window_in_days = 10
  tags = {
    name        = "sftp-s3-key"
    environment = local.environment
    owner       = var.owner_name
  }
}


resource "aws_s3_bucket" "source_bucket" {
  bucket = "source-s3-bucket-sftp"
  tags = {
    name        = "source-s3-bucket-sftp"
    environment = local.environment
    owner       = "tahooramajlesi@gmail.com",
    dataType    = "SFTP files"
  }
}


resource "aws_s3_bucket" "destination_bucket" {
    bucket = "destination-s3-bucket-sftp"
    tags = {
    name        = "destination-s3-bucket-sftp"
    environment = local.environment
    owner       = "tahooramajlesi@gmail.com",
    dataType    = "SFTP files"
  }
}


resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.source_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_iam_role" "sftp_role" {
  name = "tf-test-transfer-server-iam-role-${local.workspace_env}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

#Set SFTP user permissions.
resource "aws_iam_role_policy" "sftp_policy" {
  name = "tf-test-transfer-server-iam-policy-${local.workspace_env}"
  role = aws_iam_role.sftp_role.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "AllowFullAccesstoCloudWatchLogs",
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "*"
        },
        {
			    "Effect": "Allow",
          "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ],
         "Resource": [
            "arn:aws:s3:::${local.sftp_bucket_name}"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:DeleteObjectVersion",
            "s3:GetObjectVersion",
            "s3:GetObjectACL",
            "s3:PutObjectACL"
          ],
          "Resource": [
            "arn:aws:s3:::${local.sftp_bucket_name}/*"
        ]
      }
    ]
}
POLICY
}


resource "aws_transfer_server" "sftp_server" {
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.sftp_role.arn

  tags = {
    name        = "tf-acc-test-transfer-server-${local.workspace_env}"
    environment = local.environment
    owner       = var.owner_name
  }
}


variable "aws_region" {
    default = "eu-west-1"
    description = "AWS Region to deploy to"
}

variable "env_name" {
    default = "s3-to-s3-copy"
    description = "Terraform environment name"
}

data "archive_file" "my_lambda_function" {
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda.zip"
  type        = "zip"
}


resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.env_name}_lambda_policy"
  description = "${var.env_name}_lambda_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:CopyObject",
        "s3:HeadObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::source-s3-bucket-sftp",
        "arn:aws:s3:::source-s3-bucket-sftp/*"
      ]
    },
    {
      "Action": [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:CopyObject",
        "s3:HeadObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::destination-s3-bucket-sftp",
        "arn:aws:s3:::destination-s3-bucket-sftp/*"
      ]
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "s3_copy_function" {
    name = "app_${var.env_name}_lambda"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "terraform_lambda_iam_policy_basic_execution" {
  role = "${aws_iam_role.s3_copy_function.id}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

resource "aws_lambda_permission" "allow_terraform_bucket" {
    statement_id = "AllowExecutionFromS3Bucket"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.s3_copy_function.arn}"
    principal = "s3.amazonaws.com"
    source_arn = "${aws_s3_bucket.source_bucket.arn}"
}

resource "aws_lambda_function" "s3_copy_function" {
    filename = "lambda.zip"
    source_code_hash = data.archive_file.my_lambda_function.output_base64sha256
    function_name = "${var.env_name}_s3_copy_lambda"
    role = "${aws_iam_role.s3_copy_function.arn}"
    handler = "index.handler"
    runtime = "python3.9"

    environment {
        variables = {
            DST_BUCKET = "destination-s3-bucket-sftp",
            REGION = "${var.aws_region}"
        }
    }
}


resource "aws_s3_bucket_notification" "bucket_terraform_notification" {
    bucket = "${aws_s3_bucket.source_bucket.id}"
    lambda_function {
        lambda_function_arn = "${aws_lambda_function.s3_copy_function.arn}"
        events = ["s3:ObjectCreated:*"]
    }

    depends_on = [ aws_lambda_permission.allow_terraform_bucket ]
}

