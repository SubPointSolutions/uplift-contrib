# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Configring SQL accounts for CRM..."
Write-UpliftEnv

Configuration Configure_CRM_SQLUsers {

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 12.2.0.0

    Node localhost
    {
        $computerName = $env:COMPUTERNAME
        $instanceName = 'MSSQLSERVER'

        $adminsGroup  = "BUILTIN\Administrators";

        $domainAdminCreds = New-Object System.Management.Automation.PSCredential(
            "uplift\vagrant", 
             (ConvertTo-SecureString "vagrant" -AsPlainText -Force)
        )

        SqlServerLogin Add_AdministratorsGroup
        {
            Ensure               = 'Present'

            Name                 =  $adminsGroup
            LoginType            = 'WindowsGroup'
            
            ServerName           = $computerName
            InstanceName         = $instanceName
            
            PsDscRunAsCredential = $domainAdminCreds
        }

        SqlServerRole Grant_AdministratorsGroup_Db_Creator
        {
            Ensure               = 'Present'
            ServerRoleName       = 'db_creator'
            MembersToInclude     = $adminsGroup
            
            ServerName           = $computerName
            InstanceName         = $instanceName
            
            PsDscRunAsCredential = $domainAdminCreds

            DependsOn = @(
                '[SqlServerLogin]Add_AdministratorsGroup'
            )
        }

        SqlServerRole Grant_AdministratorsGroup_SecurityAdmin
        {
            Ensure               = 'Present'
            ServerRoleName       = 'securityadmin'
            MembersToInclude     = $adminsGroup
            
            ServerName           = $computerName
            InstanceName         = $instanceName
            
            PsDscRunAsCredential = $domainAdminCreds

            DependsOn = @(
                '[SqlServerLogin]Add_AdministratorsGroup'
            )
        }

        SqlServerRole Grant_AdministratorsGroup_SysAdmin
        {
            Ensure               = 'Present'
            ServerRoleName       = 'sysadmin'
            MembersToInclude     = $adminsGroup
            
            ServerName           = $computerName
            InstanceName         = $instanceName
            
            PsDscRunAsCredential = $domainAdminCreds

            DependsOn = @(
                '[SqlServerLogin]Add_AdministratorsGroup'
            )
        }
    }
}

$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            
            RetryCount = 10           
            RetryIntervalSec = 30
        }
    )
}

$configuration = Get-Command Configure_CRM_SQLUsers
Start-UpliftDSCConfiguration $configuration $config $True

exit 0