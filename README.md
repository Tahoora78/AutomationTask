# Automation Book Keeping
This is an automation program that simplifies bookkeeping by uploading monthly invoices through the SFTP protocol.
<br>
So we have 2 S3 buckets. The source-s3-bucket is where every employee has a folder there and has only access to this folder.
After processing the file, if the file is in YYYYMM.pdf format it will be automatically copied to destination-s3-block to the folder specific to that employee. Otherwise, the system will send an alert in Slack.
<br>
- Each employee has their own SFTP user.
- Source and destination buckets are the same for all users(We only have 2 buckets in total)

<br>
All of this project is written with terraform. So to run this you can:
<br>
`terraform init`
<br>
`terraform apply`
<br>
And to create a new user you can run aws_sftp_user.py
<br>
To create a new admin user you can run aws_sftp_admin.py
<br>
To delete a user you can run delete_aws_sftp_user.py
<br>
To delete a user folder you can run delete_aws_sftp_folder.py
<br>

---
There are 3 documents in <a href="https://github.com/Tahoora78/AutomationTask/tree/main/Documents">document folder</a>.
