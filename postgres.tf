# create dns zone for the postgres server
resource "azurerm_private_dns_zone" "dnsZone" {
  name                = "${var.resource_group_name}19962022.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_subnet_network_security_group_association.postgresNSGLink]
}

# link the dns zone to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "dnsZoneLink" {
  name                  = "${var.resource_group_name}netlink19962022.com"
  private_dns_zone_name = azurerm_private_dns_zone.dnsZone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
  depends_on = [azurerm_private_dns_zone.dnsZone]
}

# create postgres flexible server
resource "azurerm_postgresql_flexible_server" "flexPostgres" {
  name                   = var.server_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "13"
  delegated_subnet_id    = azurerm_subnet.postgresSubnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.dnsZone.id
  administrator_login    = "adminuser"
  administrator_password = var.DB_Password
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  backup_retention_days  = 7

  depends_on = [azurerm_private_dns_zone_virtual_network_link.dnsZoneLink]
}

# configure the postgres server
resource "azurerm_postgresql_flexible_server_configuration" "postgresConfig" {
  depends_on = [azurerm_postgresql_flexible_server.flexPostgres]
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.flexPostgres.id
  value     = "off"
}

# create a data-base in the postgres server
resource "azurerm_postgresql_flexible_server_database" "postgresDB" {
  depends_on = [azurerm_postgresql_flexible_server.flexPostgres]
  name      = "postgresDB"
  server_id = azurerm_postgresql_flexible_server.flexPostgres.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}