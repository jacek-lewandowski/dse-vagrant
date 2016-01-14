#!/usr/bin/env bash

set -x

export basedir="$(cd "`dirname "$0"`"; pwd)"

function toAbsolutePath {
    path="$1"
    perl -e "use File::Spec; print File::Spec->rel2abs(\"$path\")"
}

if [ "$1" != "" ]; then
    export DSE_HOME="$(toAbsolutePath $1)"
fi

if [ "$DSE_HOME" == "" ]; then
    echo "No DSE_HOME specified"
    exit 1
fi

if [ -h "$basedir/dse" ]; then
    rm "$basedir/dse"
fi

cd "$basedir"
ln -v -f -s "$DSE_HOME" dse
