# how-to-autoscale-Azure-SQL-database
This solution allows you to automatically scale Azure SQL databases and implement it automatically on a new environments via Terraform (and ARM injected into Terraform)

1. Overview

Azure SQL Database offers an easy several-clicks solution to scale database instances when more resources are needed, however, is that the scaling operation is a manual one. In order to save money we implemented logic based on https://techcommunity.microsoft.com/t5/azure-database-support-blog/how-to-auto-scale-azure-sql-databases/ba-p/2235441  to run it automatically.

2. Prerequisite:

Supported purchasing models. The script only supports DTU and vCore (provisioned compute) databases. Hyperscale, Serverless, Fsv2, DC and M series are not supported.
Az Automation needs to have the following modules imported:
Az.Account
Az.Automation
Az.Sql
Az.AlertsManagement
As per https://azure.microsoft.com/en-us/updates/azure-automation-az-module-support/  , the modules should be installed when a new automation account is created, otherwise manual installation via modules gallery helps out.

3. How it works
The scale operation will be executed by a PowerShell runbook inside of an Azure Automation account. The script uses Webhook data passed from the alert. This data contains useful information about the resource the alert gets triggered from, which means the script can auto-scale any database and no parameters are needed; it only needs to be called from an alert using the Common Alert Schema on an Azure SQL database.

image.png

4. How to control scalling
Having said all above, to have the database tier under control in case of presentation, you will need to:
image.png

Set proper pricing tier. It may require to upscale to have a better experience if more demanding jobs will be executed. Please keep in mind that you shouldn’t go beyond the defined rsob limits {3}
Increase the time of the downscale alert condition. Click on Alerts, then Manage alert rules, subsequently choose autoscale alert. Usually, downscaling should be considered as a potential problem in more intensive jobs. Still, for some reason, it can be an excellent approach to set a pricing tier equal to max_rsob. It excludes potential error when the database runs a highly demanding job and dtu exceeds 85% for more than 5 min. If the tier is not on max_rsob, the database will scale up and the job is interrupted/stopped.
When it comes to downscaling conditions, the alert is triggered based on:
dtu limit under some number (majority of cases is set on 10),
dtu percentage less than 10%.
By clicking on one of them, two evaluations appear:

aggregation granularity (period) – defines the interval over which datapoints are grouped using the aggregation type function
frequency of evaluation – defines how often the alert should be run
No matter on which of them the time is changed, the change will affect the entire alert.
image.png

Worth mentioning, the frequency of evaluation should be lower than the period to create the required evaluation sliding window. In most of our databases, the conditions evaluate every 5 minutes, which means the tier can scale down every 5 minutes.

5. How do we keep auto-scaling in check

A two-step way of ensuring safety is implemented. Firstly, the runbook has a built-in list that will not allow a tier to be exceeded.
image.png

Second, each runbook has a loop with min/max_rsob tag. If the script is at the lowest/highest level it breaks the scaling loop.
image.png

Moreover, in the case of a downscale, the condition is evaluated based on the number of dtu. The alert will not be even triggered if the database tier is already at the defined minimum level (min_rsob tag).
