#!/bin/bash

# Variables
IMAGE_NAME="flask-appp"
CONTAINER_NAME="flask-container"

echo "============================"
echo " Docker and Bash Automation "
echo "============================"

echo "1. Build Docker Image"
echo "2. Run Docker Container"
echo "3. Stop Docker Container"
echo "4. Remove Docker Container"
echo "5. Clean Up Docker Images"
echo "6. Exit" requirements.txt 
echo "============================"
read -p "Choose an option [1-6]: " OPTION

case $OPTION in
    1)
        echo "Building Docker Image..."
        docker build -t $IMAGE_NAME .
        ;;
    2)
        echo "Running Docker Container..."
        docker run -d -it  --name $CONTAINER_NAME -p 5000:5000 $IMAGE_NAME
        ;;
    3)
        echo "Stopping Docker Container..."
        docker stop $CONTAINER_NAME
        ;;
    4)
        echo "Removing Docker Container..."
        docker rm $CONTAINER_NAME
        ;;
    5)
        echo "Cleaning up Docker Images..."
        docker image prune -a -f
        ;;
    6)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option. Please try again."
        ;;
esac