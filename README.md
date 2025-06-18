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
      name                                               = frontend_ip_configuration.value.name != null ? frontend_ip_configuration.value.name : "ipconfig-${each.value.name}"
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_lbs"></a> [lbs](#input\_lbs) | A list of LBs to make | <pre>list(object({<br/>    name      = string<br/>    rg_name   = string<br/>    location  = optional(string, "uksouth")<br/>    tags      = map(string)<br/>    edge_zone = optional(string)<br/>    frontend_ip_configuration = optional(list(object({<br/>      name                                               = optional(string)<br/>      zones                                              = list(number)<br/>      subnet_id                                          = optional(string)<br/>      gateway_load_balancer_frontend_ip_configuration_id = optional(string)<br/>      private_ip_address                                 = optional(string)<br/>      private_ip_address_allocation                      = optional(string)<br/>      private_ip_address_version                         = optional(string, "IPv4")<br/>      public_ip_address_id                               = optional(string)<br/>      public_ip_prefix_id                                = optional(string)<br/>    })))<br/>    sku      = optional(string, "Standard")<br/>    sku_tier = optional(string, "Regional")<br/>    backend_address_pools = optional(list(object({<br/>      name             = string<br/>      load_balancer_id = optional(string)<br/>      synchronous_mode = optional(string)<br/>    })))<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_frontend_ip_configuration"></a> [lb\_frontend\_ip\_configuration](#output\_lb\_frontend\_ip\_configuration) | Flattened view of every frontend\_ip\_configuration on every Load Balancer,<br/>including all attributes exported by the provider. |
| <a name="output_lb_id"></a> [lb\_id](#output\_lb\_id) | Load Balancer resource IDs. |
| <a name="output_lb_name"></a> [lb\_name](#output\_lb\_name) | Load Balancer names. |
| <a name="output_lb_private_ip_address"></a> [lb\_private\_ip\_address](#output\_lb\_private\_ip\_address) | First private IP address on each Load Balancer (first frontend config only). |
| <a name="output_lb_private_ip_addresses"></a> [lb\_private\_ip\_addresses](#output\_lb\_private\_ip\_addresses) | List of all private IPs (across all frontend configs) on each Load Balancer. |
