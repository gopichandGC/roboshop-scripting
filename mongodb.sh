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

if [ $ID -ne 0 ]
then
     echo -e "$R ERROR:: Please run this script with root access $N"
     exit 1
else
   echo "You are root user"
fi

cp mongo.repo /etc/yum.repos.d/mango.repo &>> $LOGFILE

VALIDATE $? "Copied Mongodb Repo"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? " Installing Mongodb"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? " Enabling Mongodb"

systemctl start mongod &>> $LOGFILE

VALIDATE $? " Starting Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Remote Access to Mongodb"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? " Restarting Mongodb"