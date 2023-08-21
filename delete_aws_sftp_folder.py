import boto3
import click


@click.command()
@click.option('--user','-u',prompt="user name",help="name of the username to delete its folder")
def delete_folder(user):
    # Create an S3 client
    s3 = boto3.client('s3')
    objects = s3.list_objects(Bucket='source-s3-bucket-sftp', Prefix=user+'/')
    # Delete all objects in the folder
    for object in objects['Contents']:
        s3.delete_object(Bucket='source-s3-bucket-sftp', Key=object['Key'])

    # Delete the folder
    s3.delete_object(Bucket='source-s3-bucket-sftp', Key=user+'/')