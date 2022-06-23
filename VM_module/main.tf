# configures the network interface for the frontend VMs
resource "azurerm_network_interface" "FENetInterfaces" {
  count               = var.amount_of_machines
  location            = var.resource_group_location
  name                = "frontendNI${count.index}"
  resource_group_name = var.resource_group_name


  ip_configuration {
    name                          = "NI${count.index}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.frontend_subnet_id
  }
}

# creates 3 virtual machines for the frontend
resource "azurerm_linux_virtual_machine" "FEVirtualMachines" {
  count                 = var.amount_of_machines
  location              = var.resource_group_location
  name                  = "frontendVM${count.index}"
  network_interface_ids = [element(azurerm_network_interface.FENetInterfaces.*.id, count.index)]
  resource_group_name   = var.resource_group_name
  availability_set_id   = var.availability_set_id
  size                  = "Standard_D2s_v3"

  admin_username                  = "adminuser"
  admin_password                  = var.VM_Password
  disable_password_authentication = false



  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "Canonical"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
