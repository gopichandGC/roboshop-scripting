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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disabling the default version of mysql"

cp myql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "Copying the mysql repo file"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "Installing mysql:5.7 Version"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling  mysql"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? " Setting mysql root password"

