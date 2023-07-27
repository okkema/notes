locals {
  secrets = {
    "TF_API_TOKEN" : var.TF_API_TOKEN,
    "ACTIONS_GITHUB_TOKEN" : var.ACTIONS_GITHUB_TOKEN
  }
  name = "notes"
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
  bucket     = local.name
}

module "worker" {
  source     = "app.terraform.io/okkema/worker/cloudflare"
  version    = "0.4.0"
  depends_on = [module.bucket]

  account_id = var.cloudflare_account_id
  zone_id    = var.cloudflare_zone_id
  name       = local.name
  content    = file(abspath("${path.module}/../dist/index.js"))
  hostnames  = ["public.${local.name}", "private.${local.name}"]
  buckets = [{
    binding = "NOTES"
    name    = local.name
  }]
}

module "team" {
  source  = "app.terraform.io/okkema/team/github"
  version = "0.1.0"

  name = local.name
}

module "application" {
  source     = "app.terraform.io/okkema/application/cloudflare"
  version    = "0.2.2"
  depends_on = [module.team, module.worker]

  zone_id      = var.cloudflare_zone_id
  name         = "private.${local.name}"
  github_teams = [local.name]
}