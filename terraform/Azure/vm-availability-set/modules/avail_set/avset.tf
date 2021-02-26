
 resource "azurerm_availability_set" "winavset" {
 name                = var.av_set_name
 location            = element(var.regions,0)
 resource_group_name = var.resource_group_name

 tags = {
   Name = var.environment
 }
}
