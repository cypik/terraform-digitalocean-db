provider "digitalocean" {}


module "vpc" {
  source      = "cypik/vpc/digitalocean"
  version     = "1.0.1"
  name        = "app"
  environment = "test"
  region      = "blr1"

  ip_range = "10.31.0.0/24"
}


module "mysql" {
  source             = "../../"
  name               = "app"
  environment        = "test"
  region             = "blr1"
  cluster_engine     = "mysql"
  cluster_version    = "8"
  cluster_size       = "db-s-1vcpu-1gb"
  cluster_node_count = 1

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

  create_firewall = false
  firewall_rules = [
    {
      type  = "ip_addr"
      value = "0.0.0.0"
    }
  ]
}
