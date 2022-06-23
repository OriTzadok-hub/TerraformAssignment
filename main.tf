# configure the resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

# configure availability set for the front end VMs
resource "azurerm_availability_set" "avset" {
  depends_on          = [azurerm_resource_group.rg]
  location            = var.resource_group_location
  name                = "TFAvset"
  resource_group_name = var.resource_group_name
}

# summons a module that creates virtual machines with network interface
# parameters :
# * resource_group_location & resource_group_name - details of the resource group that the VM will be created in
# * frontend_subnet_id  - id of the subnets to attach to the network interface of the VM
# * availability_set_id - id of the availability set to attach to the VMs
# * amount_of_machines - the amount of virtual machines to be created
# * VM_Password - the password for the VM
# outputs :
# VMs password
# network interfaces of the VMs
module "virtualMachines" {
  depends_on              = [azurerm_resource_group.rg, azurerm_subnet.backendSN, azurerm_subnet.frontendSN, azurerm_availability_set.avset]
  source                  = "./VM_module"
  resource_group_location = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  frontend_subnet_id      = azurerm_subnet.frontendSN.id
  availability_set_id     = azurerm_availability_set.avset.id
  amount_of_machines      = var.amount_of_VM
  VM_Password             = var.VM_Password
}



