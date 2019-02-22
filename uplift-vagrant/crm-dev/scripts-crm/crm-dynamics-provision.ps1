# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Running CRM privision..."
Write-UpliftEnv

$crmModuleVersion  = (Get-InstalledModule Dynamics365Configuration).Version
$pullLogMinVersion = "1.0.0.0"

Write-UpliftMessage "CRM module version: Dynamics365Configuration $crmModuleVersion"

$dbHostName      = $env:COMPUTERNAME
$computerName    = ($env:COMPUTERNAME).Split('.')[0]

$resourceName    = Get-UpliftEnvVariable "UPLF_CRM_RESOURCE_NAME" "" "ms-dynamics-crm90-server-en"
$mediaDir        = "C:\_uplift_resources\$resourceName\latest\unpacked"
$licenceKey      = Get-UpliftEnvVariable "UPLF_CRM_LICENCE_KEY" "" "KKNV2-4YYK8-D8HWD-GDRMW-29YTW"

$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force

$CRMInstallAccountCredential        = New-Object System.Management.Automation.PSCredential( "uplift\_crmadmin", $securedPassword );
$CRMServiceAccountCredential        = New-Object System.Management.Automation.PSCredential( "uplift\_crmsrv", $securedPassword );
$DeploymentServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "uplift\_crmdplsrv", $securedPassword );
$SandboxServiceAccountCredential    = New-Object System.Management.Automation.PSCredential( "uplift\_crmsandbox", $securedPassword );
$VSSWriterServiceAccountCredential  = New-Object System.Management.Automation.PSCredential( "uplift\_crmvsswrit", $securedPassword );
$AsyncServiceAccountCredential      = New-Object System.Management.Automation.PSCredential( "uplift\_crmasync", $securedPassword );
$MonitoringServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "uplift\_crmmon", $securedPassword );

if($crmModuleVersion -gt $pullLogMinVersion) {
    Write-UpliftMessage  "Using -LogFilePullToOutput option"

    Install-Dynamics365Server `
        -MediaDir $mediaDir `
        -LicenseKey $licenceKey `
        -InstallDir "c:\Program Files\Microsoft Dynamics CRM" `
        -CreateDatabase `
        -SqlServer $dbHostName `
        -PrivUserGroup "CN=CRM01PrivUserGroup,OU=CRM groups,DC=uplift,DC=local" `
        -SQLAccessGroup "CN=CRM01SQLAccessGroup,OU=CRM groups,DC=uplift,DC=local" `
        -UserGroup "CN=CRM01UserGroup,OU=CRM groups,DC=uplift,DC=local" `
        -ReportingGroup "CN=CRM01ReportingGroup,OU=CRM groups,DC=uplift,DC=local" `
        -PrivReportingGroup "CN=CRM01PrivReportingGroup,OU=CRM groups,DC=uplift,DC=local" `
        -CrmServiceAccount $CRMServiceAccountCredential `
        -DeploymentServiceAccount $DeploymentServiceAccountCredential `
        -SandboxServiceAccount $SandboxServiceAccountCredential `
        -VSSWriterServiceAccount $VSSWriterServiceAccountCredential `
        -AsyncServiceAccount $AsyncServiceAccountCredential `
        -MonitoringServiceAccount $MonitoringServiceAccountCredential `
        -CreateWebSite `
        -WebSitePort 5555 `
        -WebSiteUrl "https://$computerName.uplift.local" `
        -Organization "Uplift Ltd." `
        -OrganizationUniqueName uplift `
        -BaseISOCurrencyCode USD `
        -BaseCurrencyName "US Dollar" `
        -BaseCurrencySymbol `$ `
        -BaseCurrencyPrecision 2 `
        -OrganizationCollation Latin1_General_CI_AI `
        -ReportingUrl ("http://" + $computerName + ":80/ReportServer") `
        -InstallAccount $CRMInstallAccountCredential `
        -LogFilePullToOutput
} else {
    Write-UpliftMessage  "Skipping -LogFilePullToOutput option, v1.0.0.0 module or older"

    Install-Dynamics365Server `
        -MediaDir $mediaDir `
        -LicenseKey $licenceKey `
        -InstallDir "c:\Program Files\Microsoft Dynamics CRM" `
        -CreateDatabase `
        -SqlServer $dbHostName `
        -PrivUserGroup "CN=CRM01PrivUserGroup,OU=CRM groups,DC=uplift,DC=local" `
        -SQLAccessGroup "CN=CRM01SQLAccessGroup,OU=CRM groups,DC=uplift,DC=local" `
        -UserGroup "CN=CRM01UserGroup,OU=CRM groups,DC=uplift,DC=local" `
        -ReportingGroup "CN=CRM01ReportingGroup,OU=CRM groups,DC=uplift,DC=local" `
        -PrivReportingGroup "CN=CRM01PrivReportingGroup,OU=CRM groups,DC=uplift,DC=local" `
        -CrmServiceAccount $CRMServiceAccountCredential `
        -DeploymentServiceAccount $DeploymentServiceAccountCredential `
        -SandboxServiceAccount $SandboxServiceAccountCredential `
        -VSSWriterServiceAccount $VSSWriterServiceAccountCredential `
        -AsyncServiceAccount $AsyncServiceAccountCredential `
        -MonitoringServiceAccount $MonitoringServiceAccountCredential `
        -CreateWebSite `
        -WebSitePort 5555 `
        -WebSiteUrl "https://$computerName.uplift.local" `
        -Organization "Uplift Ltd." `
        -OrganizationUniqueName uplift `
        -BaseISOCurrencyCode USD `
        -BaseCurrencyName "US Dollar" `
        -BaseCurrencySymbol `$ `
        -BaseCurrencyPrecision 2 `
        -OrganizationCollation Latin1_General_CI_AI `
        -ReportingUrl ("http://" + $computerName + ":80/ReportServer") `
        -InstallAccount $CRMInstallAccountCredential 
}

exit 0