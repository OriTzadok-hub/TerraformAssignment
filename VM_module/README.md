# Virtual Machine Module

## description
This module creates a given amount of Virtual Machines.

## input variables
This module needs to recieve several variables:

* resource group name & location
* subnet id - to connect the VM network interface
* amount of machines - the desired amount of machines to be created
* password - the desired password for the VM
* availability set id - the id of the availability set the VM will be attached to

## output variables

* VM password - the password of the VM
* network interface resource - if needed for further use in the code

## module summon example
module "example" {

  source                  = "./VM_module" #path to module directory
  
  resource_group_location = 
  
  resource_group_name     = 
  
  frontend_subnet_id      = 
  
  availability_set_id     = 
  
  amount_of_machines      = 
  
  VM_Password             = 
  
}
