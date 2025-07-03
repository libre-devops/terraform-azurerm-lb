# Azure Load Balancer Terraform Module

This Terraform module creates and manages Azure Load Balancers and their associated resources.

## Features

- Create multiple Azure Load Balancers
- Configure frontend IP configurations
- Create backend address pools
- Set up NAT pools and rules
- Configure outbound rules
- Define load balancer rules

## Usage

```hcl
module "load_balancer" {
  source = "github.com/your-org/terraform-azurerm-lb"

  lbs = [
    {
      name     = "example-lb"
      rg_name  = "example-rg"
      location = "uksouth"
      tags     = { Environment = "Production" }
      sku      = "Standard"
      sku_tier = "Regional"

      frontend_ip_configuration = [
        {
          name                          = "frontend-ip"
          zones                         = [1, 2, 3]
          public_ip_address_id          = azurerm_public_ip.example.id
          private_ip_address_allocation = "Dynamic"
        }
      ]

      backend_address_pools = [
        {
          name = "backend-pool"
        }
      ]

      lb_rules = [
        {
          name          = "http"
          protocol      = "Tcp"
          frontend_port = 80
          backend_port  = 80
        }
      ]
    }
  ]
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
