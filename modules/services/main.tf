# Terraform remote states
data "terraform_remote_state" "datastorage" {
    backend = "s3"
    config = {
        bucket = "ms5-apopa-tf-state"
        key = "${var.env}/data-storage/terraform.tfstate"
        region = "eu-central-1"
    }
}

data "terraform_remote_state" "network" {
    backend = "s3"
    config = {
        bucket = "ms5-apopa-tf-state"
        key = "${var.env}/network/terraform.tfstate"
        region = "eu-central-1"
    }
}


# EC2 INSTANCES

# EC2 Main
resource "aws_instance" "ec2-main" {
    ami                    = "ami-05ff5eaef6149df49"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [data.terraform_remote_state.network.outputs.security_group_priv]
    subnet_id = data.terraform_remote_state.network.outputs.subnet_priv1
    iam_instance_profile = aws_iam_instance_profile.profile.id

    tags = {
        Name = "ms5-apopa-${var.env}-EC2-main"
    }

    user_data = templatefile("${path.module}/ec2-main.tftpl",
    {
        database_address = data.terraform_remote_state.datastorage.outputs.database_address
        database_name = data.terraform_remote_state.datastorage.outputs.database_name
        database_port = data.terraform_remote_state.datastorage.outputs.database_port
        database_username = data.terraform_remote_state.datastorage.outputs.database_username
        database_password = data.terraform_remote_state.datastorage.outputs.database_password
    })
}

# EC2 Bastion-Host
resource "aws_instance" "ec2-bastion-host" {
    ami                    = "ami-05ff5eaef6149df49"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [data.terraform_remote_state.network.outputs.security_group_bastion, data.terraform_remote_state.network.outputs.security_group_pub]
    subnet_id = data.terraform_remote_state.network.outputs.subnet_pub
    associate_public_ip_address = true
    iam_instance_profile = aws_iam_instance_profile.profile.id

    tags = {
        Name = "ms5-apopa-${var.env}-EC2-bastion-host"
    }
    
    user_data = templatefile("${path.module}/bastion-host.tftpl",
    {
        database_address = data.terraform_remote_state.datastorage.outputs.database_address
        database_name = data.terraform_remote_state.datastorage.outputs.database_name
        database_port = data.terraform_remote_state.datastorage.outputs.database_port
        database_username = data.terraform_remote_state.datastorage.outputs.database_username
        database_password = data.terraform_remote_state.datastorage.outputs.database_password
    })
}



# INSTANCE PROFILE

resource "aws_iam_instance_profile" "profile" {
    name = "ms5-apopa-${var.env}-profile-b"
    role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
    name = "ms5-apopa-${var.env}-role"
    path = "/"
    assume_role_policy =    <<EOF
                            {
                                "Version": "2012-10-17",
                                "Statement": [{
                                    "Action": "sts:AssumeRole",
                                    "Principal": {
                                        "Service": "ec2.amazonaws.com"
                                    },
                                    "Effect": "Allow",
                                    "Sid": ""
                                }]
                            }
                            EOF
    tags = {
        Name = "ms5-apopa-${var.env}-role"
    }
}

resource "aws_iam_role_policy_attachment" "attachment" {
    role = aws_iam_role.role.name
    count = length([
                    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
                    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
                  ])
    policy_arn = [
                    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
                    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
                 ][count.index]
}