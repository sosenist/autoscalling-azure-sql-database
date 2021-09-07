provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "xx"
  subscription_id = "xx1"
  features {}
}

terraform {
  backend "azurerm" {
        resource_group_name     = "rg"
        container_name          = "my_cn"
        key                     = "my.tfstate"
        storage_account_name    = "storage"
        subscription_id = "xx2"
  }
}

locals {
  environment      = lookup(var.environment, terraform.workspace)
  project          = lookup(var.project, terraform.workspace)
  product          = lookup(var.product, terraform.workspace)
  location_suffix  = lookup(var.location_suffix, terraform.workspace)
  upscale          = lookup(var.upscale, terraform.workspace)
  downscale        = lookup(var.downscale, terraform.workspace)
  dbdownscalethreshold = lookup(var.dbdownscalethreshold, terraform.workspace)
  dbupscalethreshold = lookup(var.dbupscalethreshold, terraform.workspace)
  dbmindtulimit    = lookup(var.dbmindtulimit, terraform.workspace)
  db_tier         = lookup(var.db_tier, terraform.workspace)
  min_rsob        = lookup(var.min_rsob, terraform.workspace)
  max_rsob        = lookup(var.max_rsob, terraform.workspace)
  database_edition = lookup(var.database_edition, terraform.workspace)
}

module "alerts" {
  source              = "./modules/alerts"
  resource_group      = module.resource_group.resource_group
  environment         = local.environment
  project             = local.project
  product             = local.product
  location_suffix     = local.location_suffix
  downscale           = local.downscale
  upscale             = local.upscale
  dbdownscalethreshold = local.dbdownscalethreshold
  dbupscalethreshold = local.dbupscalethreshold
  dbmindtulimit = local.dbmindtulimit
}


module "database" {
  source          = "./modules/database"
  resource_group  = module.resource_group.resource_group
  environment     = local.environment
  project         = local.project
  product         = local.product
  db_tier         = local.db_tier
  min_rsob        = local.min_rsob
  max_rsob        = local.max_rsob
  database_edition = local.database_edition
  location_suffix = local.location_suffix
}

