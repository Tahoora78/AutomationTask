# AutomationTask
This is an automation program which simplify bookkeeping of uploading mounthly invoices thrrough SFTP protocol.
<br>
So we have 2 s3 bucket. The source-s3-bucket is where every employee has a folder there and has only the access to this folder.
After processing the file, if the file is in YYYYMM.pdf format it will be automatically copied to destination-s3-block to the folder specific to that employee. Otherwise, the system will send an alert in slack.
<br>
- Each employee has their own SFTP user.
- Source and destination buckets are the same for all users(We only have 2 buckets in total)

<br>
All of this project is written with terraform. So to run this you can:
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
