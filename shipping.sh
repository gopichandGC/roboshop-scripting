#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"
MYSQL_HOST=mysql.techwithgopi.online

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

dnf install maven -y &>> $LOGFILE
 
VALIDATE $? "Installing maven"

id roboshop
if [ $? -ne 0 ]
then
     useradd roboshop
     VALIDATE $? "roboshop user creation"
else
     echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app

VALIDATE $? "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading shipping"

cd /app

VALIDATE $? "Moving to app directory"

unzip /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? " Unzipping shipping"

mvn clean package &>> $LOGFILE

VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "Renaming Jar File"

cp /home/centos/roboshop-scripting/shipping.service  /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "Copying shipping service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "deamon reload"

systemctl enable shipping  &>> $LOGFILE

VALIDATE $? "enabling shipping"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "Starting shipping"

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "Installing mysql client"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOGFILE

VALIDATE $? "Loading shipping data"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "restarting shipping"