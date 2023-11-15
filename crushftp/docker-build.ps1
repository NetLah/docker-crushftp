[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)] [string] $imageTag = 'dev',
    [Parameter(Mandatory = $false)] [string[]] $dockerRepository,
    [Parameter(Mandatory = $false)] [string] $baseImageRepos,
    [Parameter(Mandatory = $false)] [string] $crushFtpVersion,
    [Parameter(Mandatory = $false)] [string] $source,
    [Parameter(Mandatory = $false)] [switch] $WhatIf
)

$dockerImages = @()
foreach ($dockerRepos in $dockerRepository) {
    $dockerImages += @("$($dockerRepos):$($imageTag)")
}

$params = @('build', '.')

if ($baseImageRepos) {
    Write-Verbose "REPO: $baseImageRepos"
    $params += @('--build-arg', "REPO=$baseImageRepos")
}

if ($crushFtpVersion) {
    Write-Verbose "CRUSHFTP_VERSION: $crushFtpVersion"
    $params += @('--build-arg', "CRUSHFTP_VERSION=$crushFtpVersion")
}

if ($source) {
    Write-Verbose "SOURCE: $source"
    $params += @('--build-arg', "SOURCE=$source")
}

$params += @('--pull', '--progress=plain')

Write-Output "Docker images: $dockerImages"
[bool]$isGitHubAction = "$Env:GITHUB_ACTIONS" -eq $true
if (!$isGitHubAction) {
    foreach ($dockerImage in $dockerImages) {
        $params += @("--cache-from=$($dockerImage)")
    }
}

foreach ($dockerImage in $dockerImages) {
    $params += @("--tag=$($dockerImage)")
}

Write-Verbose "Execute: docker $params"
docker @params
if (!$?) {
    $saveLASTEXITCODE = $LASTEXITCODE
    Write-Error "docker build failed (exit=$saveLASTEXITCODE)"
    exit $saveLASTEXITCODE
}

if ($WhatIf) {
    Write-Host "Skipped pushing docker image"
}
elseif ($dockerImages) {
    Write-Host "Pushing docker images"
    foreach ($dockerImage in $dockerImages) {
        docker push $dockerImage
        if (!$?) {
            $saveLASTEXITCODE = $LASTEXITCODE
            Write-Error "docker push failed (exit=$saveLASTEXITCODE)"
            exit $saveLASTEXITCODE
        }
    }
}
