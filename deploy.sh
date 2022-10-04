#!/bin/bash

env=$1
action=$2

if [[ "$env" != "DEV" && "$env" != "PROD" && "$action" != "create" && "$action" != "destroy" ]]; then
	echo "Usage: ./deploy.sh DEV/PROD create/destroy"
	exit 1
fi

cd live/global/s3
terraform init
terraform apply -auto-approve
cd ../../

if [[ "$action" == "create" ]]
then
	# Deploy network
	cd $env/network
	terraform init
	terraform apply -auto-approve
	# Deploy data-storage
	cd ../data-storage
	terraform init
	terraform apply -auto-approve
	# Deploy services
	cd ../services
	terraform init
	terraform apply -auto-approve
else
	# Destroy services
	cd $env/services
	terraform apply -destroy -auto-approve
	# Destroy data-storage
	cd ../data-storage
	terraform apply -destroy -auto-approve
	# Dstroy network
	cd ../network
	terraform apply -destroy -auto-approve
fi
