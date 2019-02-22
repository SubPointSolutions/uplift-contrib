# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Configuring CRM PowerShell modules"
Write-UpliftEnv

# - install other DSC packages
$packages = @(

    @{ 
        Id = "Dynamics365Configuration"
        Version = "1.0"
    },

    @{ 
        Id = "CertificateDsc"
        Version = "4.1.0.0"
    }
     
)

Write-UpliftMessage "Installing DSC modules: $packages"
Install-UpliftPSModules $packages

exit 0