# Install Azure PowerShell module
Install-Module -Name Az -Force -AllowClobber

# Import Azure PowerShell module
Import-Module Az

# Authenticate to Azure
# Authenticate to Azure
Connect-AzAccount -ServicePrincipal -Credential $secrets.AZURE_CREDENTIALS
# Define variables
$resourceGroupName = "project-dev"
$dataFactoryName = "myappadf"
$pipelineName = "ds_raiscopy"
$datasetName = "ds_azurcloud"
$linkedServiceName = "ds_azuresqls"

# Delete Pipeline
Remove-AzDataFactoryPipeline -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $pipelineName -Force

# Delete Dataset
Remove-AzDataFactoryDataset -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $datasetName -Force

# Delete Linked Service
Remove-AzDataFactoryLinkedService -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $linkedServiceName -Force
