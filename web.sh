#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script Started Executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
         echo -e "$2 ... $R FAILED $N"
         exit 1
    else
         echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $? -ne 0 ]
then
     echo -e "$R ERROR :: Please run this script  with root access $N"
     exit 1
else
     echo -e " You are root user"
fi

dnf install nginx -y &>> $LOGFILE

VALIDATE $? "Installing Nginx"

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "Enabling Nginx"

systemctl start nginx &>> $LOGFILE

VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* 

VALIDATE $? "Removing default html page"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
 
VALIDATE $? "Downloading the application"

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "moving nginx html directory"

unzip /tmp/web.zip &>> $LOGFILE

VALIDATE $? "Unzipping the application"

cp /home/centos/roboshop-scripting/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "Restarting nginx"
