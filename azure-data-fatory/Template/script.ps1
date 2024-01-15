param
(
    [parameter(Mandatory = $true)] [String] $DataFactoryName,
    [parameter(Mandatory = $true)] [String] $DataFactoryResourceGroup,
    [parameter(Mandatory = $true)] [String] $DataFactorySubscriptionId,
    [parameter(Mandatory = $false)] [Bool] $DisableAllTriggers = $true,
    [parameter(Mandatory = $true)] [String] $EnabledTriggers # comma separated list
)
 
 
 
##############################################
# Check provided information
##############################################
$ErrorActionPreference = "Stop"
 
# Setting one subscription on active (fails with non existing)
Write-Host "Checking existance Subscription Id [$($DataFactorySubscriptionId)]."
$Subscription = Get-AzSubscription -SubscriptionId $DataFactorySubscriptionId `
                                   -WarningAction Ignore
Write-Host "- Subscription [$($Subscription.Name)] found."
Set-AzContext -Subscription $DataFactorySubscriptionId `
              -WarningAction Ignore > $null
Write-Host "- Subscription [$($Subscription.Name)] is active."
 
 
# Checking whether resource group exists (fails with non existing)
Write-Host "Checking existance Resource Group [$($DataFactoryResourceGroup)]."
Get-AzResourceGroup -Name $DataFactoryResourceGroup > $null
Write-Host "- Resource Group [$($DataFactoryResourceGroup)] found."
 
 
# Checking whether provided data factory exists (fails with non existing)
Write-Host "Checking existance Data Factory [$($DataFactoryName)]."
Get-AzDataFactoryV2 -ResourceGroupName $DataFactoryResourceGroup `
                    -Name $DataFactoryName > $null
Write-Host "- Data Factory [$($DataFactoryName)] found."
 
 
# Checking provided triggernames, first split into array
$EnabledTriggersArray = $EnabledTriggers.Split(",")
Write-Host "Checking existance of ($($EnabledTriggersArray.Count)) provided triggernames."
 
 
# Loop through all provided triggernames
foreach ($EnabledTrigger in $EnabledTriggersArray)
{ 
    # Get Trigger by name
    $CheckTrigger = Get-AzDataFactoryV2Trigger -ResourceGroupName $DataFactoryResourceGroup `
                                               -DataFactoryName $DataFactoryName `
                                               -Name $EnabledTrigger `
                                               -ErrorAction Ignore # To be able to provide more detailed error
 
    # Check if trigger was found
    if (!$CheckTrigger)
    {
        throw "Trigger $($EnabledTrigger) not found in data dactory $($DataFactoryName) within resource group $($DataFactoryResourceGroup)"
    }
}
Write-Host "- All ($($EnabledTriggersArray.Count)) provided triggernames found in data dactory $($DataFactoryName) within resource group $($DataFactoryResourceGroup)"
 
 
 
##############################################
# Disable triggers
##############################################
# Check if all trigger should be disabled
if ($DisableAllTriggers)
{
    # Get all enabled triggers and stop them (unless they should be enabled)
    Write-Host "Getting all enabled triggers that should be disabled."
    $CurrentTriggers = Get-AzDataFactoryV2Trigger -ResourceGroupName $DataFactoryResourceGroup `
                                                   -DataFactoryName $DataFactoryName `
                       | Where-Object {$_.RuntimeState -ne 'Stopped'} `
                       | Where-Object {$EnabledTriggersArray.Contains($_.Name) -eq $false}
 
    # Loop through all found triggers
    Write-Host "- Number of triggers to disable: $($CurrentTriggers.Count)."
    foreach ($CurrentTrigger in $CurrentTriggers)
    {
        # Stop trigger
        Write-Host "- Stopping trigger [$($CurrentTrigger.Name)]."
        Stop-AzDataFactoryV2Trigger -ResourceGroupName $DataFactoryResourceGroup -DataFactoryName $DataFactoryName -Name $CurrentTrigger.Name -Force > $null
    }
}
 
 
 
##############################################
# Enable triggers
##############################################
# Loop through provided triggernames and enable them
Write-Host "Enable all ($($EnabledTriggersArray.Count)) provided triggers."
foreach ($EnabledTrigger in $EnabledTriggersArray)
{                   
    # Get trigger details
    $CheckTrigger = Get-AzDataFactoryV2Trigger -ResourceGroupName $DataFactoryResourceGroup `
                                               -DataFactoryName $DataFactoryName `
                                               -Name $EnabledTrigger
 
    # Check status of trigger
    if ($CheckTrigger.RuntimeState -ne "Started")
    {
        Write-Host "- Trigger [$($EnabledTrigger)] starting"
        Start-AzDataFactoryV2Trigger -ResourceGroupName $DataFactoryResourceGroup `
                                     -DataFactoryName $DataFactoryName `
                                     -Name $EnabledTrigger `
                                     -Force > $null
    }
    else
    {
        Write-Host "- Trigger [$($EnabledTrigger)] already started"
    }
}