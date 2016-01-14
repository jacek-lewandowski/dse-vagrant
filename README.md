# dse-vagrant

Allows to setup virtual machines to run 3 DSE nodes.
The installation scripts generate SSL keys, install and configures Kerberos KDC and generates keytabs.

The testing environment allows for running your local build of DSE on the virtual machines. 
All the `lib` and `build` directories are linked while all the other files, like configuration and scripts are copied to the virtual machines.
Such approach gives you very fast re-installation of DSE on the nodes when your code changes (few seconds). 

Installation:

Assumptions: you have VirtualBox, Vagrant and Java installed

1. `cd main` then `./install.sh`
This may take a while, but it is performed only once. It will create virtual machines with Ubuntu Trusty 64 and install all the required software. It will ask you whether you want to destroy a machine <default> - answer yes. 
2. Your machines are set up and turned off. There are 4 machines: dse1, dse2, dse3, kdc. By default all vagrant commands applies only to dse1.
3. Choose local DSE home which you would like to use on the virtual machines: `main/set-dse-home.sh <path-to-dse-home>`

At this point the setup, which you need to only once, is completed.

To run DSE:
1. Build your DSE locally with `./gradlew clean jar`
2. Run the machine: `cd main/vagrant` then `vagrant up <machine>`
3. Login to the machine: `cd main/vagrant` then `vagrant ssh <machine>`
4. Install DSE in the VM: In the VM shell: `/vagrant/dse-install.sh`
5. At this point DSE is installed at `/usr/local/dse` and belongs to the user `dse` whose password is `dse`
6. Step 4 can be repeated as often as you want
7. If you install for the first time, exit shell and open it again to reload bash rc files which includes paths and env variables
