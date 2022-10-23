#!/bin/bash

function create-image {
        if [ ! -z "$1" ] && [ ! -z "$2" ]
        then
            aws ec2 create-image --instance-id $1 --name $2 --reboot
        else
            echo "please define the instance-id and the name of the image"
        fi
}

function start-instance {
        # Start instance
        echo "start instance..."
        if [ ! -z "$1" ]
        then
            aws ec2 start-instances --instance-ids $1
            aws ec2 wait instance-running --instance-ids $1
        else
            echo "please define the instance-id to start this instance"
        fi 
}

function stop-instance {
        echo "stop instance...FIXME"
}


function run-instance-frontend {
        #create instance into the correct sec-group 
        new_instanceid=$(run-instance $1 $2 sg-0b50ec9c7e17ff370)
        echo $new_instanceid
        #waiting for running
        aws ec2 wait instance-running --instance-ids $new_instanceid
        #add new instance to load-balancer target group
        add-to-lb-targetgroup \
        arn:aws:elasticloadbalancing:eu-central-1:150625325991:targetgroup/cad-team3-tg-frontend-ssl/46c2db42e010cdfd \
        $new_instanceid
}

function run-instance-backend {
        #create instance into the correct sec-group 
        new_instanceid=$(run-instance $1 $2 sg-09f8cbb6d85ecbb61)
        #waiting for running
        aws ec2 wait instance-running --instance-ids $new_instanceid
        #add new instance to load-balancer target group
        add-to-lb-targetgroup \
        arn:aws:elasticloadbalancing:eu-central-1:150625325991:targetgroup/cad-team3-tg-backend-ssl/89b62b6fe0b69c98 \
        $new_instanceid 
}


function run-instance {
        # Start instance
        if [ ! -z "$1" ] && [ ! -z "$2" ] && [ ! -z "$3" ]
        then
            # create instance from image and parse return json for newid 
            new_instanceid=$(aws ec2 run-instances \
            --image-id $1 \
            --instance-type t2.micro \
            --key-name cad_team3_ \
            --security-group-ids "$3" \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$2}]" \
            --query "Instances[*].[InstanceId]" \
            --output text)

            # return the new instanceid
            echo $new_instanceid
        else
            echo "please define the image-id and instance name to run a instance from ami"
        fi 
}

function add-to-lb-targetgroup {
        # Start instance
        echo "run instance..."
        if [ ! -z "$1" ] && [ ! -z "$2" ]
        then
           aws elbv2 register-targets \
           --target-group-arn $1 \
           --targets Id=$2,Port=443
           #wait until is healthy
           aws elbv2 wait target-in-service \
           --target-group-arn $1 \
           --targets Id=$2,Port=443
        else
            echo "please define the image-id and instance name to run a instance from ami"
        fi 
}

function delete-instance {
    aws ec2 terminate-instances --instance-ids $1
    aws ec2 wait instance-terminated --instance-ids $1
}

function check-dependency {
if ! command -v aws &> /dev/null
then
    echo "the dependency aws could not be found"
    echo "please install the cli tool aws"
    exit
fi
}

function print-help {
        echo " "
        echo "You have so many opportunities!!!"
        echo " "
        echo "- create-image {instance_id} {image_target_name}"
        echo "- run-instance {frontend or backend} {image_id} {instance_name}"
        echo "- start-instance {instance_id}"
        echo "- stop-instance {instance_id}"
        echo "- delete-instance {instance_id}"
        echo " "
}




######--------------- beginn Script ---------------######
check-dependency
echo "starting script: $1"

if [ ! -z "$1" ]
then
    case $1 in
    help)
        # Help
        print-help
        ;;
    create-image)
        # Create Image
        echo "creating image..."
        create-image $2 $3
        ;;
    run-instance)
        # run Instance
        echo "running instance from ami"
        if [ ! -z "$2" ]
        then
            case $2 in
            frontend)
                run-instance-frontend $3 $4
                ;;
            backend)
                run-instance-backend $3 $4
                ;;
            *)
                ;;
            esac
        else
            echo "please define frontend or backend, the instance-id and the name of the image"
        fi
        ;;
    start-instance)
        start-instance $2
        ;;
    stop-instance)
        stop-instance $2
        ;;
    delete-instance)
        delete-instance $2
        ;;
    *)
        echo "Wrong argument"
        ;;
    esac
else
    echo "please define the mode of the script"
fi