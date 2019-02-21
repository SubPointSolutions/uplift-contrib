# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Configuring CRM PowerShell modules"
Write-UpliftEnv

# - install other DSC packages
$packages = @(

    @{ 
        Id = "InvokeUplift" 
    },

    @{ 
        Id = "Dynamics365Configuration"
    },

    @{ 
        Id = "CertificateDsc"
        Version = "4.1.0.0"
    }
     
)

Write-UpliftMessage "Installing DSC modules: $packages"
Install-UpliftPSModules $packages

exit 0