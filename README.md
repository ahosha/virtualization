# virtualization
vagrant and terraform ci/virtualization project 

Vagrant:

https://www.vagrantup.com

1. Make sure that you have Vagrant and Oracle's VirtualBox installed on your computer and the parent folders of their executable files are added to the system PATH variable. If you followed the standard installation procedure, these folders are added automatically.



Install vagrant plugin in IntelliJ:   vagrant plugin expunge --reinstall

Vagrant usage:

From root dir (not provisioning)
./gradlew tasks
 ./gradlew vagrantUp
./gradlew vagrantDestroy



to run just script -> From provisioning dir :  vagrant provision
To ssh to the box ->From provisioning dir : vagrant ssh  
vagrant reload
 
 
 erraform:


Install :
brew install terraform

http://macappstore.org/terraform/

1. Add *.tf file in provisioning dir
2. Add TF_VAR_vsphere_user='your vsphere username' and TF_VAR_vsphere_password='your vsphere password' as environment variable

1. Put in plugin in build.gradle


https://q1git.canlab.ibm.com/docker/si-security-rust-scanner/blob/master/Dockerfile











##Set up workspace to work on RsyncService

1. Install terraform: preferably using Homebrew(it will set the required path variables)

2. Add TF_VAR_vsphere_user='your vsphere username' and TF_VAR_vsphere_password='your vsphere password' as environment variable


3. For testing only perspective copy the latest rpm name from develop branch of Anchor repo to ```gradle.properties``` and uncomment the provisioning comment from rsync.tf. Also create a folder named rpm under provisioning folder.


4. Run ``` ./gradlew  vsphereUp ``` to check if your project is setup for creating VM's on vsphere
Note : After checking the above command runs destroy the VM's using ```./gradlew vsphereDestroy```

5. Run ```./gradlew vsphereTest``` to run fvt test on VM machines. It would create VM's run test on the machine and will destroy for you

6. To run local fvt test run ```./gradlew fvtTest``` it would look for vsphere.env file for both the VM's so check under provision directory if the env files(storing the IP of VM's) are there.

7. There is a sample fvt test added under fvt folder with name Example.groovy that would help you to setup fvt for 2 VM's

8. All terraform provisioning is done through 'rsync.tf' that configures template for terraform VM's and 'vsphere.sh' that sets the required workspace in the VM's

9. Note: Check ip variable on anchor.toml on your local workspace before running ```vsphere gradle command```. It should be empty for now as it would be populated once you run any ```vsphere gradle command```

10. Check the rpm folder before running ```./gradlew vsphereUp``` there should not be any old rpm sitting there.

###TO DO Still in progress 


1. Adding vsphere and fvt test command on anchor CI branch pipeline

2. Document the steps for vagrant setup for Rsync Service

3. Refactoring more of groovy scripts for setting up multiple VM's and adding isolated environments on them

4. Adding script for checking the latest rpm for QA


