# Automated Backup Script with AWS S3 

## Features 
-    Compresses and backs up specified directories.
-    Automatically uploads backup files to an Amazon S3 bucket.
-    Configurable via environment variables and script parameters.
-    Automates backup scheduling using cron.
## Prerequisites
- AWS CLI installed on the system.
    - Installation steps are provided in the script documentation.
- IAM Role or User with appropriate permissions:
   - AmazonS3FullAccess
   - AmazonSSMFullAccess (if managing EC2 instances)
- Cron for scheduling backups.

### Setup Instructions
- 1. Clone or Create the Script
Save the following script as backup-script.sh in your desired directory:
```bash
#!/bin/bash
# Created by Khaled Hawil

# -----------------------
# Variables Initialization
# -----------------------
# Define variables for time, backup file, destination, log file, and S3 bucket.

time=$(date +%m-%d-%y_%H_%M_%S)
backup_file=/home/ubuntu/bash
dest=/home/ubuntu/backup
filename=file-backup-$time.tar.gz
LOG_FILE="/home/ubuntu/backup/logfile.log"
s3_Bucket="s3-bash-hawil"
file_TO_upload="$dest/$filename" 

### Check if user enter  the path file to backup 
#
#if [ -z "$backup_file" ]; then
#       echo " Please enter the directory that U want to backup at ---> $(date)" | tee  -a "$LOG_FILE"
#       exit 2
#fi


# ------------------------------------------
# Check for AWS CLI installation
# ------------------------------------------
# Ensure that AWS CLI is installed. If not, print a message and exit with status 2.
if ! command -v aws &> /dev/null
then
        echo "AWS CLI ir not installed. Please install it first"
        exit 2
fi

# ------------------------------------------
# Backup the specified directory
# ------------------------------------------
# Check if the backup file already exists. If it doesn’t, create a compressed one.

if [ $? -ne 2 ]; then
 if [ -f $filename ]; then
        echo "Error file $filename already exists!" | tee -a  "$LOG_FILE"
 else
        tar -czvf "$dest/$filename"  "$backup_file"
        echo "backup completed successfully .  BackUp file: $dest/$filename " | tee -a "$LOG_FILE" 
        echo
        aws s3 cp "$file_TO_upload" "s3://$s3_Bucket/"
 fi
fi 

# ------------------------------------------
# Verify the upload to S3
# ------------------------------------------
# Check the exit status of the `aws s3 cp` command. If successful, print a success message.

if [ $? -eq 0 ] ; then
        echo
        echo "File Uploaded successfully to the S2 bucket : $s3_Bucket"
else
        echo "File upload tp s3 failed"
fi
echo "This Script provided by eng-$eng"
```
### 2. Install AWS CLI
Run the following commands to install AWS CLI:
```bash
sudo apt install unzip \
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
unzip awscliv2.zip \
sudo ./aws/install
```
### 3. Configure AWS CLI
Set up your AWS credentials:
```bash
aws configure 
```
 Provide your AWS Access Key ID, Secret Access Key, and default region.
### 4. Create an S3 Bucket
Run the following command to create an S3 bucket:
```bash
aws s3api create-bucket --bucket <bucket-name> --region <region>
```
Replace <bucket-name> and <region> with your desired bucket name and region.

### 5. Schedule Backups
Use cron to automate the backup process. For example, to run the script every 2 minutes:
  ```bash
sudo vim /etc/crontab
```
Add the following line:
  ```bash 
*/2 * * * * root /home/ubuntu/backup-script.sh
``` 
### 6. Clean Up
To delete the S3 bucket and its contents:
```bash
aws s3 rb s3://<bucket-name> --force
```

## Logs
The script logs all operations to 
```bash
cat /home/ubuntu/backup/logfile.log 
```
for easy debugging and monitoring.
# Before use this script
* This script is provided as-is. Ensure proper testing in your environment before using it in production.

