#!/bin/bash

env=$1

if [[ "$env" != "DEV" && "$env" != "PROD" ]]; then
	echo "Usage: ./deploy.sh DEV/PROD"
	exit 1
fi

cd live/$env/network
terraform init
terraform apply -auto-approve

cd ../data-storage
terraform init
terraform apply -auto-approve

cd ../services
terraform init
terraform apply -auto-approve
