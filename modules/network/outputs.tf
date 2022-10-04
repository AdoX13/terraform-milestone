output "vpc_1" {
    value = aws_vpc.vpc_1.id
}

output "subnet_pub" {
    value = aws_subnet.public_subnet.id
}

output "subnet_priv1" {
    value = aws_subnet.private_subnet_1.id
}

output "subnet_priv2" {
    value = aws_subnet.private_subnet_2.id
}

output "security_group_pub" {
    value = aws_security_group.vpc_1_pub_sg.id
}

output "security_group_priv" {
    value = aws_security_group.vpc_1_priv_sg.id
}

output "security_group_bastion" {
    value = aws_security_group.vpc_1_bastion_sg.id
}

output "subnet_group" {
    value = aws_db_subnet_group.default_sn_group.id
}