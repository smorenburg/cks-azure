locals {
  # Set the log categories.
  key_vault_log_categories = data.azurerm_monitor_diagnostic_categories.key_vault.log_category_types

  # Set the metric categories.
  key_vault_metric_categories = data.azurerm_monitor_diagnostic_categories.key_vault.metrics
}

# Create the key vault.
resource "azurerm_key_vault" "default" {
  name                       = "kv-${local.app}-${var.environment}-${random_id.key_vault.hex}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.default.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
}

# Create the key vault policy for the current user.
resource "azurerm_key_vault_access_policy" "default" {
  key_vault_id = azurerm_key_vault.default.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Update",
    "Sign",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]

  secret_permissions = [
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Set"
  ]
}

# Create the key vault access policy for the disk encryption set managed identity.
resource "azurerm_key_vault_access_policy" "disk_encryption_set" {
  key_vault_id = azurerm_key_vault.default.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.disk_encryption_set.principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}

# Create the key for the disk encryption set.
resource "azurerm_key_vault_key" "disk_encryption_set" {
  name         = "disk-encryption-set"
  key_vault_id = azurerm_key_vault.default.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [
    azurerm_key_vault_access_policy.disk_encryption_set,
    azurerm_key_vault_access_policy.default
  ]
}

# Create the secret for the SSH private key.
resource "azurerm_key_vault_secret" "ssh" {
  name         = "ssh-default"
  value        = tls_private_key.ssh.private_key_pem
  key_vault_id = azurerm_key_vault.default.id

  depends_on = [
    azurerm_key_vault_access_policy.default
  ]
}

# Collect the diagnostic categories.
data "azurerm_monitor_diagnostic_categories" "key_vault" {
  resource_id = azurerm_key_vault.default.id
}

# Create the default diagnostic setting, excluding the kube-audit logs.
resource "azurerm_monitor_diagnostic_setting" "key_vault_default" {
  name                           = "default"
  target_resource_id             = azurerm_key_vault.default.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.default.id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = local.key_vault_log_categories

    content {
      category = enabled_log.key
    }
  }

  dynamic "metric" {
    for_each = local.key_vault_metric_categories

    content {
      category = metric.key
      enabled  = false
    }
  }
}
