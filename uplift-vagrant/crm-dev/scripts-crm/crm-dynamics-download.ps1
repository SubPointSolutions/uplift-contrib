# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Downloading CRM resource..."
Write-UpliftEnv

$resourceName = Get-UpliftEnvVariable "UPLF_CRM_RESOURCE_NAME" "" "ms-dynamics-crm90-server-en"
$serverUrl    = Get-UpliftEnvVariable "UPLF_HTTP_ADDR"

$uplifLocalRepository =  Get-UpliftEnvVariable "UPLF_LOCAL_REPOSITORY_PATH" "" "c:/_uplift_resources"

# always turn into http, it might be 10.0.2.2 address only
# uplift needs explicit http/https only
if($serverUrl.ToLower().StartsWith("http") -eq $False) {
    $serverUrl = "http://" + $serverUrl
}

Write-UpliftMessage "Downloading resource: $resourceName"
pwsh -c Invoke-Uplift resource download-local $resourceName -server $serverUrl -repository $uplifLocalRepository

Write-UpliftMessage "Unpacking resource: $resourceName"

$resourceLatestFolder = "$uplifLocalRepository\$resourceName\latest"
$filePath = Find-UpliftFileInPath $resourceLatestFolder

$directoryPath =  "$uplifLocalRepository\$resourceName\latest\unpacked"

Start-Process -FilePath $filePath -ArgumentList "/extract:$directoryPath /passive /quiet" -Wait -NoNewWindow

exit 0