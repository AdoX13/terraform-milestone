# Terraform remote states
data "terraform_remote_state" "network" {
    backend = "s3"
    config = {
        bucket = "ms5-apopa-tfstate"
        key = "DEV/network/terraform.tfstate"
        region = "eu-central-1"
    }
}

# DATABASES

# Database for webapp
resource "aws_db_instance" "mysql" {
    identifier = "ms5-apopa-${var.s_env}-mysql-database"
    engine = "mysql"
    instance_class = "db.t2.micro"
    allocated_storage = 10
    db_subnet_group_name = data.terraform_remote_state.network.outputs.subnet_group
    vpc_security_group_ids = [data.terraform_remote_state.network.outputs.security_group_priv]
    skip_final_snapshot = true
    
    db_name = "webapp_db"
    username = "admin"
    password = "test1234"

    tags = {
        Name = "ms5-apopa-${var.env}-mysql-database"
    }
}
