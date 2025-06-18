locals {
  lb_backend_pool_list = flatten([
    for lb_index, lb in var.lbs : [
      for pool_index, pool in (
        lb.backend_address_pools != null ? lb.backend_address_pools : []
      ) : {
        lb_index    = lb_index        # which LB are we in?
        pool_index  = pool_index      # position inside that LB’s list

        lb_name     = lb.name
        rg_name     = lb.rg_name

        pool        = pool
      }
    ]
  ])

  lb_pools_map = {
    for item in local.lb_backend_pool_list :
    "${item.lb_index}_${item.pool_index}" => item
  }


  lb_nat_pools_flat = flatten([
    for lb in var.lbs : [
      for np in coalesce(lb.nat_pools, []) : {
        composite_key = "${lb.name}_${np.name != null ? np.name : uuid()}" # map key
        lb_name       = lb.name
        rg_name       = lb.rg_name
        pool          = np
      }
    ]
  ])

  lb_nat_pools_map = {
    for p in local.lb_nat_pools_flat : p.composite_key => p
  }
}

