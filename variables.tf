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
      name             = optional(string)
      virtual_network_id = optional(string)
      loadbalancer_id = optional(string)
      synchronous_mode = optional(string)
      tunnel_interface = optional(list(object({
        identifier = string
        type = optional(string)
        protocol = optional(string)
        port = number
      })))
    })))
    nat_pools = optional(list(object({
      name                            = optional(string)
      protocol                        = string
      frontend_port_start             = number
      frontend_port_end               = number
      backend_port                    = number
      frontend_ip_configuration_name  = optional(string)
      idle_timeout_in_minutes         = optional(number)
      floating_ip_enabled = optional(bool)
      tcp_reset_enabled = optional(bool)
    })))
  }))
}
