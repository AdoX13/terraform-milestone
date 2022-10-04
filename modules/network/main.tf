# VPC
resource "aws_vpc" "vpc_1" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "ms5-apopa-${var.env}-vpc-1"
    }
}

# Security Groups

# SG for public subnet
resource "aws_security_group" "vpc_1_pub_sg" {
    description = "Security group for ${var.env} public subnet"
    name = "ms5-apopa-${var.env}-vpc-1-pub-sg"
    vpc_id = aws_vpc.vpc_1.id
    tags = {
        Name = "ms5-apopa-${var.env}-vpc-1-pub-sg"
    }
}

resource "aws_security_group_rule" "inbound_vpn_ssh_pub" {
    description = "In-bound internal rules for ssh"
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["194.117.242.0/26", "195.93.136.0/26"]
    security_group_id = aws_security_group.vpc_1_pub_sg.id
}

resource "aws_security_group_rule" "outbound_all_ssh_pub" {
    description = "Outbound to all web, any protocol"
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.vpc_1_pub_sg.id
}

# SG for private subnets
resource "aws_security_group" "vpc_1_priv_sg" {
    description = "Security group for ${var.env} private subnets"
    name = "ms5-apopa-${var.env}-vpc-1-priv-sg"
    vpc_id = aws_vpc.vpc_1.id
    tags = {
        Name = "ms5-apopa-${var.env}-vpc-1-priv-sg"
    }
}

resource "aws_security_group_rule" "outbound_all_ssh_priv" {
    description = "Outbound to all web, any protocol"
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.vpc_1_priv_sg.id
}

# rule
resource "aws_security_group_rule" "inbound_mysql_pub" {
    description = ""
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    security_group_id = aws_security_group.vpc_1_pub_sg.id
}

resource "aws_security_group_rule" "inbound_mysql_priv" {
    description = ""
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    security_group_id = aws_security_group.vpc_1_priv_sg.id
}

# SG for bastion-host
resource "aws_security_group" "vpc_1_bastion_sg" {
    description = "Security group for ${var.env} private subnets"
    name = "ms5-apopa-${var.env}-vpc-1-bastion-sg"
    vpc_id = aws_vpc.vpc_1.id
    tags = {
        Name = "ms5-apopa-${var.env}-vpc-1-bastion-sg"
    }
}

resource "aws_security_group_rule" "inbound_vpn_ssh_bastion" {
    description = "In-bound internal rules for ssh"
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["194.117.242.0/26", "195.93.136.0/26"]
    security_group_id = aws_security_group.vpc_1_bastion_sg.id
}

resource "aws_security_group_rule" "inbound_vpn_httpd_bastion" {
    description = "In-bound internal rules for accessing the webapp on 8080"
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["194.117.242.0/26", "195.93.136.0/26"]
    security_group_id = aws_security_group.vpc_1_bastion_sg.id
}

# SG rule - bastion to private subnets
resource "aws_security_group_rule" "inbound_bastion_ssh_private" {
    description = "In-bound rules for connecting to private subnets from bastion-host"
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = aws_security_group.vpc_1_bastion_sg.id
    security_group_id = aws_security_group.vpc_1_priv_sg.id
}



# Subnets

# Public Subnet
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.vpc_1.id
    cidr_block = "10.0.0.0/24"
    tags = {
        Name = "ms5-apopa-${var.env}-pub-subnet"
    }
}

# Private Subnet 1
resource "aws_subnet" "private_subnet_1" {
    vpc_id = aws_vpc.vpc_1.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-central-1a"
    tags = {
        Name = "ms5-apopa-${var.env}-priv-subnet-1"
    }
}

# Private Subnet 2
resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.vpc_1.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "eu-central-1b"
    tags = {
        Name = "ms5-apopa-${var.env}-priv-subnet-2"
    }
}


# Subnet group
resource "aws_db_subnet_group" "default_sn_group" {
    name = "ms5-apopa-${var.s_env}-subnet-group"
    subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

    tags = {
        Name = "ms5-apopa-${var.env}-subnet-group"
    }
}

# NAT and Internet Gateways
resource "aws_internet_gateway" "Internet_GW" {
    vpc_id = aws_vpc.vpc_1.id
    tags = {
        Name = "ms5-apopa-${var.env}-Internet-GW"
    }
}

resource "aws_eip" "NAT_GW_eip" {
    vpc = true
    depends_on = [aws_internet_gateway.Internet_GW]
    tags = {
        Name = "ms5-apopa-${var.env}-EIP-for-NAT-GW"
    }
}

resource "aws_nat_gateway" "NAT_GW" {
    allocation_id = aws_eip.NAT_GW_eip.id
    subnet_id = aws_subnet.public_subnet.id
    tags = {
        Name = "ms5-apopa-${var.env}-NAT-GW"
    }
}



# ROUTE TABLES

# Public subnets RTs
resource "aws_route_table" "public_RT" {
    vpc_id = aws_vpc.vpc_1.id
    tags = {
        Name = "ms5-apopa-${var.env}-public-RT"
    }
}

resource "aws_route_table_association" "public_sn" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_RT.id
}

resource "aws_route" "internet_gw_route" {
    route_table_id = aws_route_table.public_RT.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_GW.id
}

# Private subnets RTs
resource "aws_route_table" "private_RT" {
    vpc_id = aws_vpc.vpc_1.id
    tags = {
        Name = "ms5-apopa-${var.env}-private-RT"
    }
}

resource "aws_route_table_association" "private_sn_1" {
    subnet_id = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.private_RT.id
}

resource "aws_route_table_association" "private_sn_2" {
    subnet_id = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.private_RT.id
}

resource "aws_route" "nat_gw_route" {
    route_table_id = aws_route_table.private_RT.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_GW.id
}
