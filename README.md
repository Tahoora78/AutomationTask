# AutomationTask
<br>
# user-guide
<br>
You can use any sftp client. Then you can login to the server with the parameter that admin has given to you. These parameters are:
host, username and ssh-key

<br>
# admin guide
<br>
- Create a server
<br>
You can create a server with the command:
terraform init
terraform apply --auto-aprove
<br>
- create a new user
<br>
You can create new user by running aws_sftp_user.py. You can run this script and then type the username that you want.
This script will give you the ssh-key, ssh-key.pub .
You should give username, ssh-key and also the server endpoint to any user that you want.
<br>
You can find the server-endpoint from the SFTP server page. Just click on the server which the server Id is the one that you got when create a new user.
<br>
- delete a user
You can delete a user by running delete_aws_sftp_user.py.
Just enter the username of the user.
<br>
- delete a folder
you can also delete the folder which the user has accesed by running delete_aws_sftp_folder.py.
like the previous part just type the username.
<br>
# Developer guide
<br>
We have Provider.tf file, you should type down youe access_key and secret_key there.
<br>
In the main.tf file we build the sftp server, lambda function and the iam roles and policy which is needed. 
<br>
All of the sftp server, s3 buckets, iam roles and policies are created with this file.
<br>
We only use 2 s3 bucket. Which are source_s3_bucket and destination_s3_bucket. When admin creates a new user by running aws_sftp_user.py a folder with username name would be created. 
So the new user can only access this folder from the source_s3_bucket.
<br>
If the file that the user has uploaded is in YYYYMM.pdf format, it will be copied to the destination_s3_bucket. And if it didn't an alert would be send to the slack chanel. These to action is handled by the lambda function which is lambda/index.py 
<br>
We have delete_aws_sftp_folder.py to delete the user folder from source_s3_bucket.
<br>
We also have delete_aws_sftp_user.py to delete user.