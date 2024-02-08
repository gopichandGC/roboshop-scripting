#!/bin/bash

AMI=ami-0f3c7d07486cad139
SG_ID=sg-0523f705109b77eaa
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")
ZONE_ID=Z01392352BS5MX7GMAHS1
DOMAIN_NAME=

for i in "${INSTANCES[@]}"
do
    if [ $i == "mongodb"] || [ $i == "mysql"] || [ $i == "shipping"]
    then
         INSTANCE_TYPE="t3.small"
    else
         INSTANCE_TYPE="t2.micro"
    fi
    
    IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications "ResourceType=instance, Tags=[{Key=Name,Value=$i}]" --query 'Instance[0].PrivateIpAddress' --output text)

    echo "$i: $IP_ADDRESS"

done