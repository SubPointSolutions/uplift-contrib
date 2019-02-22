
# fail on errors and include uplift helpers
$ErrorActionPreference = "Stop"

Import-Module Uplift.Core

Write-UpliftMessage "Creating self-signed cert for CRM..."
Write-UpliftEnv

$certPassword = "asd94y3475n";

$pfxPass = ConvertTo-SecureString $certPassword -AsPlainText -Force;
New-Item c:\certs -ItemType Directory
@(
    "$env:COMPUTERNAME.uplift.local"
) | % {
    $hostName = $_;

    $cert = New-SelfSignedCertificate -DnsName $hostName -CertStoreLocation Cert:\LocalMachine\My;
    
    $cert | Export-PfxCertificate -FilePath "c:\certs\$hostName.pfx" -Password $pfxPass -Force | Out-Null;
    $cert | Remove-Item -Force;
}

exit 0