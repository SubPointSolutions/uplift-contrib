# Using `invoke-vagrant` 

The vagrant plugin provides a simplified configuration of DC, SQL, SharePoint and VS and designed to be used with uplift packer boxes.

The uplift project offers consistent Packer/Vagrant workflows and Vagrant boxes specifically designed for SharePoint professionals. It heavy lifts low-level details of the creation of domain controllers, SQL servers, SharePoint farms and Visual Studio installs by providing a codified workflow using Packer/Vagrant tooling.

## Installing `vagrant-uplift` plugin
`vagrant-uplift` is a normal Vagrant plugin distributed via rubygems.org. Refer to Vagrant documentation for additional information.

```shell
# listing installed plugins
vagrant plugin list

# installing vagrant-uplift plugin
vagrant plugin install vagrant-uplift 

# uninstalling vagrant-uplift plugin
vagrant plugin uninstall vagrant-uplift 
```

## Using `uplift-vagrant` 
The latest documentation can be found on the project repository:
* https://github.com/SubPointSolutions/uplift-vagrant