provider "digitalocean" {}

locals {
  name        = "app"
  environment = "test"
  region      = "blr1"
}
module "vpc" {
  source      = "git::https://github.com/cypik/terraform-digitalocean-vpc.git?ref=v1.0.0"
  name        = local.name
  environment = local.environment
  region      = local.region
  ip_range    = "10.20.0.0/24"
}

module "mysql" {
  source                       = "../../"
  name                         = local.name
  environment                  = local.environment
  region                       = local.region
  cluster_engine               = "mysql"
  cluster_version              = "8"
  cluster_size                 = "db-s-1vcpu-1gb"
  cluster_node_count           = 1
  cluster_private_network_uuid = module.vpc.id
  mysql_sql_mode               = "ANSI,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,STRICT_ALL_TABLES,ALLOW_INVALID_DATES"
  cluster_maintenance = {
    maintenance_hour = "02:00:00"
    maintenance_day  = "saturday"
  }
  databases = ["testdb", "testdbt"]

  users = [
    {
      name              = "test1",
      mysql_auth_plugin = "mysql_native_password"
    }
  ]


  create_firewall = true
  firewall_rules = [
    {
      type  = "ip_addr"
      value = "0.0.0.0"
    }
  ]
}
