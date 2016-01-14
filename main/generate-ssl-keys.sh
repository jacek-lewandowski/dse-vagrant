#!/usr/bin/env bash

# This script generates SSL keystores and truststores. The following files are generated:
# data/dse1/.keystore      - contains private key and certificate for node 1
# data/dse2/.keystore      - contains private key and certificate for node 2
# data/dse3/.keystore      - contains private key and certificate for node 3
# data/.server-truststore  - contains certificates for nodes 1, 2, 3 and for client (to allow for client-auth)
# data/.client-keystore    - contains private key and certificate for client (to allow for client-auth)
# data/.client-truststore  - contains certificates for nodes 1, 2, 3
# All the keystores and truststores have the same password: cassandra

set -x

export basedir="$(cd "`dirname "$0"`"; pwd)"

find "$basedir/data" -name "*.cer" | xargs -- rm -f
find "$basedir/data" -name "*keystore" | xargs -- rm -f
find "$basedir/data" -name "*truststore" | xargs -- rm -f

mkdir -p "$basedir/data/dse1"
mkdir -p "$basedir/data/dse2"
mkdir -p "$basedir/data/dse3"

keytool -genkey -noprompt -dname CN=Unknown -trustcacerts -keypass cassandra -storepass cassandra -keyalg RSA -alias dse1 -keystore "$basedir/data/dse1/.keystore"
keytool -genkey -noprompt -dname CN=Unknown -trustcacerts -keypass cassandra -storepass cassandra -keyalg RSA -alias dse2 -keystore "$basedir/data/dse2/.keystore"
keytool -genkey -noprompt -dname CN=Unknown -trustcacerts -keypass cassandra -storepass cassandra -keyalg RSA -alias dse3 -keystore "$basedir/data/dse3/.keystore"
keytool -genkey -noprompt -dname CN=Unknown -trustcacerts -keypass cassandra -storepass cassandra -keyalg RSA -alias cassandra -keystore "$basedir/data/.client-keystore"

keytool -export -noprompt -trustcacerts -alias dse1 -file "$basedir/data/dse1/dse.cer" -storepass cassandra -keystore "$basedir/data/dse1/.keystore"
keytool -export -noprompt -trustcacerts -alias dse2 -file "$basedir/data/dse2/dse.cer" -storepass cassandra -keystore "$basedir/data/dse2/.keystore"
keytool -export -noprompt -trustcacerts -alias dse3 -file "$basedir/data/dse3/dse.cer" -storepass cassandra -keystore "$basedir/data/dse3/.keystore"
keytool -export -noprompt -trustcacerts -alias cassandra -file "$basedir/data/cassandra.cer" -storepass cassandra -keystore "$basedir/data/.client-keystore"

keytool -import -v -noprompt -trustcacerts -alias dse1 -file "$basedir/data/dse1/dse.cer" -storepass cassandra -keystore "$basedir/data/.server-truststore"
keytool -import -v -noprompt -trustcacerts -alias dse2 -file "$basedir/data/dse2/dse.cer" -storepass cassandra -keystore "$basedir/data/.server-truststore"
keytool -import -v -noprompt -trustcacerts -alias dse3 -file "$basedir/data/dse3/dse.cer" -storepass cassandra -keystore "$basedir/data/.server-truststore"
cp "$basedir/data/.server-truststore" "$basedir/data/.client-truststore"
keytool -import -v -noprompt -trustcacerts -alias cassandra -file "$basedir/data/cassandra.cer" -storepass cassandra -keystore "$basedir/data/.server-truststore"
