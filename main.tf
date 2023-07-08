resource "azurerm_resource_group" "acr_rg" {
  name     = "acr-rg"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "897safsacr"
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_container_registry_task" "lemmy_nginx" {
  name                  = "build-lemmy-nginx"
  container_registry_id = azurerm_container_registry.acr.id
  platform {
    os = "Linux"
  }

  docker_step {
    dockerfile_path      = var.dockerfile
    context_path         = "https://github.com/timwebster9/nginx-lemmy#main"
    context_access_token = var.pat_token
    image_names          = ["lemmy-nginx:{{.Run.ID}}"]
  }

  source_trigger {
    name           = "build-lemmy-nginx"
    events         = ["commit"]
    repository_url = "https://github.com/timwebster9/nginx-lemmy.git"
    source_type    = "Github"
    branch         = "main"
  }
}
