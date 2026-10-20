locals {
  secrets = {
    "TF_API_TOKEN" : var.TF_API_TOKEN,
    "ACTIONS_GITHUB_TOKEN" : var.ACTIONS_GITHUB_TOKEN
    "CLOUDFLARE_R2_ACCESS_KEY" : var.cloudflare_r2_access_key
    "CLOUDFLARE_R2_SECRET_KEY" : var.cloudflare_r2_secret_key
    "CLOUDFLARE_R2_BUCKET" : var.CLOUDFLARE_R2_BUCKET
    "CLOUDFLARE_ACCOUNT_ID" : var.cloudflare_account_id
  }
  ocr_secrets = {
    "aws-access-key-id" : var.cloudflare_r2_access_key
    "aws-secret-access-key" : var.cloudflare_r2_secret_key
    "r2-bucket" : var.CLOUDFLARE_R2_BUCKET
  }
  zip_file = abspath("${path.module}/../dist/notes.zip")
  role     = "Private Notes Reader"
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
  name       = var.github_repository
}

module "worker" {
  source     = "app.terraform.io/okkema/worker/cloudflare"
  version    = "~> 1.0"
  depends_on = [module.bucket, module.ocr]

  account_id          = var.cloudflare_account_id
  zone_id             = var.cloudflare_zone_id
  name                = var.github_repository
  content_file        = abspath("${path.module}/../dist/index.js")
  hostnames           = ["public.${var.github_repository}", "private.${var.github_repository}"]
  compatibility_flags = ["nodejs_compat_v2"]
  buckets = [{
    bucket_name = var.github_repository
    name        = "BUCKET"
  }]
  secrets = [
    {
      name = "SENTRY_DSN"
      text = module.sentry.dsn
    },
    {
      name = "GOOGLE_CREDENTIALS"
      text = module.service_account.private_key
    },
  ]
  env_vars = [{
    name = "GOOGLE_FUNCTION_URL_OCR"
    text = module.ocr.function_uri
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

module "sentry" {
  source  = "app.terraform.io/okkema/project/sentry"
  version = "~> 0.4"

  github_repository = var.github_repository
  platform          = "other"
}

module "project" {
  source  = "app.terraform.io/okkema/project/google"
  version = "~> 0.1"

  name            = var.github_repository
  billing_account = var.google_billing_account
}

module "service_account" {
  source  = "app.terraform.io/okkema/service_account/google"
  version = "~> 0.1"

  account_id = var.github_repository
  project    = module.project.project_id
}

module "function_bucket" {
  source  = "app.terraform.io/okkema/bucket/google"
  version = "~> 0.1"

  project = module.project.project_id
  name    = module.project.project_id
  objects = {
    "notes.zip" = local.zip_file
  }
}

module "ocr_secret" {
  source   = "app.terraform.io/okkema/secret/google"
  version  = "~> 0.1"
  for_each = local.ocr_secrets

  project     = module.project.project_id
  secret_id   = each.key
  secret_data = each.value
}

module "ocr" {
  source  = "app.terraform.io/okkema/function/google"
  version = "~> 0.2"

  project          = module.project.project_id
  entry_point      = "ocr_paper"
  description      = "OCR a PDF paper and store markdown note"
  available_cpu    = 1
  available_memory = "2Gi"
  timeout_seconds  = 300
  environment_variables = {
    SENTRY_DSN      = module.sentry.dsn
    BUCKET_URL      = var.cloudflare_r2_endpoint_url
    UNPAYWALL_EMAIL = var.google_unpaywall_email
  }
  secrets = {
    AWS_ACCESS_KEY_ID     = "aws-access-key-id"
    AWS_SECRET_ACCESS_KEY = "aws-secret-access-key"
    BUCKET                = "r2-bucket"
  }
  bucket     = module.project.project_id
  object     = "notes.zip"
  members    = ["serviceAccount:${module.service_account.email}"]
  depends_on = [module.function_bucket, module.ocr_secret, module.sentry]
}