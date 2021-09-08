# autoscalling-azure-sql-database with implementation in terraform

Based on https://techcommunity.microsoft.com/t5/azure-database-support-blog/how-to-auto-scale-azure-sql-databases/ba-p/2235441
https://hbuckle.github.io/terraform/2018/03/08/creating-azure-automation-webhooks-with-terraform.html

As Azure PowerShell migrate from AzureRM to Az
https://docs.microsoft.com/en-us/powershell/azure/migrate-from-azurerm-to-az?view=azps-6.4.0

Required modules added to Automation Account: 
- Az.AlertsManagement
- Az.Automation
- Az.Sql
- Az.Accounts 
