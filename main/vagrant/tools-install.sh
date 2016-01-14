#!/usr/bin/env bash

export ANT_VERSION="1.9.6"
export MAVEN_VERSION="3.3.9"

set -x

function downloadFromApacheMirror {
    if [ "$1" == "" ] || [ "$2" == "" ]; then
        echo "Invalid arguments" &>2
        return 1
    fi

    mirror="$(curl -s 'https://www.apache.org/dyn/closer.cgi' | grep -o '<strong>[^<]*</strong>' | sed 's/<[^>]*>//g' | head -1)"
    remotePath="$1"
    targetPath="$2"

    if [ -f "$targetPath" ]; then
        echo "$targetPath already exists" &>2
        return 0
    else
        echo "Downloading $mirror$remotePath into $targetPath"
        wget -O "$targetPath" "$mirror$remotePath"
        return "$?"
    fi
}

function unpack {
    if [ "$1" == "" ] || [ "$2" == "" ]; then
        echo "Invalid arguments" &>2
        return 1
    fi

    local archivePath="$1"
    local targetDir="$2"

    rm -rf "$targetDir"
    mkdir "$targetDir"
    tar -xvf "$archivePath" --strip-components=1 -C "$targetDir"
}

function install {
    if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ]; then
        echo "Invalid arguments" &>2
        return 1
    fi

    local archivePath="$1"
    local targetDir="$2"
    local executable="$3"

    unpack "$archivePath" "$targetDir"
    rm -f "/usr/bin/$executable"
    ln -s "$targetDir/bin/$executable" "/usr/bin/$executable"
}

function downloadAndInstall {
    if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ] || [ "$4" == "" ]; then
        echo "Invalid arguments" &>2
        return 1
    fi

    local archivePath="$1"
    local targetDir="$2"
    local executable="$3"
    local remotePath="$4"

    rm -f "$archivePath"
    downloadFromApacheMirror "$remotePath" "$archivePath"
    if [ "$?" == "0" ]; then
        install "$archivePath" "$targetDir" "$executable"
    else
        return 1
    fi
}

function installAnt {
    apt-get -q -y remove ant
    version="$1"
    name="apache-ant-$version"
    file="$name-bin.tar.gz"
    remotePath="/ant/binaries/$file"
    archivePath="/tmp/$file"
    targetDir="/usr/local/$name"
    downloadAndInstall "$archivePath" "$targetDir" "ant" "$remotePath"
}

function installMaven {
    apt-get -q -y remove maven maven2
    version="$1"
    name="apache-maven-$version"
    file="$name-bin.tar.gz"
    remotePath="/maven/maven-3/$version/binaries/$file"
    archivePath="/tmp/$file"
    targetDir="/usr/local/$name"
    downloadAndInstall "$archivePath" "$targetDir" "mvn" "$remotePath"
}

installAnt "$ANT_VERSION"
installMaven "$MAVEN_VERSION"
