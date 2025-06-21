```hcl
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

  name               = each.value.pool.name != null ? each.value.pool.name : "bepool-${each.value.lb_name}"
  loadbalancer_id    = azurerm_lb.this[each.value.lb_name].id
  synchronous_mode   = (each.value.pool.virtual_network_id != null ? coalesce(each.value.pool.synchronous_mode, "Automatic") : null)
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

###############################################################################
# NAT POOL                                                                   #
###############################################################################
resource "azurerm_lb_nat_pool" "this" {
  for_each = local.lb_nat_pools_map

  name                = coalesce(each.value.pool.name, "natpool-${each.value.lb_name}")
  resource_group_name = azurerm_lb.this[each.value.lb_name].resource_group_name
  loadbalancer_id     = azurerm_lb.this[each.value.lb_name].id

  protocol            = title(each.value.pool.protocol)
  frontend_port_start = each.value.pool.frontend_port_start
  frontend_port_end   = each.value.pool.frontend_port_end
  backend_port        = each.value.pool.backend_port

  frontend_ip_configuration_name = coalesce(
    each.value.pool.frontend_ip_configuration_name,
    azurerm_lb.this[each.value.lb_name].frontend_ip_configuration[0].name
  )

  idle_timeout_in_minutes = each.value.pool.idle_timeout_in_minutes
  floating_ip_enabled     = each.value.pool.floating_ip_enabled
  tcp_reset_enabled       = each.value.pool.tcp_reset_enabled
}

###############################################################################
# NAT RULE                                                                   #
###############################################################################
resource "azurerm_lb_nat_rule" "this" {
  for_each = local.lb_nat_rules_map

  loadbalancer_id     = azurerm_lb.this[each.value.lb_name].id
  resource_group_name = azurerm_lb.this[each.value.lb_name].resource_group_name

  name         = coalesce(each.value.rule.name, "natrule-${each.value.lb_name}-${replace(each.key, "/.*_/", "")}")
  protocol     = each.value.rule.protocol
  backend_port = each.value.rule.backend_port

  frontend_port       = try(each.value.rule.frontend_port, null)
  frontend_port_start = try(each.value.rule.frontend_port_start, null)
  frontend_port_end   = try(each.value.rule.frontend_port_end, null)

  frontend_ip_configuration_name = coalesce(
    each.value.rule.frontend_ip_configuration_name,
    azurerm_lb.this[each.value.lb_name].frontend_ip_configuration[0].name
  )

  backend_address_pool_id = coalesce(
    each.value.rule.backend_address_pool_id,
    try(azurerm_lb_backend_address_pool.this[each.value.rule.associate_backend_pool_key].id, null),
    try(values({
      for k, v in azurerm_lb_backend_address_pool.this :
      k => v.id if v.loadbalancer_id == azurerm_lb.this[each.value.lb_name].id
    })[0], null)
  )

  enable_floating_ip      = try(each.value.rule.enable_floating_ip, null)
  enable_tcp_reset        = try(each.value.rule.enable_tcp_reset, null)
  idle_timeout_in_minutes = try(each.value.rule.idle_timeout_in_minutes, null)
}


resource "azurerm_lb_outbound_rule" "this" {
  for_each = local.lb_ob_rules_map

  name            = coalesce(each.value.rule.name, "obr-${each.value.lb_name}-${replace(each.key, "/.*_/", "")}")
  loadbalancer_id = azurerm_lb.this[each.value.lb_name].id
  protocol        = each.value.rule.protocol


  backend_address_pool_id = coalesce(
    each.value.rule.backend_address_pool_id,
    try(azurerm_lb_backend_address_pool.this[each.value.rule.associate_backend_pool_key].id, null),
    try( # fall-back: “whatever pool belongs to this LB – first one”
      values({
        for k, v in azurerm_lb_backend_address_pool.this :
        k => v.id if v.loadbalancer_id == azurerm_lb.this[each.value.lb_name].id
      })[0],
    null)
  )

  enable_tcp_reset         = try(each.value.rule.enable_tcp_reset, null)
  allocated_outbound_ports = try(each.value.rule.allocated_outbound_ports, null)
  idle_timeout_in_minutes  = try(each.value.rule.idle_timeout_in_minutes, null)

  dynamic "frontend_ip_configuration" {
    for_each = coalesce(
      each.value.rule.frontend_ip_configuration,
      [{ name = azurerm_lb.this[each.value.lb_name].frontend_ip_configuration[0].name }]
    )
    content {
      name = frontend_ip_configuration.value.name
    }
  }
}

resource "azurerm_lb_rule" "this" {
  for_each        = local.lb_rules_map
  loadbalancer_id = azurerm_lb.this[each.value.lb_name].id

  name          = coalesce(each.value.rule.name, "lbrule-${each.value.lb_name}-${each.value.rule_index}")
  protocol      = each.value.rule.protocol
  frontend_port = each.value.rule.frontend_port
  backend_port  = each.value.rule.backend_port
  frontend_ip_configuration_name = coalesce(
    each.value.rule.frontend_ip_configuration_name,
    azurerm_lb.this[each.value.lb_name].frontend_ip_configuration[0].name
  )

  backend_address_pool_ids = compact(concat(
    # 1) caller-supplied list (may be null)
    coalesce(each.value.rule.backend_address_pool_ids, []),

    [
      try(
        azurerm_lb_backend_address_pool.this[
          each.value.rule.associate_backend_pool_key
        ].id,
        ""
      )
    ],

    [
      try(
        values({
          for k, v in azurerm_lb_backend_address_pool.this :
          k => v.id if v.loadbalancer_id == azurerm_lb.this[each.value.lb_name].id
        })[0],
        ""
      )
    ]
  ))


  probe_id                = try(each.value.rule.probe_id, null)
  enable_floating_ip      = try(each.value.rule.enable_floating_ip, null)
  idle_timeout_in_minutes = try(each.value.rule.idle_timeout_in_minutes, null)
  load_distribution       = try(each.value.rule.load_distribution, null)
  disable_outbound_snat   = try(each.value.rule.disable_outbound_snat, null)
  enable_tcp_reset        = try(each.value.rule.enable_tcp_reset, null)
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_lb.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_nat_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_nat_pool) | resource |
| [azurerm_lb_nat_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_nat_rule) | resource |
| [azurerm_lb_outbound_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_outbound_rule) | resource |
| [azurerm_lb_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_lbs"></a> [lbs](#input\_lbs) | A list of LBs to make | <pre>list(object({<br/>    name      = string<br/>    rg_name   = string<br/>    location  = optional(string, "uksouth")<br/>    tags      = map(string)<br/>    edge_zone = optional(string)<br/>    frontend_ip_configuration = optional(list(object({<br/>      name                                               = optional(string)<br/>      zones                                              = list(number)<br/>      subnet_id                                          = optional(string)<br/>      gateway_load_balancer_frontend_ip_configuration_id = optional(string)<br/>      private_ip_address                                 = optional(string)<br/>      private_ip_address_allocation                      = optional(string, "Dynamic")<br/>      private_ip_address_version                         = optional(string, "IPv4")<br/>      public_ip_address_id                               = optional(string)<br/>      public_ip_prefix_id                                = optional(string)<br/>    })))<br/>    sku      = optional(string, "Standard")<br/>    sku_tier = optional(string, "Regional")<br/>    backend_address_pools = optional(list(object({<br/>      name               = optional(string)<br/>      virtual_network_id = optional(string)<br/>      loadbalancer_id    = optional(string)<br/>      synchronous_mode   = optional(string)<br/>      tunnel_interface = optional(list(object({<br/>        identifier = string<br/>        type       = optional(string)<br/>        protocol   = optional(string)<br/>        port       = number<br/>      })))<br/>    })))<br/>    nat_pools = optional(list(object({<br/>      name                           = optional(string)<br/>      protocol                       = string<br/>      frontend_port_start            = number<br/>      frontend_port_end              = number<br/>      backend_port                   = number<br/>      frontend_ip_configuration_name = optional(string)<br/>      idle_timeout_in_minutes        = optional(number)<br/>      floating_ip_enabled            = optional(bool)<br/>      tcp_reset_enabled              = optional(bool)<br/>    })))<br/>    nat_rules = optional(list(object({<br/>      name                           = optional(string)<br/>      protocol                       = optional(string, "Tcp")<br/>      frontend_port                  = optional(number)<br/>      frontend_port_start            = optional(number)<br/>      frontend_port_end              = optional(number)<br/>      backend_port                   = number<br/>      frontend_ip_configuration_name = optional(string)<br/>      backend_address_pool_id        = optional(string)<br/>      idle_timeout_in_minutes        = optional(number)<br/>      enable_tcp_reset               = optional(bool)<br/>      enable_floating_ip             = optional(bool)<br/>    })))<br/>    outbound_rules = optional(list(object({<br/>      name                       = optional(string)<br/>      protocol                   = string<br/>      backend_address_pool_id    = optional(string)<br/>      associate_backend_pool_key = optional(string)<br/>      frontend_ip_configuration = optional(list(object({<br/>        name = string<br/>      })))<br/>      enable_tcp_reset         = optional(bool)<br/>      allocated_outbound_ports = optional(number, 1024)<br/>      idle_timeout_in_minutes  = optional(number, 4)<br/>    })))<br/>    lb_rules = optional(list(object({<br/>      name                           = optional(string)<br/>      protocol                       = string<br/>      frontend_port                  = number<br/>      backend_port                   = number<br/>      associate_backend_pool_key     = optional(string)<br/>      backend_address_pool_ids       = optional(list(string))<br/>      probe_id                       = optional(string)<br/>      frontend_ip_configuration_name = optional(string)<br/>      enable_floating_ip             = optional(bool)<br/>      idle_timeout_in_minutes        = optional(number)<br/>      load_distribution              = optional(string)<br/>      disable_outbound_snat          = optional(bool)<br/>      enable_tcp_reset               = optional(bool)<br/>    })))<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_backend_address_pool_backend_ip_configurations"></a> [lb\_backend\_address\_pool\_backend\_ip\_configurations](#output\_lb\_backend\_address\_pool\_backend\_ip\_configurations) | Map of <lb>\_<pool> ΓåÆ list of Backend IP Configuration IDs. |
| <a name="output_lb_backend_address_pool_inbound_nat_rules"></a> [lb\_backend\_address\_pool\_inbound\_nat\_rules](#output\_lb\_backend\_address\_pool\_inbound\_nat\_rules) | Map of <lb>\_<pool> ΓåÆ list of Inbound NAT Rule IDs. |
| <a name="output_lb_backend_address_pool_load_balancing_rules"></a> [lb\_backend\_address\_pool\_load\_balancing\_rules](#output\_lb\_backend\_address\_pool\_load\_balancing\_rules) | Map of <lb>\_<pool> ΓåÆ list of Load-Balancing Rule IDs. |
| <a name="output_lb_backend_address_pool_outbound_rules"></a> [lb\_backend\_address\_pool\_outbound\_rules](#output\_lb\_backend\_address\_pool\_outbound\_rules) | Map of <lb>\_<pool> ΓåÆ list of Outbound Rule IDs. |
| <a name="output_lb_frontend_ip_configuration"></a> [lb\_frontend\_ip\_configuration](#output\_lb\_frontend\_ip\_configuration) | Flattened view of every frontend\_ip\_configuration on every Load Balancer,<br/>including all attributes exported by the provider. |
| <a name="output_lb_id"></a> [lb\_id](#output\_lb\_id) | Load Balancer resource IDs. |
| <a name="output_lb_name"></a> [lb\_name](#output\_lb\_name) | Load Balancer names. |
| <a name="output_lb_nat_rule_ids"></a> [lb\_nat\_rule\_ids](#output\_lb\_nat\_rule\_ids) | Map of <lb>\_<rule> ΓåÆ NAT-rule ID. |
| <a name="output_lb_nat_rule_names"></a> [lb\_nat\_rule\_names](#output\_lb\_nat\_rule\_names) | Map of <lb>\_<rule> ΓåÆ NAT-rule name. |
| <a name="output_lb_private_ip_address"></a> [lb\_private\_ip\_address](#output\_lb\_private\_ip\_address) | First private IP address on each Load Balancer (first frontend config only). |
| <a name="output_lb_private_ip_addresses"></a> [lb\_private\_ip\_addresses](#output\_lb\_private\_ip\_addresses) | List of all private IPs (across all frontend configs) on each Load Balancer. |
| <a name="output_lb_rule_ids"></a> [lb\_rule\_ids](#output\_lb\_rule\_ids) | Map of <lb>\_<ruleIndex> ΓåÆ azurerm\_lb\_rule ID. |
| <a name="output_lb_rule_names"></a> [lb\_rule\_names](#output\_lb\_rule\_names) | Map of <lb>\_<ruleIndex> ΓåÆ azurerm\_lb\_rule name. |
