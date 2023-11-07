provider "digitalocean" {}



module "vpc" {
  source      = "git::https://github.com/opz0/terraform-digitalocean-vpc.git?ref=v1.0.0"
  name        = "app"
  environment = "test"
  region      = "blr1"
  ip_range    = "10.20.0.0/24"
}

module "mongodb" {
  source                       = "../../"
  name                         = "app"
  environment                  = "test"
  region                       = "blr1"
  cluster_engine               = "mongodb"
  cluster_version              = "6"
  cluster_size                 = "db-s-1vcpu-1gb"
  cluster_node_count           = 1
  cluster_private_network_uuid = module.vpc.id
  cluster_maintenance = {
    maintenance_hour = "02:00:00"
    maintenance_day  = "saturday"
  }
  databases = ["testdb"]
  users = [
    {
      name = "test"
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
