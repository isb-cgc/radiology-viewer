# radiology-viewer

This repo contains scripts for launching the webapp radiology viewer VMs. There are four VMs: dicom-viewer-prod, dicom-viewer-dev, dicom-viewer-test and dicom-viewer-uat. To launch a vm, execute:

  $ build/buildVM.sh \<vm\>

where \<vm\> is one of prod|dev|test|uat.

This script will first create a static external IP address, also called dicomc-viewer-xxx, if such a IP address does not already exist. It will then delete any existing VM having that name and launch a new suitably configured VM. It will then scp copy and execute build/install_deps.sh on the new VM. install_deps.sh installs git and docker, performs apt-get update/upgrade, installs and configures nginx, tenable and clamav. install_deps.sh also clones the https://github.com/isb-cgc/ohif-viewer/tree/master repo into an ohif-viewer directory on the VM. When complete, install_deps.sh then reboots the VM.

On rebooting, the startup.sh script is executed, and calls run_viewer.sh, which, eventually executes start_ohif.sh. start_ohif.sh calls docker_compose, passing a script that pulls a number of docker images for dcm4chee, postresql, mongo, and the OHIF viewer from GCR and executes them.  These images were previously saved in  GCR. All such images are third party...not built by us.

