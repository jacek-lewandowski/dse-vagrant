#!/usr/bin/env bash

export basedir="$(cd "`dirname "$0"`"; pwd)"

cd "$basedir/vagrant/base"
./make_base_machine.sh

mkdir -p "$basedir/data"

"$basedir/set-dse-home.sh" /tmp

cd "$basedir/vagrant"
vagrant up dse1
vagrant halt dse1

vagrant up dse2
vagrant halt dse2

vagrant up dse3
vagrant halt dse3

vagrant up kdc
vagrant halt kdc

cd "$basedir"
./generate-ssl-keys.sh
