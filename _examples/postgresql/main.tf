provider "digitalocean" {}

locals {
  name        = "app"
  environment = "test"
  region      = "blr1"
}

module "vpc" {
  source      = "cypik/vpc/digitalocean"
  version     = "1.0.2"
  name        = local.name
  environment = local.environment
  region      = local.region
  ip_range    = "10.11.0.0/24"
}

module "postgresql" {
  source                       = "./../../"
  name                         = local.name
  environment                  = local.environment
  region                       = local.region
  cluster_engine               = "pg"
  cluster_version              = "15"
  cluster_size                 = "db-s-1vcpu-1gb"
  cluster_node_count           = 1
  cluster_private_network_uuid = module.vpc.id
  cluster_maintenance = {
    maintenance_hour = "02:00:00"
    maintenance_day  = "saturday"
  }
  databases = ["testdbt"]
  users = [
    {
      name = "test"
    }
  ]

  create_pools = true
  pools = [
    {
      name    = "test",
      mode    = "transaction",
      size    = 10,
      db_name = "defaultdb",
      user    = "doadmin"
    }
  ]

  create_firewall = false
  firewall_rules = [
    {
      type  = "ip_addr"
      value = "0.0.0.0"
    }
  ]
}
