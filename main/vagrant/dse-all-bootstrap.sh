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

useradd --create-home --user-group dse
usermod --password "$(echo dse | openssl passwd -1 -stdin)" dse

addIfMissing /etc/hosts "192.168.33.10 kdc"
addIfMissing /etc/hosts "192.168.33.11 dse1"
addIfMissing /etc/hosts "192.168.33.12 dse2"
addIfMissing /etc/hosts "192.168.33.13 dse3"

realm="EXAMPLE.COM"
kdc_host="192.168.33.10"
perl -i -p -e "s/^\s*\[realms\]\s*$/[realms]\n\t${realm} = {\n\t\tkdc = ${kdc_host}\n\t\tadmin_server = ${kdc_host}\n\t}\n/" /etc/krb5.conf
perl -i -p -e "s/^\s*default_realm\s*=.*$/\tdefault_realm = ${realm}/" /etc/krb5.conf

cp /vagrant/.java.login.config /home/dse/
chown dse:dse /home/dse/.java.login.config

# Some scripts uses find to look for JARs and other files. Since DSE installation will be based on symbolic links
# a regular find will not work. We need to implicitly add -L argument to make it follow symbolic links.
echo '/usr/bin/find -L "$@"' > /usr/local/sbin/find
chmod +x /usr/local/sbin/find
