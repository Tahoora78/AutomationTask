import boto3
import datetime
import click


client = boto3.client('transfer')


@click.command()
@click.option('--user','-u',prompt="user name",help="name of the user to delete")
def delete_user(user):
    client.delete_user(UserName=user)