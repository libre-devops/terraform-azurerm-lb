variable "lbs" {
  description = "A list of LBs to make"
  type = list(object({
    name      = string
    rg_name   = string
    location  = optional(string, "uksouth")
    tags      = map(string)
    edge_zone = optional(string)
    frontend_ip_configuration = optional(list(object({
      name                                               = optional(string)
      zones                                              = list(number)
      subnet_id                                          = optional(string)
      gateway_load_balancer_frontend_ip_configuration_id = optional(string)
      private_ip_address                                 = optional(string)
      private_ip_address_allocation                      = optional(string, "Dynamic")
      private_ip_address_version                         = optional(string, "IPv4")
      public_ip_address_id                               = optional(string)
      public_ip_prefix_id                                = optional(string)
    })))
    sku      = optional(string, "Standard")
    sku_tier = optional(string, "Regional")
    backend_address_pools = optional(list(object({
      name               = optional(string)
      virtual_network_id = optional(string)
      loadbalancer_id    = optional(string)
      synchronous_mode   = optional(string)
      tunnel_interface = optional(list(object({
        identifier = string
        type       = optional(string)
        protocol   = optional(string)
        port       = number
      })))
    })))
    nat_pools = optional(list(object({
      name                           = optional(string)
      protocol                       = string
      frontend_port_start            = number
      frontend_port_end              = number
      backend_port                   = number
      frontend_ip_configuration_name = optional(string)
      idle_timeout_in_minutes        = optional(number)
      floating_ip_enabled            = optional(bool)
      tcp_reset_enabled              = optional(bool)
    })))
    nat_rules = optional(list(object({
      name                           = optional(string)
      protocol                       = optional(string, "Tcp")
      frontend_port                  = optional(number)
      frontend_port_start            = optional(number)
      frontend_port_end              = optional(number)
      backend_port                   = number
      frontend_ip_configuration_name = optional(string)
      backend_address_pool_id        = optional(string)
      idle_timeout_in_minutes        = optional(number)
      enable_tcp_reset               = optional(bool)
      enable_floating_ip             = optional(bool)
    })))
    outbound_rules = optional(list(object({
      name                       = optional(string)
      protocol                   = string
      backend_address_pool_id    = optional(string)
      associate_backend_pool_key = optional(string)
      frontend_ip_configuration = optional(list(object({
        name = string
      })))
      enable_tcp_reset         = optional(bool)
      allocated_outbound_ports = optional(number, 1024)
      idle_timeout_in_minutes  = optional(number, 4)
    })))
    lb_rules = optional(list(object({
      name                           = optional(string)
      protocol                       = string
      frontend_port                  = number
      backend_port                   = number
      associate_backend_pool_key     = optional(string)
      backend_address_pool_ids       = optional(list(string))
      probe_id                       = optional(string)
      frontend_ip_configuration_name = optional(string)
      enable_floating_ip             = optional(bool)
      idle_timeout_in_minutes        = optional(number)
      load_distribution              = optional(string)
      disable_outbound_snat          = optional(bool)
      enable_tcp_reset               = optional(bool)
    })))
  }))
}
