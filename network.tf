# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  depends_on          = [azurerm_resource_group.rg]
  name                = "TFNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# configure frontend subnet
resource "azurerm_subnet" "frontendSN" {
  depends_on           = [azurerm_virtual_network.vnet]
  name                 = "frontendSN"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# configure subnet for the postgres server
resource "azurerm_subnet" "postgresSubnet" {
  depends_on = [azurerm_virtual_network.vnet]
  name                 = "PostgresSubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# configure NSG for the frontend subnet
resource "azurerm_network_security_group" "frontendNSG" {
  depends_on          = [azurerm_resource_group.rg]
  location            = var.resource_group_location
  name                = "frontendNSG"
  resource_group_name = var.resource_group_name

  # allow ssh from current machine ip
  security_rule {
    name                       = "allowSSHPublic"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = var.ansible_controller_ip
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }


  # allow access to the app through port 8080
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "allow8080"
    priority                   = 110
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "8080"
    destination_address_prefix = "*"
  }

  # deny all other access options
  security_rule {
    access                     = "Deny"
    direction                  = "Inbound"
    name                       = "denyAll"
    priority                   = 1000
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }

}


# configure NSG for the backend subnet
resource "azurerm_network_security_group" "backendNSG" {
  depends_on          = [azurerm_resource_group.rg]
  location            = var.resource_group_location
  name                = "backendNSG"
  resource_group_name = var.resource_group_name


  # allow postgres to the backend machine from the front end subnet machines
  security_rule {
    name                       = "allowPostgres"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefixes    = azurerm_subnet.frontendSN.address_prefixes
    destination_port_range     = "5432"
    destination_address_prefix = "*"
  }

  # deny all the rest of the access
  security_rule {
    access                     = "Deny"
    direction                  = "Inbound"
    name                       = "denyAll"
    priority                   = 1000
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }

}

# connect the frontend NSG to the frontend subnet
resource "azurerm_subnet_network_security_group_association" "FESubnetNSGAssociation" {
  depends_on                = [azurerm_subnet.frontendSN, azurerm_network_security_group.frontendNSG]
  network_security_group_id = azurerm_network_security_group.frontendNSG.id
  subnet_id                 = azurerm_subnet.frontendSN.id
}

# connect the backend NSG to the postgres subnet
resource "azurerm_subnet_network_security_group_association" "postgresNSGLink" {
  depends_on = [azurerm_subnet.postgresSubnet]
  subnet_id                 = azurerm_subnet.postgresSubnet.id
  network_security_group_id = azurerm_network_security_group.backendNSG.id
}
