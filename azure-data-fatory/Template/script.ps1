
# Install Azure PowerShell module
Install-Module -Name Az -Force -AllowClobber

# Import Azure PowerShell module
Import-Module Az

# Authenticate to Azure
$azCredentials = $secrets.AZURE_CREDENTIALS
$servicePrincipal = New-Object PSCredential($azCredentials.ApplicationId, (ConvertTo-SecureString $azCredentials.Secret -AsPlainText -Force))
Connect-AzAccount -ServicePrincipal -Credential $servicePrincipal -Tenant $azCredentials.TenantId

# Set Azure context
Set-AzContext -SubscriptionId "6712c173-cfc7-47a7-b8ee-cf07ef93f18d"

# Define variables
$resourceGroupName = "project-dev"
$dataFactoryName = "myappadf"
$pipelineName = "ds_raiscopy"
$datasetName = "ds_azurcloud"
$linkedServiceName = "ds_azuresqls"

# Specify API version
$apiVersion = "2018-06-01"

# Delete Pipeline
Remove-AzDataFactoryPipeline -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $pipelineName -Force -ApiVersion $apiVersion

# Delete Dataset
Remove-AzDataFactoryDataset -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $datasetName -Force -ApiVersion $apiVersion

# Delete Linked Service
Remove-AzDataFactoryLinkedService -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $linkedServiceName -Force -ApiVersion $apiVersion
