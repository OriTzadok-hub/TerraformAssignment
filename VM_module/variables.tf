variable "resource_group_name" {
  type = string
  description = "The name of the resource group"

}

variable "resource_group_location" {
  type = string
  description = "The location of the resource group"

}

variable "frontend_subnet_id" {
  type = string
  description = "The id of the frontend subnet"
}

variable "availability_set_id" {
  type = string
  description = "the id of the desired availability set to attach to the VMs"
}

variable "amount_of_machines" {
  type = number
  description = "the desired amount of machines to be created"
}

variable "VM_Password" {
  type = string
  description = "the password for the VM"
}
