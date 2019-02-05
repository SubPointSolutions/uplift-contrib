# uplift-contrib
This repository contains examples and how-tos for the uplift project.

The uplift project offers consistent Packer/Vagrant workflows and Vagrant boxes specifically designed for SharePoint professionals. It heavy lifts low-level details of the creation of domain controllers, SQL servers, SharePoint farms and Visual Studio installs by providing a codified workflow using Packer/Vagrant tooling.

## How this works
The uplift project is split into several repositories to address particular a piece of functionality:

* [uplift-powershell](https://github.com/SubPointSolutions/uplift-powershell) - reusable PowerShell modules
* [uplift-packer](https://github.com/SubPointSolutions/uplift-packer) - Packer templates for SharePoint professionals
* [uplift-vagrant](https://github.com/SubPointSolutions/uplift-vagrant) - Vagrant plugin to simplify Windows infrastructure provisioning 
* [uplift-cicd-jenkins2](https://github.com/SubPointSolutions/uplift-cicd-jenkins2) - Jenkins server and pipelines to build uplift Packer images and Vagrant boxes
* [uplift-uplift-contrib](https://github.com/SubPointSolutions/uplift-contrib) - examples and how-tos for the uplift project

The current repository houses examples and how-tos for the uplift project.

## Using `uplift-contrib` project 
All examples are organised into subfolders to address a particular area of the uplift project: downloading binaries, using PowerShell modules, building Packer images, customising Packer images and Vagrant boxes, and so on. Refer to a particular subfolder and README file for more information.

## Feature requests, support and contributions
All contributions are welcome. If you have an idea, create [a new GitHub issue](https://github.com/SubPointSolutions/uplift-contrib/issues). Feel free to edit existing content and make a PR for this as well.