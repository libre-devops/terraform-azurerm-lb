###############################################################################
# Locals                                                                     #
###############################################################################
locals {
  # ────────────────────────────── backend pools ─────────────────────────────
  lb_backend_pool_list = flatten([
    for lb_index, lb in var.lbs : [
      for pool_index, pool in coalesce(lb.backend_address_pools, []) : {
        lb_index   = lb_index   # which LB
        pool_index = pool_index # position in that LB

        lb_name = lb.name
        rg_name = lb.rg_name
        pool    = pool
      }
    ]
  ])

  lb_pools_map = {
    for item in local.lb_backend_pool_list :
    "${item.lb_index}_${item.pool_index}" => item
  }

  # ──────────────────────────────── NAT POOLS ──────────────────────────────
  lb_nat_pools_flat = flatten([
    for lb_index, lb in var.lbs : [
      for np_index, np in coalesce(lb.nat_pools, []) : {
        composite_key = "${lb.name}_${np_index}"
        lb_name       = lb.name
        rg_name       = lb.rg_name
        pool          = np
      }
    ]
  ])

  lb_nat_pools_map = {
    for p in local.lb_nat_pools_flat : p.composite_key => p
  }

  # ──────────────────────────────── NAT RULES ──────────────────────────────
  lb_nat_rules_flat = flatten([
    for lb_index, lb in var.lbs : [
      for nr_index, nr in coalesce(lb.nat_rules, []) : {
        composite_key = "${lb.name}_${nr_index}"
        lb_name       = lb.name
        rg_name       = lb.rg_name
        rule          = nr
      }
    ]
  ])

  lb_nat_rules_map = {
    for r in local.lb_nat_rules_flat : r.composite_key => r
  }

  lb_ob_rules_flat = flatten([
    for lb in var.lbs : [
      for obr in coalesce(lb.outbound_rules, []) : {
        composite_key = "${lb.name}_${obr.name != null ? obr.name : uuid()}"
        lb_name       = lb.name
        rg_name       = lb.rg_name
        rule          = obr
      }
    ]
  ])

  lb_ob_rules_map = {
    for r in local.lb_ob_rules_flat : r.composite_key => r
  }

  lb_rules_flat = flatten([
    for lb_index, lb in var.lbs : [
      for rule_index, r in coalesce(lb.lb_rules, []) : {
        composite_key = "${lb.name}_${coalesce(r.name, uuid())}"
        lb_index      = lb_index
        lb_name       = lb.name
        rg_name       = lb.rg_name
        rule_index    = rule_index
        rule          = r
      }
    ]
  ])

  lb_rules_map = {
    for r in local.lb_rules_flat : r.composite_key => r
  }
}
