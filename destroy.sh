#!/bin/bash

env=$1

if [[ "$env" != "DEV" && "$env" != "PROD" ]]; then
	echo "Usage: ./deploy.sh DEV/PROD"
	exit 1
fi

cd live/$env/services
terraform apply -destroy -auto-approve

cd ../data-storage
terraform apply -destroy -auto-approve

cd ../network
terraform apply -destroy -auto-approve
