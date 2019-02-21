# fail on errors and include $simpleDomainName helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Configuring DC with CRM specific settings"
Write-UpliftEnv

$domainName = "uplift"

$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
$SqlRSAccountCredential = New-Object System.Management.Automation.PSCredential( "$domainName\_ssrs", $securedPassword );
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "$domainName\_crmadmin", $securedPassword );
$CRMServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$domainName\_crmsrv", $securedPassword );
$DeploymentServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$domainName\_crmdplsrv", $securedPassword );
$SandboxServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$domainName\_crmsandbox", $securedPassword );
$VSSWriterServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$domainName\_crmvsswrit", $securedPassword );
$AsyncServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$domainName\_crmasync", $securedPassword );
$MonitoringServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$domainName\_crmmon", $securedPassword );

Configuration ConfigureDomainForCRM
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory -ModuleVersion 2.21.0.0

    Node localhost
    {
        $domainName = $Node.DomainName
        $simpleDomainName = $domainName.Split('.')[0]

        $SqlRSAccountCredential = $Node.SqlRSAccountCredential
        $CRMInstallAccountCredential = $Node.CRMInstallAccountCredential
        $CRMServiceAccountCredential = $Node.CRMServiceAccountCredential
        $DeploymentServiceAccountCredential = $Node.DeploymentServiceAccountCredential
        $SandboxServiceAccountCredential = $Node.SandboxServiceAccountCredential
        $VSSWriterServiceAccountCredential = $Node.VSSWriterServiceAccountCredential
        $AsyncServiceAccountCredential = $Node.AsyncServiceAccountCredential
        $MonitoringServiceAccountCredential = $Node.MonitoringServiceAccountCredential

        xADUser SqlRSAccountCredentialUser
        {
            DomainName              = $domainName
            UserName                = $SqlRSAccountCredential.GetNetworkCredential().UserName
            Password                = $SqlRSAccountCredential
            PasswordNeverExpires    = $true
        }
        
        xADUser CRMInstallAccountUser
        {
            DomainName              = $domainName
            UserName                = $CRMInstallAccountCredential.GetNetworkCredential().UserName
            Password                = $CRMInstallAccountCredential
            PasswordNeverExpires    = $true
        }
        
        xADUser CRMServiceAccountUser
        {
            DomainName              = $domainName
            UserName                = $CRMServiceAccountCredential.GetNetworkCredential().UserName
            Password                = $CRMServiceAccountCredential
            PasswordNeverExpires    = $true
        }

        xADUser DeploymentServiceAccountUser
        {
            DomainName              = $domainName
            UserName                = $DeploymentServiceAccountCredential.GetNetworkCredential().UserName
            Password                = $DeploymentServiceAccountCredential
            PasswordNeverExpires    = $true
        }

        xADUser SandboxServiceAccountUser
        {
            DomainName              = $domainName
            UserName                = $SandboxServiceAccountCredential.GetNetworkCredential().UserName
            Password                = $SandboxServiceAccountCredential
            PasswordNeverExpires    = $true
        }

        xADUser VSSWriterServiceAccountUser
        {
            DomainName              = $domainName
            UserName                = $VSSWriterServiceAccountCredential.GetNetworkCredential().UserName
            Password                = $VSSWriterServiceAccountCredential
            PasswordNeverExpires    = $true
        }

        xADUser AsyncServiceAccountUser
        {
            DomainName              = $domainName
            UserName                = $AsyncServiceAccountCredential.GetNetworkCredential().UserName
            Password                = $AsyncServiceAccountCredential
            PasswordNeverExpires    = $true
        }

        xADUser MonitoringServiceAccountUser
        {
            DomainName              = $domainName
            UserName                = $MonitoringServiceAccountCredential.GetNetworkCredential().UserName
            Password                = $MonitoringServiceAccountCredential
            PasswordNeverExpires    = $true
        }

        xADOrganizationalUnit CRMGroupsOU
        {
           Name = "CRM groups"
           Path = "DC=$simpleDomainName,DC=local"
        }

        xADGroup CRMPrivUserGroup
        {
            GroupName           = "CRM01PrivUserGroup"
            MembersToInclude    = $CRMInstallAccountCredential.GetNetworkCredential().UserName
            GroupScope          = "Universal"
            Path                = "OU=CRM groups,DC=$simpleDomainName,DC=local"
            DependsOn           = "[xADUser]CRMInstallAccountUser"
        }
        
        xADObjectPermissionEntry OUPermissions
        {
            Ensure                              = 'Present'
            Path                                = "OU=CRM groups,DC=$simpleDomainName,DC=local"
            IdentityReference                   = "$simpleDomainName\CRM01PrivUserGroup"
            ActiveDirectoryRights               = 'GenericAll'
            AccessControlType                   = 'Allow'
            ObjectType                          = '00000000-0000-0000-0000-000000000000'
            ActiveDirectorySecurityInheritance  = 'All'
            InheritedObjectType                 = '00000000-0000-0000-0000-000000000000'
            DependsOn                           = "[xADGroup]CRMPrivUserGroup"
        }
    
        xADGroup CRMSQLAccessGroup
        {
            GroupName   = "CRM01SQLAccessGroup"
            GroupScope  = "Universal"
            Path        = "OU=CRM groups,DC=$simpleDomainName,DC=local"
        }

        xADGroup CRMUserGroup
        {
            GroupName   = "CRM01UserGroup"
            Path        = "OU=CRM groups,DC=$simpleDomainName,DC=local"
        }

        xADGroup CRMReportingGroup
        {
            GroupName   = "CRM01ReportingGroup"
            GroupScope  = "Universal"
            Path        = "OU=CRM groups,DC=$simpleDomainName,DC=local"
        }

        xADGroup CRMPrivReportingGroup
        {
            GroupName           = "CRM01PrivReportingGroup"
            MembersToInclude    = $SqlRSAccountCredential.GetNetworkCredential().UserName
            GroupScope          = "Universal"
            Path                = "OU=CRM groups,DC=$simpleDomainName,DC=local"
        }

        xADGroup EnterpriseAdminGroup
        {
            GroupName   = "Enterprise Admins"
            MembersToInclude    = $CRMInstallAccountCredential.GetNetworkCredential().UserName
        }

        xADGroup DomainAdminGroup
        {
            GroupName   = "Domain Admins"
            MembersToInclude    = $CRMInstallAccountCredential.GetNetworkCredential().UserName
        }

        xADGroup Administrators
        {
            GroupName   = "Administrators"
            MembersToInclude    = $CRMInstallAccountCredential.GetNetworkCredential().UserName
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

            DomainName = "uplift.local"

            SqlRSAccountCredential = $SqlRSAccountCredential 
            CRMInstallAccountCredential = $CRMInstallAccountCredential 
            CRMServiceAccountCredential = $CRMServiceAccountCredential 
            DeploymentServiceAccountCredential = $DeploymentServiceAccountCredential 
            SandboxServiceAccountCredential = $SandboxServiceAccountCredential 
            VSSWriterServiceAccountCredential = $VSSWriterServiceAccountCredential 
            AsyncServiceAccountCredential = $AsyncServiceAccountCredential 
            MonitoringServiceAccountCredential = $MonitoringServiceAccountCredential
        }
    )
}

$configuration = Get-Command ConfigureDomainForCRM
Start-UpliftDSCConfiguration $configuration $config $True

exit 0