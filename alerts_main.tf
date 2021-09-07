#data automation account
data "azurerm_automation_account" "aa" {
  name = "aa-${var.product}-${var.project}-${var.environment}-${var.location_suffix}"
  resource_group_name = var.resource_group.name
}

#locals
locals {
  webhook_name_upscale = "${data.azurerm_automation_account.aa.name}/${var.environment}_webhook-gateway-upscale"
  webhook_uri_upscale =  "https://${split("/",data.azurerm_automation_account.aa.endpoint)[4]}.webhook.we.azure-automation.net/webhooks?token=%2b${random_string.token1.result}%2b${random_string.token2.result}%3d"
  webhook_name_downscale = "${data.azurerm_automation_account.aa.name}/${var.environment}_webhook-gateway-downscale"
  webhook_uri_downscale =  "https://${split("/",data.azurerm_automation_account.aa.endpoint)[4]}.webhook.we.azure-automation.net/webhooks?token=%2b${random_string.token3.result}%2b${random_string.token4.result}%3d"
}

#tokens
resource "random_string" "token1" {
  length  = 10
  upper   = true
  lower   = true
  number  = true
  special = false
}
resource "random_string" "token2" {
  length  = 31
  upper   = true
  lower   = true
  number  = true
  special = false
}
resource "random_string" "token3" {
  length  = 10
  upper   = true
  lower   = true
  number  = true
  special = false
}
resource "random_string" "token4" {
  length  = 31
  upper   = true
  lower   = true
  number  = true
  special = false
}

#upscale deployment
resource "azurerm_resource_group_template_deployment" "gateway_scripts_deployment_upscale" {
  name                = "webhook-${var.product}-${var.project}-gateway-upscale-${var.environment}-${var.location_suffix}"
  resource_group_name = var.resource_group.name
  deployment_mode     = "Incremental"
  template_content = <<TEMPLATE
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "name": "${local.webhook_name_upscale}",
      "type": "Microsoft.Automation/automationAccounts/webhooks",
      "apiVersion": "2015-10-31",
      "properties": {
        "isEnabled": true,
        "uri": "${local.webhook_uri_upscale}",
        "expiryTime": "2028-01-01T00:00:00.000+00:00",
        "parameters": {},
        "runbook": {
          "name": "autoscaleSQL"
        }
      }
    }
  ]
}
TEMPLATE
}

#downscale deployment
resource "azurerm_resource_group_template_deployment" "gateway_scripts_deployment_downscale" {
  name                = "webhook-${var.product}-${var.project}-gateway-downscale-${var.environment}-${var.location_suffix}"
  resource_group_name = var.resource_group.name
  deployment_mode     = "Incremental"
  template_content = <<TEMPLATE
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "name": "${local.webhook_name_downscale}",
      "type": "Microsoft.Automation/automationAccounts/webhooks",
      "apiVersion": "2015-10-31",
      "properties": {
        "isEnabled": true,
        "uri": "${local.webhook_uri_downscale}",
        "expiryTime": "2028-01-01T00:00:00.000+00:00",
        "parameters": {},
        "runbook": {
          "name": "autoscaleSQL-downscale"
        }
      }
    }
  ]
}
TEMPLATE
}

#upscale monitor group
resource "azurerm_monitor_action_group" "ag-mnfro-intd-dbupscale" {
  name                = "ag-${var.product}-${var.project}-dbupscale-${var.environment}-${var.location_suffix}"
  resource_group_name = var.resource_group.name
  short_name          = "ag-mnfro-${var.upscale}"
  
  automation_runbook_receiver {
    automation_account_id   = data.azurerm_automation_account.aa.id 
    is_global_runbook       = false
    name                    = "upscaleSQLdb" 
    runbook_name            = "autoscaleSQL" 
    service_uri             = local.webhook_uri_upscale
    use_common_alert_schema = true 
    webhook_resource_id     = "${data.azurerm_automation_account.aa.id}/webhooks/${local.webhook_name_upscale}" 
  }

  email_receiver {
    email_address           = "random_email@random.com"
    name                    = "sendtoorandom_email_-EmailAction-"
    use_common_alert_schema = true 
  }
}



#downscale monitor group
resource "azurerm_monitor_action_group" "ag-mnfro-intd-dbdownscale" {
  name                = "ag-${var.product}-${var.project}-dbdownscale-${var.environment}-${var.location_suffix}"
  resource_group_name = var.resource_group.name
  short_name          = "ag-mnfro-${var.downscale}"
  
  automation_runbook_receiver {
    automation_account_id   = data.azurerm_automation_account.aa.id 
    is_global_runbook       = false
    name                    = "downscaleSQLdb" 
    runbook_name            = "autoscaleSQL-downscale" 
    service_uri             = local.webhook_uri_downscale
    use_common_alert_schema = true 
    webhook_resource_id     = "${data.azurerm_automation_account.aa.id}/webhooks/${local.webhook_name_downscale}" 
  }

  email_receiver {
    email_address           = "random_email@random.com"
    name                    = "sendtoorandom_email_-EmailAction-"
    use_common_alert_schema = true 
  }
}

#upscale alert
resource "azurerm_monitor_metric_alert" "gateway-database-upscale" {
  name                = "gateway-${var.environment}-database-autoscale"
  resource_group_name = var.resource_group.name
  scopes              = [var.gateway_database.id]
  enabled             = true
  auto_mitigate        = false
  frequency            = "PT1M"
  severity             = 2
  window_size          = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "dtu_consumption_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.dbupscalethreshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag-mnfro-intd-dbupscale.id
  }

}

#downscale alert
resource "azurerm_monitor_metric_alert" "gateway-database-downscale" {
  name                = "gateway-${var.environment}-database-autoscale-downscale"
  resource_group_name = var.resource_group.name
  scopes              = [var.gateway_database.id]
  enabled             = true
  auto_mitigate        = false
  frequency            = "PT5M"
  severity             = 2
  window_size          = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "dtu_consumption_percent"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.dbdownscalethreshold
  }

  criteria { 
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "dtu_limit"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.dbmindtulimit
  }  

  action {
    action_group_id = azurerm_monitor_action_group.ag-mnfro-intd-dbdownscale.id
  }
}
