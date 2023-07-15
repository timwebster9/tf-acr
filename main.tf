resource "azurerm_resource_group" "acr_rg" {
  name     = "acr-rg"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "897safsacr"
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  sku                 = "Standard"
  admin_enabled       = false
  anonymous_pull_enabled = true
}

/*
resource "azurerm_user_assigned_identity" "acr_mi" {
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
  name                = "acr-mi"
}

resource "azurerm_role_assignment" "acr_mi_role_assignment" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_mi.principal_id
}
*/

resource "azurerm_container_registry_task" "lemmy_nginx" {
  name                  = "build-lemmy-nginx"
  container_registry_id = azurerm_container_registry.acr.id
  platform {
    os = "Linux"
  }

  docker_step {
    dockerfile_path      = "Dockerfile"
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

    authentication {
      token = var.pat_token
      token_type = "PAT"
    }
  }
}

resource "azurerm_container_registry_task" "lemmy_caddy" {
  name                  = "build-lemmy-caddy"
  container_registry_id = azurerm_container_registry.acr.id
  platform {
    os = "Linux"
  }

  docker_step {
    dockerfile_path      = "Dockerfile"
    context_path         = "https://github.com/timwebster9/caddy-lemmy#main"
    context_access_token = var.pat_token
    image_names          = ["lemmy-caddy:{{.Run.ID}}"]
  }

  source_trigger {
    name           = "build-lemmy-caddy"
    events         = ["commit"]
    repository_url = "https://github.com/timwebster9/caddy-lemmy.git"
    source_type    = "Github"
    branch         = "main"

    authentication {
      token = var.pat_token
      token_type = "PAT"
    }
  }
}

resource "azurerm_container_registry_task" "lemmy" {
  name                  = "build-lemmy"
  container_registry_id = azurerm_container_registry.acr.id
  platform {
    os = "Linux"
  }

  docker_step {
    dockerfile_path      = "Dockerfile"
    context_path         = "https://github.com/timwebster9/lemmy-server#main"
    context_access_token = var.pat_token
    image_names          = ["lemmy:{{.Run.ID}}"]
  }

  source_trigger {
    name           = "build-lemmy"
    events         = ["commit"]
    repository_url = "https://github.com/timwebster9/lemmy-server.git"
    source_type    = "Github"
    branch         = "main"

    authentication {
      token = var.pat_token
      token_type = "PAT"
    }
  }
}
