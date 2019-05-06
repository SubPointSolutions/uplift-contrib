# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Fixing IIS 10 after sysprep"
Write-UpliftEnv

# IIS 10 gets broken after sysprep

# Windows could not start the IIS Admin Service on Local Computer. 
# For more information, review the System Event Log. If this is a non-Microsoft service, 
# contact the service vendor, and refer to service-specific error code -2146893818.

# http://findnerd.com/list/view/How-to-resolve-error-Could-not-start-the-IIS-Admin-Service---error-code--2146893818/4269/

$iisVersion = get-itemproperty HKLM:\SOFTWARE\Microsoft\InetStp\ 

Write-UpliftMessage "Current IIS setup:"
$iisVersion

if($null -ne $iisVersion -and $iisVersion.MajorVersion -eq 10) {
    Write-UpliftMessage "[~] Detected IIS 10"
    Write-UpliftMessage "Uninstalling feature:  Web-Metabase, a reboot is required"

    Uninstall-WindowsFeature Web-Metabase

} else {
    Write-UpliftMessage "[+] Detected IIS $($iisVersion.MajorVersion)"
    Write-UpliftMessage "No actions or reboots are required"
}

exit 0