
# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Configuring CRM Default Web Site: 443 and 5555"
Write-UpliftEnv

Configuration CRMDefaultWebs
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    Import-DscResource -ModuleName CertificateDsc -ModuleVersion 4.1.0.0
    Import-DscResource -ModuleName xWebAdministration -ModuleVersion 1.19.0.0
    Import-DSCResource -Module xSystemSecurity -Name xIEEsc -ModuleVersion 1.4.0.0

    Node localhost
    {
        $securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
        $CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "uplift\_crmadmin", $securedPassword );

        $pfxPassword = "asd94y3475n";
        $securedPassword = ConvertTo-SecureString $pfxPassword -AsPlainText -Force
        $pfxCredential = New-Object System.Management.Automation.PSCredential( "fake", $securedPassword )

        $hostName = "$env:COMPUTERNAME.uplift.local";
        $pfxPath = "c:\certs\$hostName.pfx";
        $cerPath = "c:\certs\$hostName.cer";
        
        $pfx = New-Object -TypeName "System.Security.Cryptography.X509Certificates.X509Certificate2";
        $pfx.Import($pfxPath,$pfxPassword,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet);

        PfxImport crmhost
        {
            Thumbprint  = $pfx.thumbprint
            Path        = $pfxPath
            Location    = 'LocalMachine'
            Store       = 'My'
            Credential  = $pfxCredential
        }

        CertificateExport crmhost
        {
            Type        = 'CERT'
            Thumbprint  = $pfx.thumbprint
            Path        = $cerPath
            DependsOn   = "[PfxImport]crmhost"
        }

        CertificateImport crmhost
        {
            Thumbprint  = $pfx.thumbprint
            Location    = 'LocalMachine'
            Store       = 'Root'
            Path        = $cerPath
            DependsOn   = "[CertificateExport]crmhost"
        }

        xWebsite WA01Site
        {
            Name        = "Microsoft Dynamics CRM"
            State       = "Started"
            BindingInfo = @(
                MSFT_xWebBindingInformation {
                    Protocol = "HTTP"
                    Port = 5555
                }
                MSFT_xWebBindingInformation {
                    Protocol = "HTTPS"
                    Port = 443
                    CertificateThumbprint = $pfx.thumbprint
                    CertificateStoreName = "My"
                    HostName = "$env:COMPUTERNAME.uplift.local"
                    SslFlags = 1
                }
            )
        }

        Registry CrmLocalZone
        {
            Ensure                  = "Present"
            Key                     = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\$env:COMPUTERNAME.uplift.local"
            ValueName               = "https"
            ValueType               = "DWord"
            ValueData               = "1"
            PsDscRunAsCredential    = $CRMInstallAccountCredential
        }

        xIEEsc DisableIEEsc
        {
            IsEnabled   = $false;
            UserRole    = "Administrators"
        }

    }
}

$configuration = Get-Command CRMDefaultWebs
Start-UpliftDSCConfiguration $configuration $config -ExpectInDesiredState $True

exit 0