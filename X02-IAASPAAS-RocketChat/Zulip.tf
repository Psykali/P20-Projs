# Zulip Web App
resource "azurerm_app_service" "zulip_app" {
  name                = var.zulip_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    linux_fx_version = "DOCKER|zulip/docker-zulip:4.8-0"
    scm_type         = "None"
  }

  app_settings = {
    "SECRETS_email_password"      = var.zulip_email_password
    "SECRETS_rabbitmq_password"   = var.zulip_rabbitmq_password
    "SECRETS_postgres_password"   = var.zulip_postgres_password
    "SECRETS_memcached_password"  = var.zulip_memcached_password
    "SECRETS_redis_password"      = var.zulip_redis_password
    "SETTING_EXTERNAL_HOST"       = var.zulip_external_host
    "SETTING_ZULIP_ADMINISTRATOR" = var.zulip_administrator_email
    "SETTING_ADMIN_DOMAIN"        = var.zulip_admin_domain
  }
}

# Redis Cache
resource "azurerm_redis_cache" "redis" {
  name                = var.redis_name
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false
}

# PostgreSQL Server
resource "azurerm_postgresql_server" "postgres" {
  name                = var.postgres_server_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "B_Gen5_2"
  storage_mb          = 5120
  backup_retention_days = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled = true
  administrator_login          = var.postgres_admin_username
  administrator_login_password = var.postgres_admin_password
  version                      = "11"
  ssl_enforcement_enabled      = true
}

# PostgreSQL Database
resource "azurerm_postgresql_database" "postgres_db" {
  name                = var.postgres_database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgres.name
  charset             = "UTF8"
  collation           = "en_US.UTF8"
}
