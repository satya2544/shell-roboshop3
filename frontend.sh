#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p "$LOGS_FOLDER"

echo "Script started executed at: $(date)" | tee -a "$LOG_FILE"

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privilege"
    exit 1
fi

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R is Failure $N" | tee -a "$LOG_FILE"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a "$LOG_FILE"
    fi
}

dnf module disable nginx -y &>>"$LOG_FILE"
VALIDATE $? "Disabling Nginx"

dnf module enable nginx:1.24 -y &>>"$LOG_FILE"
VALIDATE $? "Enabling Nginx 1.24"

dnf install nginx -y &>>"$LOG_FILE"
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>"$LOG_FILE"
VALIDATE $? "Enabling Nginx"

rm -rf /usr/share/nginx/html/*

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>"$LOG_FILE"
VALIDATE $? "Downloading frontend"

cd /usr/share/nginx/html
VALIDATE $? "Changing to frontend directory"

unzip -o /tmp/frontend.zip &>>"$LOG_FILE"
VALIDATE $? "Extracting frontend"

cp "$SCRIPT_DIR/nginx.conf" /etc/nginx/nginx.conf
VALIDATE $? "Copying Nginx configuration"

nginx -t &>>"$LOG_FILE"
VALIDATE $? "Testing Nginx configuration"

systemctl restart nginx &>>"$LOG_FILE"
VALIDATE $? "Restarting Nginx"