#!/bin/bash

echo "starting script: $1"

if [ ! -z "$1" ]
then
    case $1 in
    help)
        # Help
        echo "You have so many opportunities!!!"
        echo "- create-image {instance_id} {image_target_name}"
        ;;
    create-image)
        # Create Image
        echo "creating image..."
        if [ ! -z "$2" ] && [ ! -z "$3" ]
        then
            aws ec2 create-image --instance-id $2 --name $3 --reboot
        else
            echo "please define the instance-id and the name of the image"
        fi
        ;;
    create-instance)
        # Create Instance
        echo "creating instance"
        ;;
    *)
        echo "Wrong argument"
        ;;
    esac
else
    echo "please define the mode of the script"
fi