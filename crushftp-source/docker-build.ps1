[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)] [string[]] $dockerRepository
)

Write-Host "Repos: $dockerRepository"
