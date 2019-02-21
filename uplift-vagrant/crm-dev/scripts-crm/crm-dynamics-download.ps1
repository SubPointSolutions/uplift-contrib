# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Downloading CRM resource..."
Write-UpliftEnv

$resourceName = Get-UpliftEnvVariable "UPLF_CRM_RESOURCE_NAME" "" "ms-dynamics-crm90-server-en"
$serverUrl    = Get-UpliftEnvVariable "UPLF_HTTP_ADDR"
$uplifLocalRepository =  Get-UpliftEnvVariable "UPLF_LOCAL_REPOSITORY_PATH" "" "c:/_uplift_resources"

Write-UpliftMessage "Downloading resource: $resourceName"
pwsh -c Invoke-Uplift resource download-local $resourceName -server $serverUrl -repository $uplifLocalRepository

Write-UpliftMessage "Unpacking resource: $resourceName"

$filePath = "C:\_uplift_resources\$resourceName\latest\CRM9.0-Server-ENU-amd64.exe"
$directoryPath =  "C:\_uplift_resources\$resourceName\latest\unpacked"

Start-Process -FilePath $filePath -ArgumentList "/extract:$directoryPath /passive /quiet" -Wait -NoNewWindow

exit 0