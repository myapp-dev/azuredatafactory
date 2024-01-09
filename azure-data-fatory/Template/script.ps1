$DataFactoryName = "myappdev"
$ResourceGroupName = "project-dev"

# Deleted resources
# pipelines
Write-Host "Getting pipelines"
$pipelinesADF = Get-SortedPipelines -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName
$pipelinesTemplate = $resources | Where-Object { $_.type -eq "Microsoft.DataFactory/factories/pipelines" }
$pipelinesNames = $pipelinesTemplate | ForEach-Object {$_.name.Substring(37, $_.name.Length-40)}
$deletedpipelines = $pipelinesADF | Where-Object { $pipelinesNames -notcontains $_.Name }

# datasets
Write-Host "Getting datasets"
$datasetsADF = Get-AzDataFactoryV2Dataset -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName
$datasetsTemplate = $resources | Where-Object { $_.type -eq "Microsoft.DataFactory/factories/datasets" }
$datasetsNames = $datasetsTemplate | ForEach-Object {$_.name.Substring(37, $_.name.Length-40) }
$deleteddataset = $datasetsADF | Where-Object { $datasetsNames -notcontains $_.Name }

# linkedservices
Write-Host "Getting linked services"
$linkedservicesADF = Get-SortedLinkedServices -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName
$linkedservicesTemplate = $resources | Where-Object { $_.type -eq "Microsoft.DataFactory/factories/linkedservices" }
$linkedservicesNames = $linkedservicesTemplate | ForEach-Object {$_.name.Substring(37, $_.name.Length-40)}
$deletedlinkedservices = $linkedservicesADF | Where-Object { $linkedservicesNames -notcontains $_.Name }

# Delete resources
Write-Host "Deleting pipelines"
$deletedpipelines | ForEach-Object { 
    Write-Host "Deleting pipeline " $_.Name
    Remove-AzDataFactoryV2Pipeline -Name $_.Name -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Force 
}

Write-Host "Deleting datasets"
$deleteddataset | ForEach-Object { 
    Write-Host "Deleting dataset " $_.Name
    Remove-AzDataFactoryV2Dataset -Name $_.Name -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Force 
}

Write-Host "Deleting linked services"
$deletedlinkedservices | ForEach-Object { 
    Write-Host "Deleting Linked Service " $_.Name
    Remove-AzDataFactoryV2LinkedService -Name $_.Name -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Force 
}

# ...
