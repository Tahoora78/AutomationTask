
# Variables file implemented terraform workspaces using maps

variable "workspace_to_environment_map" {
  type = map
  default = {
    sbx = ""
    dev = "dev"
    qa  = "qa"
    prd = "prd"
  }
}

#SFTP bucket name for each environment. 
variable "sftp_bucket_name_map" {
  description = "A map from environment to a list of key pairs"
  type        = map
  default = {
    sbx = ""
    dev = "source-s3-bucket-sftp"
    qa  = ""
    prd = ""
  }
}

#SFTP bucket prefix ( folder ) for each environment for one user
variable "sftp_user_map" {
  description = "A map from environment to a list of key pairs"
  type        = map
  default = {
    sbx = ""
    dev = "sftp-testuser-dev"
    qa  = ""
    prd = ""
  }
}


#learn work terraform workspaces here - https://www.terraform.io/docs/state/workspaces.html
# command to initilize environment specific workspace ( dev, qa, prd)
# each env will have a separate backend file
# terraform init -backend-config=backends/dev-env.tf
# then init follow the below commands
# terraform workspace new "dev"
# terraform plan
# terraform apply
locals {
  workspace_env = "${lookup(var.workspace_to_environment_map, terraform.workspace, "dev")}"
  #convert to uppercase 
  environment      = "${upper(local.workspace_env)}"
  sftp_bucket_name = "${var.sftp_bucket_name_map[local.workspace_env]}"
  sftp_user        = "${var.sftp_user_map[local.workspace_env]}"

}


variable "owner_name" {
  default = "tahooramajlesi@gmail.com"
}