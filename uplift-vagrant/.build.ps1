param(
    $vagrantFolder = "sp16lts-dev",
    
    $UPLF_VAGRANT_BOX_NAME = $null,
    $UPLF_VBMANAGE_MACHINEFOLDER = $null,

    $UPLF_HTTP_DIRECTORY = $null
)

$dirPath = $BuildRoot

. "$dirPath/.build-helpers.ps1"


Enter-Build {

    $httpDirectoryPath = $UPLF_HTTP_DIRECTORY
    if( $null -eq $httpDirectoryPath ) { $httpDirectoryPath = $env:UPLF_HTTP_DIRECTORY }

    if( $null -ne $httpDirectoryPath ) {
        Write-BuildInfoMessage "Starring local http server: $httpDirectoryPath"

        $port = Get-RandomUsablePort
        $httpServerJob  = Start-LocalHttpServer $port $httpDirectoryPath

        $binAddress = ("10.0.2.2:" +  $port )
        Write-BuildInfoMessage "Setting UPLF_BIN_REPO_HTTP_ADDR: $binAddress"
        $ENV:UPLF_BIN_REPO_HTTP_ADDR = $binAddress
    } else {
        Write-BuildInfoMessage "Skipping local http server"
    }    
}

# Synopsis: Tests newly created vagrant box
task VagrantBoxTest {
    #exec {
        Write-BuildInfoMessage "Testing vagrant config, folder: $vagrantFolder"
        $vagrantCwd = $vagrantFolder

        try {
            if($null -ne $UPLF_VAGRANT_BOX_NAME) {
                Write-BuildInfoMessage "Using box name: $UPLF_VAGRANT_BOX_NAME"
                $ENV:UPLF_VAGRANT_BOX_NAME = $UPLF_VAGRANT_BOX_NAME
            } else {
                Write-BuildInfoMessage "Using default box in the Vagrantfile or ENV: $($env:UPLF_VAGRANT_BOX_NAME)"
            }

            if ($null -ne $env:UPLF_VBMANAGE_MACHINEFOLDER) {
                Write-BuildInfoMessage "Using ENV machine folder: $($env:UPLF_VBMANAGE_MACHINEFOLDER)"
                vboxmanage setproperty machinefolder $env:UPLF_VBMANAGE_MACHINEFOLDER
            }

            if ($null -ne $UPLF_VBMANAGE_MACHINEFOLDER) {
                Write-BuildInfoMessage "Using custom machine folder: $UPLF_VBMANAGE_MACHINEFOLDER"
                vboxmanage setproperty machinefolder $UPLF_VBMANAGE_MACHINEFOLDER
            }

            # Set-VagrantEnvVariables

            Write-BuildInfoMessage "Running: vagrant validate"
            pwsh -c "cd $vagrantCwd; vagrant validate"
            Confirm-ExitCode $LASTEXITCODE "Failed: vagrant validate"

            Write-BuildInfoMessage "Running: vagrant status"
            pwsh -c "cd $vagrantCwd; vagrant status"

            Write-BuildInfoMessage "Running: vagrant clean up script"
            pwsh -c "cd $vagrantCwd; . ./.vagrant-cleanup.ps1"
            Confirm-ExitCode $LASTEXITCODE "Failed: vagrant clean up script"
        
            # test
            Write-BuildInfoMessage "Running: vagrant-test.ps1"
            pwsh -c "cd $vagrantCwd; . ./.vagrant-test.ps1"
            Confirm-ExitCode $LASTEXITCODE "Failed: vagrant-test.ps1"

            # survived!
            Write-BuildWarningMessage "[+] PASSED ALL VAGRANT TESTS! This box looks really cool!"
        }
        catch {
            Write-BuildErrorMessage "ERR: $_"
            throw "Failed vagrant testing: $_"
        }
        finally {
            Write-BuildInfoMessage "Running: final vagrant clean up script"
            pwsh -c "cd $vagrantCwd; . ./.vagrant-cleanup.ps1"

            if ($null -ne $UPLF_VBMANAGE_MACHINEFOLDER) {
                vboxmanage setproperty machinefolder default
            }
        }
    #}
}
