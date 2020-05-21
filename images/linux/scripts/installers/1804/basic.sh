#!/bin/bash
################################################################################
##  File:  basic.sh
##  Desc:  Installs basic command line utilities and dev packages
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

set -e

if ! command -v 'zip'; then
    apt-get install -y --no-install-recommends \
        curl \
        dnsutils \
        dpkg \
        file \
        ftp \
        jq \
        locales \
        netcat \
        openssh-client \
        parallel \
        rpm \
        rsync \
        shellcheck \
        sudo \
        time \
        unzip \
        wget \
        zip
fi

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
for cmd in curl dpkg file ftp jq netcat ssh parallel rsync shellcheck sudo time unzip wget zip; do
    if ! command -v $cmd; then
        echo "$cmd was not installed"
        exit 1
    fi
done

# Workaround for systemd-resolve, since sometimes stub resolver does not work properly. Details: https://github.com/actions/virtual-environments/issues/798
echo "Create resolv.conf link."
if [[ -f /run/systemd/resolve/resolv.conf ]]; then
    echo "Create resolv.conf link."
    ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
fi

# Document what was added to the image
echo "Lastly, documenting what we added to the metadata file"
DocumentInstalledItem "Basic CLI:"
DocumentInstalledItemIndent "curl"
DocumentInstalledItemIndent "file"
DocumentInstalledItemIndent "ftp"
DocumentInstalledItemIndent "jq"
DocumentInstalledItemIndent "libicu55"
DocumentInstalledItemIndent "locales"
DocumentInstalledItemIndent "netcat"
DocumentInstalledItemIndent "openssh-client"
DocumentInstalledItemIndent "parallel"
DocumentInstalledItemIndent "rsync"
DocumentInstalledItemIndent "shellcheck"
DocumentInstalledItemIndent "sudo"
DocumentInstalledItemIndent "time"
DocumentInstalledItemIndent "unzip"
DocumentInstalledItemIndent "wget"
DocumentInstalledItemIndent "zip"
