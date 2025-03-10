/*module "network" {
  source = "../azure_resource_group"

  location      = var.location
  subnet_config = var.subnet_config
}*/

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

/*
 J'ai maintenant le cluster pret a acceuillir des pods/servicse etc cependant je n'ai aucun Ingress Controller.
 En utilisant Helm Chart je déploie mon controller nginx (j'utilise un chart de la communauté) et je fais pareil
 avec cert-manager qui est l'outils pour gérer les certificats HTTPS, et enfin redis.

 Je passe volontairement avec les Charts de la communauté pour simplifier, je n'ai pas besoin de re-coder
 quelque chose que le constructeur fera mieux que moi! Cependant ça ne m'empeche pas d'aller voir comment 
 ils ont fait (On ne sait jamais dans certains cas je pourrais avoir a le faire moi même).

 N'oubliez pas l'acronyme KISS (Keep It Simple Stupid https://en.wikipedia.org/wiki/KISS_principle ), 
 ou le rasoir d'Occam (shorturl.at/eBEFV)
*/

# UPDATE YOUR KUBE CONFIG OTHERWISE HELM WILL NOT BE ABLE TO DEPLOY THE CHART 


resource "local_file" "kube_config" {
  content  = azurerm_kubernetes_cluster.aks.kube_config_raw
  filename = ".kube/config"
}

resource "helm_release" "chart" {
  for_each         = var.charts
  name             = each.key
  namespace        = each.key
  create_namespace = each.value.create_namespace
  repository       = each.value.repository
  chart            = each.key
  version          = each.value.version

  dynamic "set" {
    for_each = each.value.sets
    content {
      name = set.key
      value = set.value
    }
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_resource_group.rg,
    local_file.kube_config
  ]
}