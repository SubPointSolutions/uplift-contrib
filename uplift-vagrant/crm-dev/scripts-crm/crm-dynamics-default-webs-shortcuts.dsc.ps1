# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Running CRM Shortcuts..."

Configuration CRM_Shortcuts
{
    Import-DscResource -ModuleName DSCR_Shortcut -ModuleVersion '1.3.7'

    $desktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")

    cShortcut Crm_Web_Http
    {
        Path      = "$desktopPath\CRM HTTPS.lnk"
        Target    = "C:\Program Files\Internet Explorer\iexplore.exe"
        Arguments = 'https://crm.uplift.local'
    }

    cShortcut Crm_Web_Https
    {
        Path      = "$desktopPath\CRM HTTP.lnk"
        Target    = "C:\Program Files\Internet Explorer\iexplore.exe"
        Arguments = 'http://crm.uplift.local:5555'
    }
}

$configuration = Get-Command CRM_Shortcuts
Start-UpliftDSCConfiguration $configuration $config -ExpectInDesiredState $True

exit 0