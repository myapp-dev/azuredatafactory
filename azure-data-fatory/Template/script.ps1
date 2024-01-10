$personalToken = "AzureDevOpsPersonalToken"
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($personalToken)"))
$header = @{authorization = "Basic $token"}

$organization = "myOrga"
$project = "myProj"

$pipelineName = Read-Host "Please enter pipeline to delete"

# Get all Azure Data Factory pipelines
$url = "https://dev.azure.com/$organization/$project/_apis/pipelines?api-version=6.0"
$pipelines = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers $header

$pipelines.value | ForEach-Object {
    if ($_.name -eq $pipelineName) {
        # Get the pipeline ID
        $pipelineId = $_.id
        
        # Delete the pipeline
        $url = "https://dev.azure.com/$organization/$project/_apis/pipelines/$pipelineId?api-version=6.0"
        Invoke-RestMethod -Uri $url -Method Delete -Headers $header

        Write-Host "Pipeline '$pipelineName' deleted."

        # Delete the associated dataset (if applicable)
        $datasetUrl = "https://dev.azure.com/$organization/$project/_apis/pipelines/$pipelineId/datasets?api-version=6.0"
        Invoke-RestMethod -Uri $datasetUrl -Method Delete -Headers $header
        Write-Host "Dataset associated with pipeline '$pipelineName' deleted."

        # Delete the linked service (if applicable)
        $linkedServiceUrl = "https://dev.azure.com/$organization/$project/_apis/pipelines/$pipelineId/linkedServices?api-version=6.0"
        Invoke-RestMethod -Uri $linkedServiceUrl -Method Delete -Headers $header
        Write-Host "Linked service associated with pipeline '$pipelineName' deleted."

        break
    }
}

Write-Host
