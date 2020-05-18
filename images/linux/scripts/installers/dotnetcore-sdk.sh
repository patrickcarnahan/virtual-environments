#!/bin/bash
################################################################################
##  File:  dotnetcore-sdk.sh
##  Desc:  Installs .NET Core SDK
################################################################################
source $HELPER_SCRIPTS/etc-environment.sh
source $HELPER_SCRIPTS/apt.sh
source $HELPER_SCRIPTS/document.sh

LATEST_DOTNET_PACKAGES=("dotnet-sdk-3.1")

LSB_RELEASE=$(lsb_release -rs)

mksamples()
{
    sdk=$1
    sample=$2
    mkdir "$sdk"
    cd "$sdk" || exit
    set -e
    dotnet help
    dotnet new globaljson --sdk-version "$sdk"
    dotnet new "$sample"
    dotnet restore
    dotnet build
    set +e
    cd .. || exit
    rm -rf "$sdk"
}

set -e

# Disable telemetry
export DOTNET_CLI_TELEMETRY_OPTOUT=1

for latest_package in ${LATEST_DOTNET_PACKAGES[@]}; do
    echo "Determing if .NET Core ($latest_package) is installed"
    if ! IsInstalled $latest_package; then
        echo "Could not find .NET Core ($latest_package), installing..."
        #temporary avoid 3.1.102 installation due to https://github.com/dotnet/aspnetcore/issues/19133
        if [ $latest_package != "dotnet-sdk-3.1" ]; then
            apt-get install $latest_package -y
        else
            apt-get install dotnet-sdk-3.1=3.1.101-1 -y
        fi
    else
        echo ".NET Core ($latest_package) is already installed"
    fi
done

# NuGetFallbackFolder at /usr/share/dotnet/sdk/NuGetFallbackFolder is warmed up by smoke test
# Additional FTE will just copy to ~/.dotnet/NuGet which provides no benefit on a fungible machine
setEtcEnvironmentVariable DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1
prependEtcEnvironmentPath /home/runner/.dotnet/tools
echo 'export PATH="$PATH:$HOME/.dotnet/tools"' | tee -a /etc/skel/.bashrc
