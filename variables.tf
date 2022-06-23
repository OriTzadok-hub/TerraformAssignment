variable "resource_group_name" {
  description = "The Name of the Resource Group"
  type        = string
}

variable "resource_group_location" {
  description = "the location of all the resources"
  type        = string
}

variable "ansible_controller_ip" {
  description = "the ip address of the ansible controller"
  type        = string
}

variable "VM_Password" {
  description = "the password for the VM"
  type        = string
}

variable "amount_of_VM" {
  description = "the desired amount of VM to be created"
  type        = number
}

variable "DB_Password" {
  description = "the password for the DB"
  type        = string
}

variable "server_name" {
  description = "the name of the postgres server"
  type = string
}


