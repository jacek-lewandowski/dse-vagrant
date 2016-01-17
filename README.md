# dse-vagrant

Allows to setup virtual machines to run 3 DSE nodes and KDC.
The installation scripts generate SSL keys, install and configures Kerberos KDC and generates keytabs.

The testing environment allows for running your local build of DSE on the virtual machines. 
All the `lib` and `build` directories are linked while all the other files, like configuration and scripts are copied to the virtual machines.
Such approach gives a nice advantages for everyday development - do not need to reinstall / reapply the configuration when you the code changes. Just need to build DSE locally and all lib and build directories are immediately used by virtual machines. No additional steps are needed.
 
## Installation:

Assumptions: you have VirtualBox, Vagrant and Java installed

1. `cd main` then `./install.sh` 
This may take a while, but it is performed only once. It will create virtual machines with Ubuntu Trusty 64 and install all the required software. It will ask you whether you want to destroy a machine <default> - answer yes. 
2. Your machines are set up and turned off. There are 4 machines: dse1, dse2, dse3, kdc. By default vagrant commands applies only to dse1.
3. Choose local DSE home which you would like to use on the virtual machines: `main/set-dse-home.sh <path-to-dse-home>`. It will create a symbolic link under dse-vagrant project to your DSE home dir.

At this point the setup, which you need to only once, is completed.

To run DSE:

1. Build your DSE locally with `./gradlew clean jar`
2. Run the machine: `cd main/vagrant` then `vagrant up <machine>`
3. Login to the machine: `cd main/vagrant` then `vagrant ssh <machine>`
4. Install DSE in the VM: In the VM shell: `/vagrant/dse-install.sh`
5. At this point DSE is installed at `/usr/local/dse` and belongs to the user `dse` whose password is `dse`

Step 4 can be repeated as often as you want. However, it is needed only in three cases:

1. Initial installation
2. Refresh configuration files and scripts. If during the development you change more than a source code, you need to refresh DSE installation by running `/vagrant/dse-install.sh`, so that those files are copied to the virtual machines).
3. The directory structure changes - for example, there is a new module, or some module has been removed. In this case refreshing the installation is needed to refresh symbolic links to your build and lib directories. 

## Running with Kerberos

Kerberos is installed and preconfigured. The realm name is `EXAMPLE.COM`. There are created service principals for all the nodes and they are included in particular `dse.keytab` files. Those files are automatically copied to `$DSE_HOME/resources/dse/conf/`, which is a default location of those files. All you need to do is switch authenticator in `cassandra.yaml` to Kerberos. Make sure that you start DSE from `$DSE_HOME` directory because some default paths are relative and it is assumed that the current directory is `$DSE_HOME`. 

There is also a user principal created `cassandra` with the password `dse`.

## Running with SSL

The setup scripts generate a complete set of SSL keys which are required to run DSE with and without SSL client authentication. `.keystore` located at `$DSE_HOME/resources/dse/conf/` includes a private key for the particular node. `.truststore` in the same directory contains certificates for nodes 1, 2, 3 and for the client (to allow for client-auth if enabled). To switch on SSL, just enable it `cassandra.yaml`. No need to set paths to keystores. 

There is also `.client-keystore` and `.client-truststore` which are to be used by client applications - the keystore includes the private key which is needed when client authentication is enabled. The truststore includes certificates for all the nodes.

All the keystores and truststores have the same password: cassandra
