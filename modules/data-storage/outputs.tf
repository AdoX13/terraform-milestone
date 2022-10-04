output "database_address" {
    value = aws_db_instance.mysql.address
}

output "database_username" {
    value = aws_db_instance.mysql.username
}

output "database_port" {
    value = aws_db_instance.mysql.port
}

output "database_name" {
    value = aws_db_instance.mysql.db_name
}

output "database_password" {
    value = aws_db_instance.mysql.password
}