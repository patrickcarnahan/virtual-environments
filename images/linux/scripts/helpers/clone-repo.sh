#!/bin/bash
################################################################################
##  File:  clone-repo.sh
##  Desc:  Clones the azdevnext repo to disk and runs init
################################################################################

BASE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p /agent/_work/1/s
pushd /agent/_work/1/s

which dpkg
dpkg --help

if [ -d /agent/_work/1/s/Vssf ]; then
    exit 0
fi

git init

basic_header=$(echo -n "${SYSTEM_ACCESSTOKEN}:" | base64)
git config http.extraheader "Authorization: Basic $basic_header"
git remote add origin https://mseng@dev.azure.com/mseng/AzureDevOps/_git/_full/AzDevNext

git fetch
git checkout origin/master

version=$(git rev-parse HEAD)
#pwsh -c "& { ./init.ps1; dotnet restore; scorch -y }"

git clean -ffdx
git config --unset http.extraheader
popd
