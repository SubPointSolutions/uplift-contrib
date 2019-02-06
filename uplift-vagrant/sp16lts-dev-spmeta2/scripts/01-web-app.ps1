# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Configuration Intranet_WebApp_SharePointConfiguration {
   
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDsc -ModuleVersion "1.9.0.0"
 
    Node localhost {
        
        $ensureWebApp = 'Present'
        $machineName = $env:computerName

        # by default, uplift boxes should have domain 'uplift' and default vagrant user
        $setupUserName       = "uplift\vagrant"
        $setupUserPassword   = "vagrant" 
       
        $secureSetupUserPassword = ConvertTo-SecureString $setupUserPassword -AsPlainText -Force
        $setupUserCreds          = New-Object System.Management.Automation.PSCredential($setupUserName, $secureSetupUserPassword)
        
        # web app settings
        $deleteWebApp  = $Node.WebAppDelete
        if($deleteWebApp -eq $true) { $ensureWebApp = 'Absent' }

        $webAppUrl     = "http://" + $machineName 

        $webAppPort    = $Node.WebAppPort
        if($null -eq $webAppPort) { $webAppPort = 80; }
    
        # minimal config to create web app
        SPManagedAccount WebAppPoolManagedAccount  
        {
            Ensure = 'Present'

            AccountName          = $setupUserCreds.UserName
            Account              = $setupUserCreds
            PsDscRunAsCredential = $setupUserCreds
        }

        # web app config
        SPWebApplication WebApp
        {
            Ensure = $ensureWebApp

            Name                   = "Intranet - $webAppPort"
            ApplicationPool        = "Intranet Web App"
            ApplicationPoolAccount = $setupUserCreds.UserName
            AllowAnonymous         = $false

            # https://github.com/PowerShell/SharePointDsc/issues/707
            AuthenticationMethod   = "NTLM"
            DatabaseName           = "Intraner_Content_$webAppPort"
            Url                    = $webAppUrl
            Port                   = $webAppPort
            PsDscRunAsCredential   = $setupUserCreds

            DependsOn              = "[SPManagedAccount]WebAppPoolManagedAccount"
        }

        # root site collection config
        if($ensure -eq 'Present') {
            # create root site collection if Present is set for the web app
            SPSite RootSite
            {
                Url                      = $webAppUrl + ":" + $webAppPort
                OwnerAlias               = ($setupUserCreds.UserName)
                Name                     = "Intranet Root Site"
                Template                 = "STS#0"
                PsDscRunAsCredential     = $setupUserCreds
                DependsOn                = "[SPWebApplication]WebApp"
            }
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

            WebAppPort   = ($env:WEB_APP_PORT)
            WebAppDelete = ($env:WEB_APP_DELETE -ne $null)
        }
    )
}

Write-Host "Cleaning existing DSC config"
Remove-Item Intranet_WebApp_SharePointConfiguration -Force -Recurse -ErrorAction SilentlyContinue

Write-Host "Compiling DSC config"
. Intranet_WebApp_SharePointConfiguration -ConfigurationData $config

Write-Host "Starting DSC config"
Start-DscConfiguration -Path Intranet_WebApp_SharePointConfiguration -Force -Wait -Verbose