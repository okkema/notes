locals {
  secrets = {
    "TF_API_TOKEN" : var.TF_API_TOKEN,
    "ACTIONS_GITHUB_TOKEN" : var.ACTIONS_GITHUB_TOKEN
  }
}

module "secrets" {
  for_each = local.secrets

  source  = "app.terraform.io/okkema/secret/github"
  version = "0.1.0"

  repository = var.github_repository
  key        = each.key
  value      = each.value
}

resource "cloudflare_worker_script" "script" {
  account_id = var.cloudflare_account_id
  name       = "notes"
  content    = file(abspath("${path.module}/../dist/index.js"))
  module     = true
}

resource "cloudflare_worker_domain" "domain" {
  account_id = var.cloudflare_account_id
  hostname   = "public.${var.cloudflare_zone}"
  service    = cloudflare_worker_script.script.name
  zone_id    = var.cloudflare_zone_id
}

