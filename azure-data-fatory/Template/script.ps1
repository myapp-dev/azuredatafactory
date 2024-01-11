# Install or update the Az module
Install-Module -Name Az -Force -AllowClobber -Scope CurrentUser -Repository PSGallery -Confirm:$false

# Specify your Data Factory details
$dataFactoryName = "myappadfa"
$resourceGroupName = "project-dev"
$apiVersion = '2018-06-01'  # Adjust the API version according to your requirements

# Retrieve Data Factory details
try {
    $dataFactory = Get-AzDataFactory -ResourceGroupName $resourceGroupName -Name $dataFactoryName -ApiVersion $apiVersion
} catch {
    Write-Error "Failed to retrieve Data Factory: $($_.Exception.Message)"
    exit
}

# Delete datasets (without dependency checks)
foreach ($dataset in $dataFactory.Datasets) {
    try {
        Remove-AzDataFactoryDataset -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $dataset.Name -ApiVersion $apiVersion
        Write-Output "Deleted dataset: $($dataset.Name)"
    } catch {
        Write-Warning "Failed to delete dataset $($dataset.Name): $($_.Exception.Message)"
    }
}

# Delete linked services (without dependency checks)
foreach ($linkedService in $dataFactory.LinkedServices) {
    try {
        Remove-AzDataFactoryLinkedService -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $linkedService.Name -ApiVersion $apiVersion
        Write-Output "Deleted linked service: $($linkedService.Name)"
    } catch {
        Write-Warning "Failed to delete linked service $($linkedService.Name): $($_.Exception.Message)"
    }
}

# Delete pipelines (without dependency checks)
foreach ($pipeline in $dataFactory.Pipelines) {
    try {
        Remove-AzDataFactoryPipeline -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $pipeline.Name -ApiVersion $apiVersion
        Write-Output "Deleted pipeline: $($pipeline.Name)"
    } catch {
        Write-Warning "Failed to delete pipeline $($pipeline.Name): $($_.Exception.Message)"
    }
}

Write-Output "Deletion process complete (no dependency checks performed)."
