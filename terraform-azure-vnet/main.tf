resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.sandeepspace
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  delegation {
    name = "delegation"
    service_delegation {
      name = each.value.delegation_name
      actions = each.value.delegation_actions
    }
  }

  service_endpoints = each.value.service_endpoints
}

resource "azurerm_network_security_group" "this" {
  count = var.enable_nsg ? 1 : 0

  name                = "${var.vnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  for_each = var.enable_nsg ? { for s in var.subnets : s.name => s } : {}

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[0].id
}
