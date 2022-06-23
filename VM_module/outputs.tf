output "frontend_network_interfaces" {
  value = azurerm_network_interface.FENetInterfaces
}

output "VM_Password" {
  value = azurerm_linux_virtual_machine.FEVirtualMachines[0].admin_password
}

