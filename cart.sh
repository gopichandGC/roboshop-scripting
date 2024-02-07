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

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "downloading cart application"

cd /app

unzip /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "Unzipping the application"

npm install

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-scripting/cart.service /etc/systemd/system/cart.service

VALIDATE $? "Copying cart service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "cart deamon reload"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "Enabling cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "Starting cart"