module "labels" {
  source      = "cypik/labels/digitalocean"
  version     = "1.0.2"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
}

resource "digitalocean_database_cluster" "cluster" {
  count                = var.enabled == true ? 1 : 0
  name                 = format("%s-sk${var.cluster_engine}", module.labels.id)
  engine               = var.cluster_engine
  version              = var.cluster_version
  size                 = var.cluster_size
  region               = var.region
  node_count           = var.cluster_node_count
  private_network_uuid = var.cluster_private_network_uuid
  tags                 = [module.labels.id]
  eviction_policy      = var.redis_eviction_policy
  sql_mode             = var.mysql_sql_mode
  project_id           = var.project_id

  dynamic "maintenance_window" {
    for_each = var.cluster_maintenance != null ? [var.cluster_maintenance] : []
    content {
      hour = maintenance_window.value.maintenance_hour
      day  = maintenance_window.value.maintenance_day
    }
  }
  dynamic "backup_restore" {
    for_each = var.backup_restore != null ? [var.backup_restore] : []
    content {
      database_name     = backup_restore.value.database_name
      backup_created_at = lookup(backup_restore.value, "backup_created_at", null)
    }
  }
}

resource "digitalocean_database_db" "database" {
  count      = var.cluster_engine != "redis" ? length(var.databases) : 0 # Skip for Redis
  cluster_id = join("", digitalocean_database_cluster.cluster[*].id)
  name       = var.databases[count.index]
}


resource "digitalocean_database_user" "user" {
  for_each          = var.enabled == true && var.users != null ? { for u in var.users : u.name => u } : {}
  cluster_id        = join("", digitalocean_database_cluster.cluster[*].id)
  name              = each.value.name
  mysql_auth_plugin = lookup(each.value, "mysql_auth_plugin", null)
}

resource "digitalocean_database_connection_pool" "connection_pool" {
  for_each   = var.enabled == true && var.create_pools ? { for p in var.pools : p.name => p } : {}
  cluster_id = join("", digitalocean_database_cluster.cluster[*].id)
  name       = each.value.name
  mode       = each.value.mode
  size       = each.value.size
  db_name    = each.value.db_name
  user       = each.value.user
}

resource "digitalocean_database_firewall" "firewall" {
  count      = var.enabled == true && var.create_firewall ? 1 : 0
  cluster_id = join("", digitalocean_database_cluster.cluster[*].id)
  dynamic "rule" {
    for_each = var.firewall_rules
    content {
      type  = rule.value.type
      value = rule.value.value
    }
  }
  depends_on = [digitalocean_database_cluster.cluster]
}

resource "digitalocean_database_replica" "replica-example" {
  count                = var.enabled == true && var.replica_enable ? 1 : 0
  cluster_id           = join("", digitalocean_database_cluster.cluster[*].id)
  name                 = format("%s-${var.cluster_engine}-replica", module.labels.id)
  size                 = var.replica_size
  region               = var.region
  tags                 = [module.labels.id]
  private_network_uuid = var.cluster_private_network_uuid
}

resource "digitalocean_database_firewall" "replica-firewall" {
  count      = var.enabled == true && var.create_firewall && var.replica_enable ? 1 : 0
  cluster_id = join("", digitalocean_database_cluster.cluster[*].id)
  dynamic "rule" {
    for_each = var.firewall_rules
    content {
      type  = rule.value.type
      value = rule.value.value
    }
  }
  depends_on = [digitalocean_database_cluster.cluster]
}
