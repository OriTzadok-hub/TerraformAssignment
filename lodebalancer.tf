# create public ip for the LB
resource "azurerm_public_ip" "ipforLB" {
  depends_on          = [azurerm_resource_group.rg]
  allocation_method   = "Static"
  location            = azurerm_resource_group.rg.location
  name                = "publicIPForLB"
  resource_group_name = azurerm_resource_group.rg.name
}

# configure a load balancer
resource "azurerm_lb" "loadBalancer" {
  depends_on          = [azurerm_resource_group.rg, azurerm_public_ip.ipforLB]
  location            = azurerm_resource_group.rg.location
  name                = "TFLoadbalancer"
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.ipforLB.id
  }
}

# create a back end pool for the LB
resource "azurerm_lb_backend_address_pool" "backendAddressPool" {
  depends_on      = [azurerm_lb.loadBalancer]
  loadbalancer_id = azurerm_lb.loadBalancer.id
  name            = "LBBackendAP"
}

# connect the VMs of the frontend to the LB's backend pool
resource "azurerm_network_interface_backend_address_pool_association" "VMsAssociation" {
  depends_on              = [azurerm_lb_backend_address_pool.backendAddressPool, module.virtualMachines]
  count                   = var.amount_of_VM
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendAddressPool.id
  ip_configuration_name   = "NI${count.index}"
  network_interface_id    = module.virtualMachines.frontend_network_interfaces[count.index].id
}

# configure a health probe for the LB
resource "azurerm_lb_probe" "LBProbe" {
  depends_on      = [azurerm_lb.loadBalancer]
  loadbalancer_id = azurerm_lb.loadBalancer.id
  name            = "LBHealthProbe"
  port            = 8080
  protocol        = "Http"
  request_path    = "/"
}

# configure a load balancing rule for the LB
resource "azurerm_lb_rule" "LBRule" {
  depends_on                     = [azurerm_lb_probe.LBProbe]
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
  frontend_port                  = 8080
  loadbalancer_id                = azurerm_lb.loadBalancer.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  probe_id                       = azurerm_lb_probe.LBProbe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backendAddressPool.id]

}

# configure a NAT rule for the LB
resource "azurerm_lb_nat_rule" "LBNATRule" {
  count                          = var.amount_of_VM
  depends_on                     = [azurerm_lb.loadBalancer]
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
  frontend_port                  = 4500 + count.index
  loadbalancer_id                = azurerm_lb.loadBalancer.id
  name                           = "SSHNATRule${count.index}"
  protocol                       = "Tcp"
  resource_group_name            = azurerm_resource_group.rg.name
}

# connect one of the frontend VMs to the NAT rule
resource "azurerm_network_interface_nat_rule_association" "NATAssociation" {
  count                 = var.amount_of_VM
  depends_on            = [azurerm_lb_nat_rule.LBNATRule, module.virtualMachines]
  ip_configuration_name = "NI${count.index}"
  nat_rule_id           = azurerm_lb_nat_rule.LBNATRule[count.index].id
  network_interface_id  = module.virtualMachines.frontend_network_interfaces[count.index].id
}



