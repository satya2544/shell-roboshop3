dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enabling Nginx"

rm -rf /usr/share/nginx/html/*
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend"

cd /usr/share/nginx/html
unzip -o /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extracting frontend"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying Nginx configuration"

nginx -t &>>$LOG_FILE
VALIDATE $? "Testing Nginx configuration"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting Nginx"