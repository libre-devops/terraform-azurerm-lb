output "lb_backend_address_pool_backend_ip_configurations" {
  description = "Map of <lb>_<pool> → list of Backend IP Configuration IDs."
  value = {
    for k, v in azurerm_lb_backend_address_pool.this :
    k => v.backend_ip_configurations
  }
}

output "lb_backend_address_pool_inbound_nat_rules" {
  description = "Map of <lb>_<pool> → list of Inbound NAT Rule IDs."
  value = {
    for k, v in azurerm_lb_backend_address_pool.this :
    k => v.inbound_nat_rules
  }
}

output "lb_backend_address_pool_load_balancing_rules" {
  description = "Map of <lb>_<pool> → list of Load-Balancing Rule IDs."
  value = {
    for k, v in azurerm_lb_backend_address_pool.this :
    k => v.load_balancing_rules
  }
}

output "lb_backend_address_pool_outbound_rules" {
  description = "Map of <lb>_<pool> → list of Outbound Rule IDs."
  value = {
    for k, v in azurerm_lb_backend_address_pool.this :
    k => v.outbound_rules
  }
}

output "lb_frontend_ip_configuration" {
  description = <<DESC
Flattened view of every frontend_ip_configuration on every Load Balancer,
including all attributes exported by the provider.
DESC

  value = {
    for k, v in azurerm_lb.this :
    k => [
      for cfg in v.frontend_ip_configuration : {
        id                                                 = cfg.id
        gateway_load_balancer_frontend_ip_configuration_id = try(cfg.gateway_load_balancer_frontend_ip_configuration_id, null)
        inbound_nat_rules                                  = cfg.inbound_nat_rules
        load_balancer_rules                                = cfg.load_balancer_rules
        outbound_rules                                     = cfg.outbound_rules
        private_ip_address                                 = cfg.private_ip_address
        private_ip_address_allocation                      = cfg.private_ip_address_allocation
        public_ip_address_id                               = cfg.public_ip_address_id
        public_ip_prefix_id                                = cfg.public_ip_prefix_id
        subnet_id                                          = cfg.subnet_id
      }
    ]
  }
}

output "lb_id" {
  description = "Load Balancer resource IDs."
  value       = { for k, v in azurerm_lb.this : k => v.id }
}

output "lb_name" {
  description = "Load Balancer names."
  value       = { for k, v in azurerm_lb.this : k => v.name }
}

output "lb_nat_rule_ids" {
  description = "Map of <lb>_<rule> → NAT-rule ID."
  value       = { for k, v in azurerm_lb_nat_rule.this : k => v.id }
}

output "lb_nat_rule_names" {
  description = "Map of <lb>_<rule> → NAT-rule name."
  value       = { for k, v in azurerm_lb_nat_rule.this : k => v.name }
}

output "lb_private_ip_address" {
  description = "First private IP address on each Load Balancer (first frontend config only)."
  value       = { for k, v in azurerm_lb.this : k => v.private_ip_address }
}

output "lb_private_ip_addresses" {
  description = "List of all private IPs (across all frontend configs) on each Load Balancer."
  value       = { for k, v in azurerm_lb.this : k => v.private_ip_addresses }
}

output "lb_rule_ids" {
  description = "Map of <lb>_<ruleIndex> → azurerm_lb_rule ID."
  value       = { for k, v in azurerm_lb_rule.this : k => v.id }
}

output "lb_rule_names" {
  description = "Map of <lb>_<ruleIndex> → azurerm_lb_rule name."
  value       = { for k, v in azurerm_lb_rule.this : k => v.name }
}
