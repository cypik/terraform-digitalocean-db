# terraform-digitalocean-db
# DigitalOcean Terraform Configuration

## Table of Contents

- [Introduction](#introduction)
- [Usage](#usage)
- [Module Inputs](#module-inputs)
- [Module Outputs](#module-outputs)
- [Examples](#examples)
- [License](#license)

## Introduction
This Terraform configuration is designed to create and manage a DigitalOcean DB.

## Usage
To use this module, you should have Terraform installed and configured for DIGITALOCEAN. This module provides the necessary Terraform configuration for creating DIGITALOCEAN resources, and you can customize the inputs as needed. Below is an example of how to use this module:
# Examples
You can use this module in your Terraform configuration like this:

#  Example: mongodb

```hcl

module "mongodb" {
  source                       = "git::https://github.com/opz0/terraform-digitalocean-db.git?ref=v1.0.0"
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
```
Please replace "your_database_cluster_id" with the actual ID of your DigitalOcean DB, and adjust the db rules as needed.


# Example: mysql
```hcl
module "mysql" {
  source             = "git::https://github.com/opz0/terraform-digitalocean-db.git?ref=v1.0.0"
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
```

# Example: postgresql
```hcl
module "postgresql" {
  source                       = "git::https://github.com/opz0/terraform-digitalocean-db.git?ref=v1.0.0"
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
  databases = ["testdb"]
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
      db_name = "testdb",
      user    = "test"
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
```

# Example: redis
```hcl
module "redis" {
  source                       = "git::https://github.com/opz0/terraform-digitalocean-db.git?ref=v1.0.0"
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
```

# Example: replica-db
```hcl
module "mysql" {
  source                       = "git::https://github.com/opz0/terraform-digitalocean-db.git?ref=v1.0.0"
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
```
This example demonstrates how to create various DIGITALOCEAN resources using the provided modules. Adjust the input values to suit your specific requirements.


## Module Inputs

- 'name': The name of the database cluster.
- 'region' : DigitalOcean region where the cluster will reside.
- 'cluster_engine' : Database engine used by the cluster (ex. pg for PostreSQL,
- 'cluster_version' : Engine version used by the cluster (ex. 14 for PostgreSQL 14). When this value is changed, a call to the Upgrade major Version for a Database API operation is made with the new version.
- 'cluster_size' : Database Droplet size associated with the cluster (ex. db-s-1vcpu-1gb). See here for a list of valid size slugs.
- 'cluster_node_count' : Number of nodes that will be included in the cluster. For kafka clusters, this must be 3.
- 'cluster_private_network_uuid' : The ID of the VPC where the database cluster will be located.
- 'mysql_sql_mode' :  A comma separated string specifying the SQL modes for a MySQL cluster.
- 'cluster_maintenance' : Defines when the automatic maintenance should be performed for the database cluster.
- 'maintenance_hour' :  The hour in UTC at which maintenance updates will be applied in 24 hour format.
- 'aintenance_day' : The day of the week on which to apply maintenance updates.
- 'redis_eviction_policy ' : A string specifying the eviction policy for a Redis cluster. Valid values are: noeviction, allkeys_lru, allkeys_random, volatile_lru, volatile_random, or volatile_ttl.

## Module Outputs

This module does not produce any outputs. It is primarily used for labeling resources within your Terraform configuration.

- 'database_cluster_id' : The ID of the database cluster.
- 'database_cluster_urn' : The uniform resource name of the database cluster.
- 'database_cluster_host'  Database cluster's hostname.
- 'database_cluster_port' : Network port that the database cluster is listening on.
- 'connection_pool_id' :The ID of the database replica created by Terraform.
- 'connection_pool_host' : Database replica's hostname.

## Examples
For detailed examples on how to use this module, please refer to the 'examples' directory within this repository.

## License
This Terraform module is provided under the '[License Name]' License. Please see the [LICENSE](https://github.com/opz0/terraform-digitalocean-db/blob/readme/LICENSE) file for more details.

## Author
Your Name
Replace '[License Name]' and '[Your Name]' with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.