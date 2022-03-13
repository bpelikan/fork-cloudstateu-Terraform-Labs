data "azurerm_resource_group" "rg" {
  name = var.resource-group-name
}
data "azurerm_client_config" "current" {

}

resource "azurerm_key_vault" "current" {
  name                        = var.key-vault-name
  location                    = data.azurerm_resource_group.rg.location
  resource_group_name         = data.azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = var.key-vault-sku

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get"
    ]

  }
}