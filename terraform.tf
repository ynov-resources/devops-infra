
resource "azurerm_resource_group" "rg" {
  name = "plop"
  location = "FranceCentral"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = format("%s-%s", var.name, terraform.workspace)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = format("%s-%s", var.name, terraform.workspace)

  default_node_pool {
    name       = var.aks_node_pool_config.default.name
    node_count = var.aks_node_pool_config.default.node_count
    vm_size    = var.aks_node_pool_config.default.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}