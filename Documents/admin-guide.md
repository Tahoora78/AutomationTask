As an admin you can do these works:

- Create a server
<br>
You can create a server with the command:
`terraform init`
`terraform apply --auto-aprove`

- create a new user
<br>
To create a new user, utilize the [aws_sftp_user.py](https://github.com/Tahoora78/AutomationTask/blob/main/aws_sftp_user.py)  script. Simply execute the script and input the desired username. This script will provide you with both the SSH key and its public counterpart.
<br>
When assigning access to a user, ensure you provide them with the username, SSH key, as well as the server endpoint.
<br>
You can locate the server endpoint on the SFTP server page. Simply click on the server with the server ID that corresponds to the one you received when creating a new user.

- delete a user
<br>
You can remove a user by executing the "delete_aws_sftp_user.py" script. Simply provide the username of the user you wish to delete.

- delete a folder
<br>
You can also delete the folder that the user has accessed by executing the "delete_aws_sftp_folder.py" script. Similar to the previous step, you only need to input the username.

- Create an admin user
<br>
you can create an admin user by running aws_sftp_admin.py

