# Install Azure PowerShell module
Install-Module -Name Az -Force -AllowClobber

# Import Azure PowerShell module
Import-Module Az

# Define variables
$resourceGroupName = "project-dev"
$dataFactoryName = "myappadf"
$pipelineName = "ds_raiscopy"
$datasetName = "ds_azurcloud"
$linkedServiceName = "ds_azuresqls"

# Service principal credentials
$applicationId = "3c67905d-6b25-442d-833c-42ccdec8d3a5"
$secret = "kS_8Q~xH1L3KT3.Qvlw2BEVAUdaaNRzU5rjoGdo."
$tenantId = "6712c173-cfc7-47a7-b8ee-cf07ef93f18d"
$secureSecret = ConvertTo-SecureString -String $secret -AsPlainText -Force
$servicePrincipal = New-Object PSCredential -ArgumentList $applicationId, $secureSecret

# Authenticate to Azure
Connect-AzAccount -ServicePrincipal -Credential $servicePrincipal -Tenant $tenantId

# Delete Pipeline
Remove-AzDataFactoryPipeline -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $pipelineName -Force

# Delete Dataset
Remove-AzDataFactoryDataset -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $datasetName -Force

# Delete Linked Service
Remove-AzDataFactoryLinkedService -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $linkedServiceName -Force
