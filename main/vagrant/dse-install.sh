#!/usr/bin/env bash

if [ "$0" != "/vagrant/dse-install.sh" ]; then
    echo "This script should be run from the node shell"
    exit 1
fi

if [ "$USER" != "vagrant" ]; then
    echo "This script should be run as 'vagrant' user"
    exit 1
fi

DSE_HOME="/usr/local/dse"
DSE_BASE="/home/vagrant/dse"
DATA="/home/vagrant/data"

function installDSE {
  sudo rm -rf "$DSE_HOME"
  sudo mkdir "$DSE_HOME"

  sudo rsync -v -a --exclude=lib/ --exclude=.git/ --exclude=build/ --exclude=target/ --exclude=src/ --exclude=vagrant/ "$DSE_BASE/" "$DSE_HOME/"

  cd "$DSE_BASE"

  find . -type d -name "lib"   | egrep -v -E ".*/lib.*/lib.*" | egrep -v -E ".*/build.*/lib.*" | xargs -I {} sudo ln -T -v -f -s "$DSE_BASE/{}" "$DSE_HOME/{}"
  find . -type d -name "build" | egrep -v -E ".*/build.*/build.*"                              | xargs -I {} sudo ln -T -v -f -s "$DSE_BASE/{}" "$DSE_HOME/{}"

  sudo mkdir -p -v /var/lib/cassandra
  sudo mkdir -p -v /var/lib/spark
  sudo mkdir -p -v /var/log/cassandra
  sudo mkdir -p -v /var/log/spark

  cat /etc/bash.bashrc | grep '$PATH:$DSE_HOME/bin' > /dev/null
  if [ "$?" != "0" ]; then
    sudo bash -c 'echo "export DSE_HOME=/usr/local/dse" >> /etc/bash.bashrc'
    sudo bash -c 'echo '"'"'export PATH="$PATH:$DSE_HOME/bin"'"'"' >> /etc/bash.bashrc'
  fi
}

function configureDSE {
  local IP="$(ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')"
  local CASSANDRA_YAML="/usr/local/dse/resources/cassandra/conf/cassandra.yaml"
  local DSE_YAML="/usr/local/dse/resources/cassandra/conf/cassandra.yaml"

  sudo perl -i -p -e "s/^\s*listen_address:(.*)$/listen_address: $IP/" "$CASSANDRA_YAML"
  sudo perl -i -p -e "s/^\s*rpc_address:(.*)$/rpc_address: $IP/" "$CASSANDRA_YAML"
  sudo perl -i -p -e 's/^\s*\-\s*seeds:.*/          - seeds: "'$IP'"/' "$CASSANDRA_YAML"

  sudo cp "$DATA/$(cat /etc/hostname)/dse.keytab" "$DSE_HOME/resources/dse/conf/"
  sudo cp "$DATA/$(cat /etc/hostname)/.keystore" "$DSE_HOME/resources/dse/conf/"
  sudo cp "$DATA/.server-truststore" "$DSE_HOME/resources/dse/conf/.truststore"

  sudo perl -i -p -e "s/^\s*listen_address:(.*)$/listen_address: $IP/" "$CASSANDRA_YAML"
}

function fixPermissions() {
  sudo chown -R dse:dse "$DSE_HOME"
  sudo chown -R dse:dse /var/lib/cassandra
  sudo chown -R dse:dse /var/lib/spark
  sudo chown -R dse:dse /var/log/cassandra
  sudo chown -R dse:dse /var/log/spark
}

installDSE
configureDSE
fixPermissions
