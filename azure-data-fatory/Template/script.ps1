# Install the Azure PowerShell module if needed
if (!(Get-Module -ListAvailable Az)) {
    Install-Module Az -Scope CurrentUser
}

# Connect to Azure
Connect-AzAccount

# Specify Data Factory and resource group names
$dataFactoryName = "myappadfa"
$resourceGroupName = "project-dev"

# Retrieve Data Factory details
$dataFactory = Get-AzDataFactory -ResourceGroupName $resourceGroupName -Name $dataFactoryName

# Delete datasets
foreach ($dataset in $dataFactory.Datasets) {
    Remove-AzDataFactoryDataset -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $dataset.Name -Force  # Use -Force to potentially bypass dependencies
}

# Delete linked services
foreach ($linkedService in $dataFactory.LinkedServices) {
    Remove-AzDataFactoryLinkedService -ResourceGroupName $resourceGroupName -DataFactoryName $dataFactoryName -Name $linkedService.Name -Force  # Use -Force to potentially bypass dependencies
}
