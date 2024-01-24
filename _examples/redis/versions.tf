terraform {
  required_version = ">= 1.6.6"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.34.1"
    }
  }
}
