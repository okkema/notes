terraform {
  backend "remote" {
    organization = "okkema"
    workspaces {
      name = "notes"
    }
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.10.0"
    }
  }
}
