

Import-Module Az.Accounts  # Import Azure modules for authentication
Import-Module Az.DataFactory # Import Azure Data Factory module

# Login to Azure
Connect-AzAccount

# Specify resource group, data factory name, pipeline name, and dataset name
$resourceGroupName = "project-dev"
$dataFactoryName = "myappadf"
$pipelineName = "ds_raiscopy"
$datasetName = "ds_azurcloud"

# Delete the pipeline
Remove-AzDataFactoryV2Pipeline -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $pipelineName -Force

# Delete the dataset
Remove-AzDataFactoryV2Dataset -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $datasetName -Force

Write-Output "Pipeline and dataset deleted successfully."
