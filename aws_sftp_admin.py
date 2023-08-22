import boto3
import click
import subprocess
import time


client = boto3.client('transfer')
s3 = boto3.client('s3')
# since we have only one server in ap-southeast-1 , change this accordingly
serverId=client.list_servers().get('Servers')[0].get('ServerId')
# serverEndPoint = "s-efec2545294c4e4aa.server.transfer.eu-west-1.amazonaws.com"
bucket_name = "destination-s3-bucket-sftp"

@click.command()
@click.option('--user','-u',prompt="user name",help="name of the user to create as sftp user")
def create_user(user):
    keygen_command = "ssh-keygen -t rsa -f my_ssh_key"
    subprocess.run(keygen_command, shell=True, check=True)

    # Read and print the private key
    private_key_filename = "my_ssh_key"
    with open(private_key_filename, "r") as private_key_file:
        private_key = private_key_file.read()
        print("Private Key:")
        print(private_key)

    # Read and print the public key
    public_key_filename = f"{private_key_filename}.pub"
    with open(public_key_filename, "r") as public_key_file:
        public_key_data = public_key_file.read()
        print("\nPublic Key:")
        print(public_key_data)


    scope_down_policy='''{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "s3:ListBucket",
                    "s3:GetBucketLocation"
                ],
                "Resource": [
                    "arn:aws:s3:::destination-s3-bucket"
                ],
                "Effect": "Allow",
                "Sid": "ReadWriteS3"
            },
            {
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
                    "arn:aws:s3:::destination-s3-bucket-sftp/*"
                ],
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }'''
    tags=[
        {
            'Key': 'user',
            'Value': f'{user}'
        },
        ]
    home_dir= f'/destination-s3-bucket-sftp/*'

    client.create_user(
        HomeDirectory=home_dir,
        Policy=scope_down_policy,
        Role='arn:aws:iam::212435474521:role/tf-test-transfer-server-iam-role-dev',
        ServerId=serverId,
        SshPublicKeyBody=f'{public_key_data}',
        Tags=tags,
        UserName=f'{user}'
    )
   
    s3.put_object(Bucket=bucket_name, Key=f'{user}/')

    

if __name__ == '__main__':
    create_user()