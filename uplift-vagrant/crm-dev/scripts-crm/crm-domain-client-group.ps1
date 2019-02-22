# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Configuring CRM local admin group..."
Write-UpliftEnv

Configuration Configure_CRMLocalAdminGroup {
    
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    
    Node localhost
    {
        Group AdminGroup
        {
            GroupName           = "Administrators"
            # vagrant:vagrant should have access, no Credential needed
            # Credential          = $DomainAdminCredential
            MembersToInclude    = @(
                "uplift\CRM01PrivUserGroup",
                "uplift\_crmasync",
                "uplift\_crmsrv",
                "uplift\_crmdplsrv",
                "uplift\_ssrs"
            )
        }

        # The account specified to run the Dynamics 365 application does not have Performance Counter permissions.
        Group PerformanceLogUsers
        {
            GroupName  = "Performance Log Users"
            MembersToInclude    = @(
                "uplift\CRM01PrivUserGroup",
                "uplift\_crmasync",
                "uplift\_crmsrv",
                "uplift\_crmdplsrv",
                "uplift\_ssrs"
            )
        }
        
    }
}

$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            RetryCount = 10
            RetryIntervalSec = 30
        }
    )
}

$configuration = Get-Command Configure_CRMLocalAdminGroup
Start-UpliftDSCConfiguration $configuration $config $True

exit 0