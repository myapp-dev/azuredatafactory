param(
    [parameter(Mandatory = $true)] [string]$ResourceGroupName,
    [parameter(Mandatory = $true)] [string]$dataFactoryName
)

# Check if AzureRM context is available, if not, log in
if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {
    Write-Host "Logging in to AzureRM account..."
    Add-AzureRmAccount
}

$ADF_Triggers = Get-AzureRmDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $dataFactoryName -ErrorVariable notPresent -ErrorAction SilentlyContinue
Write-Host $ADF_Triggers.Name

if ($notPresent) {
    Write-Host "Trigger does not exist. Nothing to enable!"
} else {
    $ADF_Triggers | ForEach-Object { 
        Write-Host "Enabling Pipeline Trigger $($_.name)"
        Start-AzureRmDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $dataFactoryName -Name $_.name -Force 
    }
}
