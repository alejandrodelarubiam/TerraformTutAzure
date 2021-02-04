provider "azurerm" {
  version = "=2.4.0"
  features {}
}

resource "azurerm_resource_group" "RG-AlexTutAzure" {
  name     = "terraform-resource-group"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "ASP-TerraForm" {
  name                = "terraform-appserviceplan"
  location            = azurerm_resource_group.RG-AlexTutAzure.location
  resource_group_name = azurerm_resource_group.RG-AlexTutAzure.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "AS-Terraform" {
  name                = "app-service-terraform"
  location            = azurerm_resource_group.RG-AlexTutAzure.location
  resource_group_name = azurerm_resource_group.RG-AlexTutAzure.name
  app_service_plan_id = azurerm_app_service_plan.ASP-TerraForm.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.tutazurealexdbterraform.fully_qualified_domain_name} Database=${azurerm_sql_database.terraform-sqldatabase.name};User ID=${azurerm_sql_server.tutazurealexdbterraform.administrator_login};Password=${azurerm_sql_server.tutazurealexdbterraform.administrator_login_password};Trusted_Connection=False;Encrypt=True;"
  }
}

resource "azurerm_sql_server" "tutazurealexdbterraform" {
  name                         = "tutazurealexdbterraform"
  resource_group_name          = azurerm_resource_group.RG-AlexTutAzure.name
  location                     = azurerm_resource_group.RG-AlexTutAzure.location
  version                      = "12.0"
  administrator_login          = "houssem"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_sql_database" "terraform-sqldatabase" {
  name                = "terraform-sqldatabase"
  resource_group_name = azurerm_resource_group.RG-AlexTutAzure.name
  location            = azurerm_resource_group.RG-AlexTutAzure.location
  server_name         = azurerm_sql_server.tutazurealexdbterraform.name

  tags = {
    environment = "production"
  }
}
