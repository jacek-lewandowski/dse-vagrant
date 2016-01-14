#!/usr/bin/env bash

set -x

echo "kdc" > "/etc/hostname"

DEBIAN_FRONTEND=noninteractive apt-get install -y -qq krb5-kdc krb5-admin-server

kdb5_util create -s -P dse
/etc/init.d/krb5-kdc start || true
/etc/init.d/krb5-admin-server start || true
if [ ! -r /etc/krb5kdc/kadm5.acl ] ; then
    cat <<EOF >/etc/krb5kdc/kadm5.acl
# This file Is the access control list for krb5 administration.
# When this file is edited run /etc/init.d/krb5-admin-server restart to activate
# One common way to set up Kerberos administration is to allow any principal
# ending in /admin  is given full administrative rights.
# To enable this, uncomment the following line:
# */admin *
EOF
    fi

export datadir="/home/vagrant/data"

/usr/sbin/kadmin.local -q 'addprinc -randkey dse/dse1@EXAMPLE.COM'
/usr/sbin/kadmin.local -q 'addprinc -randkey dse/dse2@EXAMPLE.COM'
/usr/sbin/kadmin.local -q 'addprinc -randkey dse/dse3@EXAMPLE.COM'
/usr/sbin/kadmin.local -q 'addprinc -randkey HTTP/dse1@EXAMPLE.COM'
/usr/sbin/kadmin.local -q 'addprinc -randkey HTTP/dse2@EXAMPLE.COM'
/usr/sbin/kadmin.local -q 'addprinc -randkey HTTP/dse3@EXAMPLE.COM'
/usr/sbin/kadmin.local -q 'ktadd -k /home/vagrant/data/dse1/dse.keytab dse/dse1@EXAMPLE.COM'
/usr/sbin/kadmin.local -q 'ktadd -k /home/vagrant/data/dse2/dse.keytab dse/dse2@EXAMPLE.COM'
/usr/sbin/kadmin.local -q 'ktadd -k /home/vagrant/data/dse3/dse.keytab dse/dse3@EXAMPLE.COM'
/usr/sbin/kadmin.local -q 'ktadd -k /home/vagrant/data/dse1/dse.keytab HTTP/dse1@EXAMPLE.COM'
/usr/sbin/kadmin.local -q 'ktadd -k /home/vagrant/data/dse2/dse.keytab HTTP/dse2@EXAMPLE.COM'
/usr/sbin/kadmin.local -q 'ktadd -k /home/vagrant/data/dse3/dse.keytab HTTP/dse3@EXAMPLE.COM'

/usr/sbin/kadmin.local -q 'addprinc -pw dse cassandra@EXAMPLE.COM'
