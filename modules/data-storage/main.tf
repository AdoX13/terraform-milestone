# Terraform remote states
data "terraform_remote_state" "network" {
    backend = "local"
 
    config = {
        path = "../network/terraform.tfstate"
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
