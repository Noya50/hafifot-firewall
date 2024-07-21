variable "firewall_name" {
  description = "(Required) The name of the firewall resource."
  type        = string
}

variable "resource_group" {
  description = "(Required) The name of the aks's resource group"
  type        = string
}

variable "location" {
  description = "(Required) The location associated with the aks"
  type        = string
}

variable "vnet_name" {
  description = "(Required) The vnat in which the firewall will be established"
  type        = string
}

variable "firewall_subnet_id" {
  description = "(Required) The id of the firewall subnet."
  type        = string
}

variable "firewall_pip_log_analytics_workspace_id" {
  description = "(Required) Log analytics workspace for the diagnostic setting of the firewall pip."
  type = string
}

variable "management_pip_log_analytics_workspace_id" {
  description = "(Optional) Log analytics workspace for the diagnostic setting of the management pip. If a management ip is created but this value is not specified, the log_analytics_workspace_id of the firewall pip will be used."
  type = string
  default = null
}

variable "pips_diagnostic_setting_categories" {
  description = "(Optional) Categories for the diagnostic setting of the pips."
  type = list(string)
  default = [ "DDoSProtectionNotifications", "DDoSMitigationFlowLogs", "DDoSMitigationReports" ]
}

variable "policy_name" {
  description = "(Optional) The name of the firewall's policy"
  default     = "firewall-policy-tf"
  type        = string
}

variable "is_force_tunneling_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Determines whether force-tunneling is enabled. Default 'false', marking 'true' forces a management_subnet_id definition."
}

variable "management_subnet_id" {
  description = "(Optional) The id of the management subnet. Having a management IP and a management subnet allows force-tunnelling."
  type        = string
  default     = null
}

variable "firewall_pip_name" {
  description = "(Optional) The name of the firwall's public IP."
  default     = "firewall-pip-tf"
  type        = string
}

variable "firewall_pip_allocation_method" {
  description = "(Optional) allocation method of the firwall's public IP."
  default     = "Static"
  type        = string
}

variable "firewall_pip_sku" {
  description = "(Optional) The sku of the pip of the firewall."
  default     = "Standard"
  type        = string
}

variable "management_pip_name" {
  description = "(Optional) The name of the firwall's managment public IP. Having a management IP and a management subnet allows force-tunnelling"
  default     = "firewall-managment-pip-tf"
  type        = string
}

variable "management_pip_allocation_method" {
  description = "(Optional) Allocation method of the firwall's managment public IP."
  default     = "Static"
  type        = string
}

variable "management_pip_sku" {
  description = "(Optional) The sku of the managment pip of the firewall."
  default     = "Standard"
  type        = string
}

variable "firewall_sku_name" {
  description = "(Optional) The sku of the firewall."
  default     = "AZFW_VNet"
  type        = string
  validation {
    condition     = can(regex("^(AZFW_VNet|AZFW_Hub)$", var.firewall_sku_name))
    error_message = "Invalid sku name selected, only allowed sku names are: 'AZFW_Hub', 'AZFW_VNet'. Default 'AZFW_VNet'"
  }
}

variable "firewall_sku_tier" {
  description = "(Optional) The tier of the firewall's sku"
  default     = "Standard"
  type        = string
  validation {
    condition     = can(regex("^(Basic|Standard|Premium)$", var.firewall_sku_tier))
    error_message = "Invalid sku tier selected, only allowed values are: 'Basic', 'Standard', 'Premium'. Default 'Standard'"
  }
}

variable "ip_configuration_name" {
  description = "(Optional) The name of the ip configuration"
  default     = "firewall-ipconfig-tf"
  type        = string
}

variable "management_ip_configuration_name" {
  description = "(Optional) The name of the managment ip configuration."
  default     = "firewall-managment-ip-Config-tf"
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the firewall resource."
  type        = map(string)
  default     = {}
}

variable "dns_servers" {
  description = "(Optional) A list of DNS servers that the Azure Firewall will direct DNS traffic to the for name resolution."
  type        = list(string)
  default     = [""]
}

variable "dns_proxy_enabled" {
  description = "(optional) Whether DNS proxy is enabled. Default false, unless dns_servers provided with a not empty list."
  type        = bool
  default     = false
}

variable "threat_intel_mode" {
  description = "(Optional) The operation mode for threat intelligence-based filtering."
  type        = string
  default     = "Alert"
  validation {
    condition     = can(regex("^(Off|Alert|Deny)$", var.threat_intel_mode))
    error_message = "Invalid value, possible values are: 'Off', 'Alert' and 'Deny'. Defaults to 'Alert'."
  }
}

variable "zones" {
  description = "(Optional) Specifies a list of Availability Zones in which this Azure Firewall should be located."
  type        = list(string)
  default     = [""]
}

variable "virtual_hub_enabled" {
  description = "(Optional) Whether virtual hub is enabled."
  type        = bool
  default     = false
}

variable "virtual_hub_id" {
  description = "(Optional) Specifies the ID of the Virtual Hub where the Firewall resides in. Required if virtual_hub_enabled set to true."
  type        = string
  default     = ""
}

variable "public_ip_count" {
  description = "(Optional) Specifies the number of public IPs to assign to the Firewall. Part of the optional block 'virtual_hub'."
  type        = number
  default     = 1
}

variable "log_analytics_workspace_id" {
  description = "(Optional) ID of the log analytics workspace to which the diagnostic setting will send the logs of this resource."
  type        = string
  default     = null
}

variable "rule_collection_group_name" {
  description = "(Optional) Name for the default rule collection group of the policy."
  type        = string
  default     = "fwpolicy-rcg-tf"
}

variable "rule_collection_group_priority" {
  description = "(Optional) The priority of the default rule collection group of the policy."
  type        = number
  default     = 500
}

variable "network_rule_collections" {
  description = "(Optional) A list of objects each describing one network rule collection"
  type = list(object({
    name      = string
    priority  = number
    action    = string
    rule = map(object({
        protocols = list(string)
        source_addresses = list(string)
        destination_addresses = list(string)
        destination_ports = list(string)
    }))
  }))
  default = null
}

variable "application_rule_collections" {
  description = "(Optional) A list of objects each describing one application rule collection"
  type = list(object({
    name      = string
    priority  = number
    action    = string
    rule = map(object({
        protocols = list(object({
          type = string
          port = number
        }))
        source_addresses = list(string)
        destination_fqdns = list(string)
    }))
  }))
  default = null
}

variable "diagnostic_setting_categories" {
  description = "value"
  type = list(string)
  default = [ "AzureFirewallApplicationRule", "AzureFirewallNetworkRule", "AzureFirewallDnsProxy", "AZFWApplicationRule", "AZFWApplicationRuleAggregation", "AZFWDnsQuery", "AZFWFatFlow", "AZFWFlowTrace", "AZFWFqdnResolveFailure", "AZFWIdpsSignature", "AZFWNatRule", "AZFWNatRuleAggregation", "AZFWNetworkRule", "AZFWNetworkRuleAggregation", "AZFWThreatIntel", "AzureFirewallApplicationRule", "AzureFirewallDnsProxy", "AzureFirewallNetworkRule" ]
}
