output "sql_admin_password" {
  description = "SQL admin password"
  value       = random_password.azuresql_adm_pass.result
}
output "sql_admin_user" {
  description = "SQL admin user"
  value       = var.sql_server_admin_user
}
