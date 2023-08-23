- Provider.tf
<br>
We have Provider.tf file, you should type down your access_key and secret_key there.

- main.tf
<br>
In the main.tf file we build the sftp server, lambda function and the iam roles and policy which is needed. 
<br>
All of the sftp server, s3 buckets, iam roles and policies are created with this file.
<br>
We exclusively employ two S3 buckets: "source_s3_bucket" and "destination_s3_bucket." When an administrator creates a new user through the "aws_sftp_user.py" script, a folder bearing the username is automatically generated. Consequently, the new user is limited to accessing only this folder within the "source_s3_bucket."

- lambda/index.py
<br>
Files uploaded by the user in the "YYYYMM.pdf" format will be transferred to the "destination_s3_bucket." In the event that the file does not adhere to this format, an alert will be dispatched to the designated Slack channel. These actions are managed by the Lambda function located at "lambda/index.py."

- aws_sftp_user.py
<br>
This file serves to accomplish several key tasks:

1. SFTP User Creation: It facilitates the creation of an SFTP user for the designated SFTP server.

2. User-Specific Folder: Upon user creation, a folder bearing the same name as the username is automatically generated. This ensures that each user can only access their designated folder.

3. SSH Key Generation: The script also generates an SSH key file, which enables the user to securely access their files through an SFTP client software.

4. Host URL Retrieval: To find the host URL, simply visit the SFTP server and locate the server endpoint, allowing for easy connection and access.

<br>
- delete_aws_sftp_folder.py
<br>
We have delete_aws_sftp_folder.py to delete the user folder from source_s3_bucket.

- delete_aws_sftp_user.py
<br>
We also have delete_aws_sftp_user.py to delete user.

- aws_sftp_admin.py
you can create admin user with it