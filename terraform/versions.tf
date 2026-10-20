terraform {
  backend "remote" {
    organization = "okkema"
    workspaces {
      name = "notes"
    }
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}
