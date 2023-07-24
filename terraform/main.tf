locals {
  secrets = {
    "TF_API_TOKEN" : var.TF_API_TOKEN,
    "ACTIONS_GITHUB_TOKEN" : var.ACTIONS_GITHUB_TOKEN
  }
}

module "secrets" {
  for_each = local.secrets

  source  = "app.terraform.io/okkema/secret/github"
  version = "0.2.1"

  repository = var.github_repository
  key        = each.key
  value      = each.value
}

module "bucket" {
  source  = "app.terraform.io/okkema/bucket/cloudflare"
  version = "0.1.1"

  account_id = var.cloudflare_account_id
  access_key = var.cloudflare_r2_access_key
  secret_key = var.cloudflare_r2_secret_key
  bucket     = "notes"
}

module "worker" {
  source  = "app.terraform.io/okkema/worker/cloudflare"
  version = "0.3.0"

  account_id = var.cloudflare_account_id
  zone_id    = var.cloudflare_zone_id
  name       = "notes"
  content    = file(abspath("${path.module}/../dist/index.js"))
  hostnames  = ["public.notes.${var.cloudflare_zone}", "private.notes.${var.cloudflare_zone}"]
  buckets = [{
    binding = "NOTES"
    name    = "notes"
  }]
}