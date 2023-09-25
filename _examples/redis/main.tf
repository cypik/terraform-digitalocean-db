provider "digitalocean" {}

locals {
  name        = "app"
  environment = "test"
  region      = "blr1"
}

module "vpc" {
  source      = "git@github.com:opz0/terraform-digitalocean-vpc.git"
  name        = local.name
  environment = local.environment
  region      = local.region
  ip_range    = "10.20.0.0/24"
}

module "redis" {
  source                       = "../../"
  name                         = local.name
  environment                  = local.environment
  region                       = local.region
  cluster_engine               = "redis"
  cluster_version              = "6"
  cluster_size                 = "db-s-1vcpu-1gb"
  cluster_node_count           = 1
  cluster_private_network_uuid = module.vpc.id
  redis_eviction_policy        = "volatile_lru"
  cluster_maintenance = {
    maintenance_hour = "02:00:00"
    maintenance_day  = "saturday"
  }
  create_firewall = false
  firewall_rules = [
    {
      type  = "ip_addr"
      value = "192.168.1.1"
    }
  ]
}
