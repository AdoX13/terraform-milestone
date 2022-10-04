provider "aws" {
    region = "eu-central-1"
}

terraform {
    backend "local" {
        path = "./terraform.tfstate"
    }
}