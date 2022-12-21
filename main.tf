locals {
  prefix = "MyOrg"
  default_tags = {
    Project  = ""
    Solution = ""
  }
}

module "connectivity_rg" {
  source   = "../terraform-azure-alz-resource-group"
  name     = "${local.prefix}-Connectivity"
  location = "uksouth"
  tags     = local.default_tags
  providers = {
    azurerm = azurerm
  }
}

resource "azurerm_virtual_wan" "vwan" {
  name                           = "${local.prefix}-VWAN-01"
  resource_group_name            = module.connectivity_rg.name
  location                       = "uksouth"
  allow_branch_to_branch_traffic = true
  type                           = "Standard"
  tags                           = local.default_tags
}

resource "azurerm_firewall_policy" "policy" {
  name                = "main"
  resource_group_name = module.connectivity_rg.name
  location            = "uksouth"
  tags                = local.default_tags
}

module "secure_virtual_hub_uksouth" {
  source              = "../terraform-azure-alz-secure-vhub"
  resource_group_name = module.connectivity_rg.name
  location            = "uksouth"
  wan_id              = azurerm_virtual_wan.vwan.id
  prefix              = "10.122.0.0/22"
  firewall_policy_id  = azurerm_firewall_policy.policy.id
  tags                = local.default_tags
}

module "secure_virtual_hub_ukwest" {
  source              = "../terraform-azure-alz-secure-vhub"
  resource_group_name = module.connectivity_rg.name
  location            = "ukwest"
  wan_id              = azurerm_virtual_wan.vwan.id
  prefix              = "10.122.4.0/22"
  firewall_policy_id  = azurerm_firewall_policy.policy.id
  tags                = local.default_tags
}