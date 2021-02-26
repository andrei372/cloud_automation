output "sql_username" {
  description = "SQL Server User"
  value       = module.sqlenv.sql_admin_user
}

output "sql_password" {
  description = "SQL Server Password"
  value       = module.sqlenv.sql_admin_password
}
