# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Running RS config..."
Write-UpliftEnv

Configuration Configure_SqlRS {

    Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 11.1.0.0

    Node localhost
    {
        SqlRS ReportingServicesConfig
        {
            InstanceName                 = 'MSSQLSERVER'
            DatabaseServerName           = 'localhost'
            DatabaseInstanceName         = 'MSSQLSERVER'

            #ReportServerVirtualDirectory = 'MyReportServer'
            
            ReportServerReservedUrl      = @( 'http://+:80' )
            
            #ReportsVirtualDirectory      = 'MyReports'
            #ReportsReservedUrl           = @( 'http://+:80', 'https://+:443' )
            #UseSsl                       = $true
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

$configuration = Get-Command Configure_SqlRS
Start-UpliftDSCConfiguration $configuration $config

exit 0