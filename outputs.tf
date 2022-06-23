output "VM_Password" {
  value     = module.virtualMachines.VM_Password
  sensitive = true
}