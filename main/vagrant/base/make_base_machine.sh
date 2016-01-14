#!/usr/bin/env bash

set -x

vagrant box remove dse_vm
vagrant up
vagrant package --output dse_vm.box
vagrant box add dse_vm dse_vm.box
vagrant destroy
