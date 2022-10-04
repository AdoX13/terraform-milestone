provider "aws" {
    region = "eu-central-1"
}

terraform {
    backend "s3" {
        bucket = "ms5-apopa-tf-state"
        key = "DEV/network/terraform.tfstate"
        region = "eu-central-1"

        dynamodb_table = "ms5-apopa-tf-locks"
        encrypt = true
    }
}