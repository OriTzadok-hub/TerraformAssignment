# TerraformAssignment

## description
This files contain a terraform code that creates a network infrastructure 
with frontend and backend subnets , 
on the frontend side there is an availability set of any amount that you choose of Virtual Machines that are connected to a loadbalancer ,
and they run our Weight Tracking Web App,
on the backend side there is a managed postgres server that holds the database of our app.

## installation
follow the installation and configuration guide on this link (you can install via powershell/bash/azure cloud shell - pick your favorite)
https://docs.microsoft.com/en-us/azure/developer/terraform/quickstart-configure
after you are done configuring,you can clone the repository :) (git clone https://github.com/OriTzadok-hub/TerraformAssignment.git)

## workspaces
the code comes with 2 workspaces(besides the default one) - staging and production,
the workspaces are used to create 2 different resource enviroments.

to navigate between the workspaces use the command: *terraform workspace select <desired-workspace>*
  
to add a workspace use the command: *terraform workspace new <workspace-name>*
  
to see all your workspaces use the command: *terraform workspace list*
  
to see which workspace is currently active use the command: *terraform workspace show*

## variables
the code expects certain variables, you can check the file variables.tf to see which ones.

you can pre-set the variables of each workspace by adding them to the .tfvars files(for example production.tfvars for the production workspace) - if you create a new workspace you should create a new .tfvars file for it.
  
or you can just set them on runtime.


## remote storage 
there is a file named backend.tf which is used to store your tfstate file remotely ,
in order to use it you need to create (manually) a storage account resource on your azure portal and add a container to it,
after that go to the backend.tf file and change the values of the parameters in it to the ones you created.
if you do not wish to store your tfstate file remotely you can just delete this file.

## output
the code will output the password of the virtual machines after the *terraform apply* command ,
please note that the output will be hidden by a (sensitive content) tag , in order to see the content - 
simply write the command *terraform output VM_Password* after you apply the code.
the user name of the VM is *adminuser*

## running the terraform code
*terraform init* 
  
in each of the following commands(plan/destroy/apply), when wanting to use the specifc .tfvars file for each workspace add the code *-var-file <name>.tfvars*
  
for example when in the production workspace: *terraform apply -var-file production.tfvars*
  
(optional) *terraform plan* - shows you whats about to be made/destroyed/changed/updated
  
*terraform apply* - creates the infrastructure

if you wish to destroy the infrastructure after applying it:
*terraform destroy*
