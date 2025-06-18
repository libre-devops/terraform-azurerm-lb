resource "azurerm_lb" "this" {
  for_each = { for lb in var.lbs : lb.name => lb }

  location            = each.value.location
  name                = each.value.name
  resource_group_name = each.value.rg_name
  tags                = each.value.tags
  sku_tier            = each.value.sku_tier
  sku                 = each.value.sku

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configuration != null ? each.value.frontend_ip_configuration : []
    content {
      name                                               = frontend_ip_configuration.value.name != null ? frontend_ip_configuration.value.name : "frontend-ipconfig-${each.value.name}"
      zones                                              = frontend_ip_configuration.value.zones
      subnet_id                                          = frontend_ip_configuration.value.subnet_id
      gateway_load_balancer_frontend_ip_configuration_id = frontend_ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_id
      private_ip_address                                 = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation                      = frontend_ip_configuration.value.private_ip_address_allocation
      private_ip_address_version                         = frontend_ip_configuration.value.private_ip_address_version
      public_ip_address_id                               = frontend_ip_configuration.value.public_ip_address_id
      public_ip_prefix_id                                = frontend_ip_configuration.value.public_ip_prefix_id
    }
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  for_each = local.lb_pools_map

  name            = each.value.pool.name != null ? each.value.pool.name : "bepool-${each.value.lb_name}"
  loadbalancer_id = azurerm_lb.this[each.value.lb_name].id
  synchronous_mode = (each.value.pool.virtual_network_id != null ? coalesce(each.value.pool.synchronous_mode, "Automatic") : null)
  virtual_network_id = each.value.pool.virtual_network_id

  dynamic "tunnel_interface" {
    for_each = each.value.pool.tunnel_interface != null ? each.value.pool.tunnel_interface : []
    content {
      identifier = tunnel_interface.value.identifier
      type       = tunnel_interface.value.type
      protocol   = tunnel_interface.value.protocol
      port       = tunnel_interface.value.port
    }
  }
}

resource "azurerm_lb_nat_pool" "this" {
  for_each = local.lb_nat_pools_map

  name            = each.value.pool.name != null ? each.value.pool.name : "natpool-${each.value.lb_name}"
  loadbalancer_id = azurerm_lb.this[each.value.lb_name].id

  protocol                       = title(each.value.pool.protocol)
  frontend_port_start            = each.value.pool.frontend_port_start
  frontend_port_end              = each.value.pool.frontend_port_end
  backend_port                   = each.value.pool.backend_port
  frontend_ip_configuration_name = try(each.value.pool.frontend_ip_configuration_name, azurerm_lb.this[each.value.lb_name].frontend_ip_configuration[0].name)
  idle_timeout_in_minutes = each.value.pool.idle_timeout_in_minutes
  floating_ip_enabled = each.value.pool.floating_ip_enabled
  tcp_reset_enabled = each.value.pool.tcp_reset_enabled
}