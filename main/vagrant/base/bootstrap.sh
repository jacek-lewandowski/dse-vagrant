#!/usr/bin/env bash

function addIfMissing {
  local path="$1"
  local toAdd="$2"
  cat "$path" | grep "$toAdd" > /dev/null
  if [ "$?" != "0" ]; then
    echo "$toAdd" >> "$path"
  fi
}

set -x

apt-get -y -q update
apt-get -y -q upgrade
apt-get -y -q install software-properties-common htop
apt-get -y -q install mc

locale-gen UTF-8 en_US en_US.UTF-8
dpkg-reconfigure locales

addIfMissing /etc/bash.bashrc 'export LC_CTYPE=en_US.UTF-8'
addIfMissing /etc/bash.bashrc 'export LC_ALL=en_US.UTF-8'

add-apt-repository -y ppa:webupd8team/java
apt-get -y -q update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
apt-get -y -q install oracle-java8-installer
apt-get -y -q install oracle-java8-unlimited-jce-policy
update-java-alternatives -s java-8-oracle

apt-get -y -q install libjna-java libcommons-daemon-java python-support

DEBIAN_FRONTEND=noninteractive apt-get -y -q install krb5-user

apt-get install rng-tools
rngd -r /dev/urandom

apt-get clean
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c && exit

