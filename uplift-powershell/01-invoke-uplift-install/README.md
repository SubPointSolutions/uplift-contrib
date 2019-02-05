# Using `invoke-uplift` module

`invoke-uplift` is a PowerShell6 module which simplifies file based routines. It is a general purpose tool and can be used freely to automate file downloads, checksum validation, file service and transferring. For example, json configuration can be used to specify which files to download. invoke-uplift will build a local repository with downloaded files which then can be used to serve files locally or uploaded to Azure/AWS storages.

This module is an essential part of the uplift project. We rely heavily on its automation to download and build local repository containing all ISOs, installation media, service packs and patches.

* https://github.com/SubPointSolutions/uplift-powershell

## Installing `invoke-uplift` 
The major versions of the module can be installed from the PowerShell gallery, and the latest `dev` and `beta` versions can be found on the `myget` feed.

* https://www.powershellgallery.com/packages/InvokeUplift
* https://www.myget.org/feed/subpointsolutions-staging/package/nuget/InvokeUplift

> Be aware that this is a PowerShell6 module so use `pwsh` instead of `powershell` all the time!

```powershell
# installing from the PowerShell
pwsh -c 'Install-Module -Name InvokeUplift'

# installing from the staging feed
# register 'subpointsolutions-staging' repository
Register-PSRepository -Name "subpointsolutions-staging" -SourceLocation "https://www.myget.org/F/subpointsolutions-staging/api/v2"

# install module under PowerShell 6
pwsh -c 'Install-Module -Name "InvokeUplift" -Repository "subpointsolutions-staging" '
```

## Using `invoke-uplift` 
The latest documentation can be found on the project repository:
* https://github.com/SubPointSolutions/uplift-powershell