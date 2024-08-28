Set initial variables and get app settings of source web app:
```
$SOURCE_WEB_NAME="webapp-ig-ntc-test"
$DEST_WEB_NAME="webapp-ig-paypense-test"
$SOURCE_RG_NAME="rg-ntc-test"
$DEST_RG_NAME="rg-paypense-test"

$SOURCE_SUB_ID="5ea488d9-2175-4b0b-a192-aa43b29dcdd4"
$DEST_SUB_ID="93c54646-be8d-459d-9ceb-023cd3cc0282"

az account set -s $SOURCE_SUB_ID

# Export app settings to a JSON file
az webapp config appsettings list --name $SOURCE_WEB_NAME --resource-group $SOURCE_RG_NAME --output json | Out-File -FilePath appsettings.json -Encoding utf8

```
Run the below commands in Linux to format the file correctly:
```
# Remember to validate each file after rename it
sed '1s/^\xEF\xBB\xBF//' appsettings.json > appsettings_nobom.json
mv appsettings_nobom.json appsettings.json
jq -r '[.[] | {(.name): .value}] | add' appsettings.json > appsettings_formatted.json
mv appsettings_formatted.json appsettings.json
jq 'del(.WEBSITE_HTTPLOGGING_RETENTION_DAYS, .WEBSITE_VNET_ROUTE_ALL)' appsettings.json > appsettings_filtered.json
mv appsettings_filtered.json appsettings.json
```

Create the web app and attach its appsetting using Terraform ( include previous created storage account ):

**main.tf**
```

# Main Terraform configuration for Azure Provider
provider "azurerm" {
  features {}
  alias = "destination"
}

terraform {
  backend "azurerm" {
    storage_account_name = "storeinfratestaks"
    container_name       = "tfstate"
    key                  = "paypense-webapp.tfstate"
    resource_group_name  = "rg-infra-test"
    subscription_id      = "93c54646-be8d-459d-9ceb-023cd3cc0282"
  }
}

# New Web App
resource "azurerm_windows_web_app" "webapp" {
  provider            = azurerm.destination
  name                = "webapp-ig-paypense-test"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = var.appplanid

  site_config {
    always_on    = true
    http2_enabled = true
  }

  # Import App Settings from JSON file
  app_settings = jsondecode(file("appsettings.json"))

  # Import Connection Strings from JSON file
  # dynamic "connection_string" {
  #   for_each = jsondecode(file("connectionstrings.json"))

  #   content {
  #     name  = connection_string.value["name"]
  #     type  = connection_string.value["type"]
  #     value = connection_string.value["value"]
  #   }
  # }
}


resource "azurerm_storage_account" "sa" {
  provider                     = azurerm.destination
  name                         = "storentctest2"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  account_tier                 = "Standard"
  account_replication_type     = "LRS"
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "storage_account_primary_connection_string" {
  value = azurerm_storage_account.sa.primary_connection_string
  sensitive = true
}

output "webapp_name" {
  value = azurerm_windows_web_app.webapp.name
}

```

**variables.tf**

```
variable "resource_group_name" {
  description = "The name of the destination resource group"
  type        = string
  default     = "rg-paypense-test"
}

variable "location" {
  description = "The location of the destination resource group"
  type        = string
  default     = "Germany West Central" 
}
variable "appplanid"{
  type        = string
  description = "App plan id"
}
```

**terraform.tfvars**

```
resource_group_name = "rg-paypense-test"
location            = "Germany West Central"
appplanid           = "/subscriptions/93c54646-be8d-459d-9ceb-023cd3cc0282/resourceGroups/rg-tim-test/providers/Microsoft.Web/serverFarms/appplan-smartbilling-test"
```

```
az account set -s $DEST_SUB_ID

terraform init
terraform plan
terraform apply 
```
Remember to add the missing configs for new web app, this code is still under development
