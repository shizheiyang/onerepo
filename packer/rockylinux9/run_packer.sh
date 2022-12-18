#!/bin/bash

BOX_MAJOR_VERSION='1'
BOX_MINOR_VERSION='0'
REPO=shizheiyang
BOX=rockylinux9

VAGRANT_CLOUD_BOX_VERSION=`curl -s https://app.vagrantup.com/api/v1/box/${REPO}/${BOX} | jq -r .current_version.version`
BUILD_NUM=`echo $VAGRANT_CLOUD_BOX_VERSION | cut -d'.' -f3`
BUILD_NUM=$((BUILD_NUM + 1))

BOX_VERSION="${BOX_MAJOR_VERSION}.${BOX_MINOR_VERSION}.${BUILD_NUM}"

if [ -z "$VAGRANT_CLOUD_TOKEN" ]; then
    echo \$VAGRANT_CLOUD_TOKEN is not set, exiting...
    exit 1
fi

if [ ! -e Rocky-9.1-x86_64-minimal.iso ]; then 
    curl -O https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.1-x86_64-minimal.iso
fi

if [ -e /etc/os-release ]; then
    OS_NAME=`awk -F '"' '/^NAME/ {print $2}' /etc/os-release`
    PKR_HCL=rockylinux9-${OS_NAME}.pkr.hcl
else
    PKR_HCL=rockylinux9.pkr.hcl
fi

set -x
PACKER_LOG=1 packer build -var "version=${BOX_VERSION}" -force $PKR_HCL
set +x
