output "vpc_1" {
    value = module.network.vpc_1
}

output "subnet_pub" {
    value = module.network.subnet_pub
}

output "subnet_priv1" {
    value = module.network.subnet_priv1
}

output "subnet_priv2" {
    value = module.network.subnet_priv2
}

output "security_group_pub" {
    value = module.network.security_group_pub
}

output "security_group_priv" {
    value = module.network.security_group_priv
}

output "security_group_bastion" {
    value = module.network.security_group_bastion
}

output "subnet_group" {
    value = module.network.subnet_group
}