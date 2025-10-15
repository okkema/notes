locals {
  secrets = {
    "TF_API_TOKEN" : var.TF_API_TOKEN,
    "ACTIONS_GITHUB_TOKEN" : var.ACTIONS_GITHUB_TOKEN
    "CLOUDFLARE_R2_ACCESS_KEY" : var.cloudflare_r2_access_key
    "CLOUDFLARE_R2_SECRET_KEY" : var.cloudflare_r2_secret_key
    "CLOUDFLARE_R2_BUCKET" : var.CLOUDFLARE_R2_BUCKET
    "CLOUDFLARE_ACCOUNT_ID" : var.cloudflare_account_id
  }
  role = "Private Notes Reader"
}

module "secrets" {
  for_each = local.secrets

  source  = "app.terraform.io/okkema/secret/github"
  version = "~> 0.2"

  repository = var.github_repository
  key        = each.key
  value      = each.value
}

module "bucket" {
  source  = "app.terraform.io/okkema/bucket/cloudflare"
  version = "~> 2.0"

  account_id = var.cloudflare_account_id
  name     = var.github_repository
}

module "worker" {
  source     = "app.terraform.io/okkema/worker/cloudflare"
  version    = "~> 1.0"
  depends_on = [module.bucket]

  account_id   = var.cloudflare_account_id
  zone_id      = var.cloudflare_zone_id
  name         = var.github_repository
  content_file = abspath("${path.module}/../dist/index.js")
  hostnames    = ["public.${var.github_repository}", "private.${var.github_repository}"]
  buckets = [{
    bucket_name = var.github_repository
    name        = "NOTES"
  }]
}

module "application" {
  source     = "app.terraform.io/okkema/application/cloudflare"
  version    = "~> 1.0"
  depends_on = [module.worker, module.role]

  account_id = var.cloudflare_account_id
  zone_id    = var.cloudflare_zone_id
  name       = "private.${var.github_repository}"
  role       = local.role
}

module "role" {
  source  = "app.terraform.io/okkema/role/auth0"
  version = "~> 0.2"

  name = local.role
}