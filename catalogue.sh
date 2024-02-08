#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST="mongodb.techwithgopi.online"

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

if [ $ID -ne 0 ]
then
     echo -e "$R ERROR:: Please run this script with root access $N"
     exit 1
else
   echo "You are root user"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling the current Nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling Nodejs"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing the Nodejs:18"

id roboshop
if [ $? -ne 0 ]
then
     useradd roboshop
     VALIDATE $? "roboshop user creation"
else
     echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app

VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading catalogue application"

cd /app

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Unzipping the application"

npm install

VALIDATE $? "Installing dependencies"
#Use absolute path, because catalogue.service exist if you follow this path
cp /home/centos/roboshop-scripting/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue deamon reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting catalogue"

cp /home/centos/roboshop-scripting/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongodb client"

mongo --host "${MONGODB_HOST}" </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalogue data into mongodb"