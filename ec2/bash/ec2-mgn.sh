#!/bin/bash

# Set the default region
REGION="eu-north-1"

# Function to create a new EC2 instance
create_instance() {
    echo "Choose the type of EC2 instance you want to create:"
    echo "1) t3.micro"
    echo "2) t2.small"
    echo "3) t2.medium"
    read -p "Enter choice [1-3]: " INSTANCE_TYPE_CHOICE

    case $INSTANCE_TYPE_CHOICE in
        1) INSTANCE_TYPE="t3.micro" ;;
        2) INSTANCE_TYPE="t2.small" ;;
        3) INSTANCE_TYPE="t2.medium" ;;
        *) echo "Invalid choice. Defaulting to t2.micro"; INSTANCE_TYPE="t3.micro" ;;
    esac
4

    echo "Choose the AMI for the instance:"
    echo "1) Ubuntu 24.04 (ami-04cdc91e49cb06165)"
    echo "2) Amazon Linux 2023 (ami-0129bfde49ddb0ed6)"
    read -p "Enter choice [1-2]: " AMI_CHOICE

    case $AMI_CHOICE in
        1) AMI_ID="ami-04cdc91e49cb06165" ;;  # Ubuntu 24.04 for eu-north-1
        2) AMI_ID="ami-0129bfde49ddb0ed6" ;;  # Amazon Linux 2023 for eu-north-1
        *) echo "Invalid choice. Defaulting to Ubuntu 24.04"; AMI_ID="ami-04cdc91e49cb06165" ;;
    esac

    read -p "Enter a key pair name (make sure it exists): " KEY_NAME

    echo "Launching EC2 instance..."
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --count 1 \
        --instance-type $INSTANCE_TYPE \
        --key-name $KEY_NAME \
        --region $REGION \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=my-ec2-instance}]" \
        --query "Instances[0].InstanceId" --output text)

    echo "EC2 instance created with ID: $INSTANCE_ID"
}

# Function to show all EC2 instances with details
show_instances() {
    echo "Fetching list of EC2 instances..."
    aws ec2 describe-instances --region $REGION --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,State:State.Name,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress}" --output table
}

# Function to delete an EC2 instance
delete_instance() {
    show_instances

    read -p "Enter the Instance ID of the EC2 instance you want to terminate: " INSTANCE_ID
    echo "Terminating EC2 instance $INSTANCE_ID..."

    aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION
    echo "Instance $INSTANCE_ID terminated."
}

# Main menu function
main_menu() {
    echo "---------------------------"
    echo " AWS EC2 Management Script"
    echo "---------------------------"
    echo "1) Create a new EC2 instance"
    echo "2) Show all EC2 instances"
    echo "3) Delete an EC2 instance"
    echo "4) Exit"
    echo "---------------------------"
    read -p "Enter your choice [1-4]: " CHOICE

    case $CHOICE in
        1) create_instance ;;
        2) show_instances ;;
        3) delete_instance ;;
        4) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice, please select between 1-4." ;;
    esac
}

# Main loop
while true; do
    main_menu
done
