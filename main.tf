resource "azurerm_firewall_policy" "this" {
  name                = var.policy_name
  resource_group_name = var.resource_group
  location            = var.location

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "example" {
  name               = var.rule_collection_group_name
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = var.rule_collection_group_priority

  dynamic "network_rule_collection" {
    for_each = var.network_rule_collections != null ? var.network_rule_collections : []
    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action
      dynamic "rule" {
        for_each = network_rule_collection.value.rule != null ? network_rule_collection.value.rule : tomap([{}])
        content {
          name                  = rule.key
          protocols             = rule.value.protocols
          source_addresses      = rule.value.source_addresses
          destination_addresses = rule.value.destination_addresses
          destination_ports     = rule.value.destination_ports
        }
      }
    }
  }

  dynamic "application_rule_collection" {
    for_each = var.application_rule_collections != null ? var.application_rule_collections : []

    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rule != null ? application_rule_collection.value.rule : tomap([{}])
        content {
          name = rule.key
          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
          source_addresses  = rule.value.source_addresses
          destination_fqdns = rule.value.destination_fqdns
        }
      }
    }
  }
}

resource "azurerm_public_ip" "firewall" {
  name                = var.firewall_pip_name
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = var.firewall_pip_allocation_method
  sku                 = var.firewall_pip_sku

  lifecycle {
    ignore_changes = [tags]
  }
}

module "diagnostic_setting_firewall_pip" {
  source = "git::https://github.com/Noya50/hafifot-diagnosticSetting.git?ref=main"

  name                          = "${azurerm_public_ip.firewall.name}-diagnostic-setting"
  target_resource_id            = azurerm_public_ip.firewall.id
  log_analytics_workspace_id    = var.firewall_pip_log_analytics_workspace_id
  diagnostic_setting_categories = var.pips_diagnostic_setting_categories
}

resource "azurerm_public_ip" "management" {
  for_each = var.is_force_tunneling_enabled == true ? tomap({ 0 = true }) : tomap({})

  name                = var.management_pip_name
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = var.management_pip_allocation_method
  sku                 = var.management_pip_sku

  lifecycle {
    ignore_changes = [tags]
  }
}

module "diagnostic_setting_management_pip" {
  for_each = var.is_force_tunneling_enabled == true ? tomap({ 0 = true }) : tomap({})
  source   = "git::https://github.com/Noya50/hafifot-diagnosticSetting.git"

  name                          = "${azurerm_public_ip.management[0].name}-diagnostic-setting"
  target_resource_id            = azurerm_public_ip.management[0].id
  log_analytics_workspace_id    = var.management_pip_log_analytics_workspace_id != null ? var.management_pip_log_analytics_workspace_id : var.firewall_pip_log_analytics_workspace_id
  diagnostic_setting_categories = var.pips_diagnostic_setting_categories
}

resource "azurerm_firewall" "this" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = azurerm_firewall_policy.this.id

  ip_configuration {
    name                 = var.ip_configuration_name
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  dynamic "management_ip_configuration" {
    for_each = var.is_force_tunneling_enabled ? [1] : []
    content {
      name                 = var.management_ip_configuration_name
      subnet_id            = var.management_subnet_id
      public_ip_address_id = azurerm_public_ip.management[0].id
    }
  }

  dynamic "virtual_hub" {
    for_each = var.virtual_hub_enabled ? [1] : []
    content {
      virtual_hub_id  = var.virtual_hub_id
      public_ip_count = var.public_ip_count
    }
  }

  depends_on = [
    azurerm_firewall_policy.this,
    azurerm_public_ip.firewall,
  ]

  lifecycle {
    ignore_changes = [tags, ]
  }
}

module "diagnostic_setting" {
  source = "git::https://github.com/Noya50/hafifot-diagnosticSetting.git?ref=main"

  name                          = "${azurerm_firewall.this.name}-diagnostic-setting"
  target_resource_id            = azurerm_firewall.this.id
  log_analytics_workspace_id    = var.log_analytics_workspace_id
  diagnostic_setting_categories = var.diagnostic_setting_categories
}
