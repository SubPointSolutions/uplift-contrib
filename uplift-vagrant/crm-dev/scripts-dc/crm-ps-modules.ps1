# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Installing PowerShell Modules..."
Write-UpliftEnv

# https://github.com/shurick81/vm-devops-starter/blob/dev/infrastructure/images/basepsmodules.ps1
# adpsmodules.ps1"

$packages = @(

    @{ 
        Id = "xActiveDirectory";       
        Version = "2.21.0.0" 
    }
)

Write-UpliftMessage "Installing DSC modules: $packages"
Install-UpliftPSModules $packages

exit 0