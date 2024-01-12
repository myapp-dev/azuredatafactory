Param(
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string] $DataFactoryName
)

# Use default values only if parameters are not provided
if (-not $DataFactoryName) {
    $DataFactoryName = "myappadfa"
}

if (-not $ResourceGroupName) {
    $ResourceGroupName = "project-dev"
}

$artfTypes = "trigger", "pipeline", "dataflow", "dataset", "linkedService"

function Remove-Artifacts {
    param (
        [Parameter(Mandatory=$true)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [System.Collections.ArrayList]$artifacts,

        [Parameter(Mandatory=$true)]
        [string]$artfType
    )

    if ($artifacts.Count -gt 0) {
        [System.Collections.ArrayList]$artToProcess = New-Object System.Collections.ArrayList($null)

        foreach ($artifact in $artifacts) {
            try {
                $removeAzDFCommand = "Remove-AzDataFactoryV2$($artfType) -DataFactoryName '$DataFactoryName' -ResourceGroupName '$ResourceGroupName' -Name '$($artifact.Name)' -Force -ErrorAction Stop"
                Write-Host $removeAzDFCommand
                Invoke-Expression $removeAzDFCommand
            }
            catch {
                if ($_ -match '.*The document cannot be deleted since it is referenced by.*') {
                    Write-Host $_
                    $artToProcess.Add($artifact)
                }
                else {
                    throw $_
                }
            }
        }

        Remove-Artifacts $artToProcess $artfType
    }
}

foreach ($artfType in $artfTypes) {
    $getAzDFCommand = "Get-AzDataFactoryV2$($artfType) -DataFactoryName '$DataFactoryName' -ResourceGroupName '$ResourceGroupName'"
    Write-Output $getAzDFCommand

    $artifacts = Invoke-Expression $getAzDFCommand
    Write-Output $artifacts.Name

    Remove-Artifacts $artifacts $artfType
}
