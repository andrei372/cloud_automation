#############################
#    Container Registry     #
#############################
# ==============================================================================================================
resource "azurerm_container_registry" "acr" {
  name                     = "akseastuscontreg"
  resource_group_name      = var.resource_group_name
  location                 = element(var.regions,0)
  sku                      = "Premium"
  admin_enabled            = false
  georeplication_locations = var.regions
}

#############################
#       Log Analytics       #
#############################
# ==============================================================================================================
resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "aks-log-work" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = element(var.regions,0)
    resource_group_name = var.resource_group_name
    sku                 = var.log_analytics_workspace_sku
}
resource "azurerm_log_analytics_solution" "aks-log-analytics" {
    solution_name         = "ContainerInsights"
    location              = element(var.regions,0)
    resource_group_name   = var.resource_group_name
    workspace_resource_id = azurerm_log_analytics_workspace.aks-log-work.id
    workspace_name        = azurerm_log_analytics_workspace.aks-log-work.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}
#############################
#            AKS            #
#############################
# ==============================================================================================================

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                    = var.aks_name
  location                = element(var.regions,0)
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.dns_prefix
  # Enabling the actual private AKS cluster feature will also create a Private DNS Zone resource
  # which will have an A Record pointing to the private IP address of the API
  # allowing everyone from the AKS VNET (Spoke) to resolve the control plane’s address
  private_cluster_enabled = true

  linux_profile {
      admin_username = var.aks_node_username

      ssh_key {
          key_data = file(var.ssh_public_key)
      }
  }

  default_node_pool {
    name                     = "aksnodepool"
    #node_count               = var.node_count
    vm_size                  = var.nodepool_vm_size
    enable_auto_scaling      = var.enable_auto_scaling
    enable_node_public_ip    = var.enable_node_public_ip
    min_count                = var.node_min_count
    max_count                = var.node_max_count
    vnet_subnet_id           = var.nodepool_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  # Add the log analytics profile we created earlier
  addon_profile {
    http_application_routing {
      enabled = var.enable_http_application_routing
    }
    kube_dashboard {
      enabled = var.enable_kube_dashboard
    }
    aci_connector_linux {
      enabled = var.enable_aci_connector_linux
    }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks-log-work.id
    }
  }

  # NETWORK PROFILE based on VNETS created
  network_profile {
    docker_bridge_cidr = var.network_docker_bridge_cidr
    dns_service_ip     = var.network_dns_service_ip
    network_plugin     = "azure"
    # Setting outbound type to userDefinedRouting  will prevent creating a public IP for the cluster’s
    # egress traffic and make use of the “user defined” Route Table
    outbound_type      = "userDefinedRouting"
    service_cidr       = var.network_service_cidr
  }

  tags = {
      Environment = var.environment
  }
}

# https://github.com/Azure/AKS/issues/1557
resource "azurerm_role_assignment" "vmcontributor" {
  role_definition_name = "Virtual Machine Contributor"
  scope                = var.resource_group_id
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
}
