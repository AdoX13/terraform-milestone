output "database_address" {
    value = module.data-storage.database_address
}

output "database_username" {
    value = module.data-storage.database_username
}

output "database_port" {
    value = module.data-storage.database_port
}

output "database_name" {
    value = module.data-storage.database_name
}

output "database_password" {
    value = module.data-storage.database_password
    sensitive = true
}