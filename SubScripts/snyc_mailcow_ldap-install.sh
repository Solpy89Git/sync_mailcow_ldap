#!/bin/bash

##############################################################################
#                            Sync Mailcow Ldap Users                         #
##############################################################################
# 
#            =============================================================
#                    Mailcow LDAP Sync Script - GNU GPL v3.0
#            =============================================================
#   This software is licensed under the GNU General Public License v3.0.
#   You are free to use, modify, and distribute this software under the
#   terms of the GPL v3.0 license.
#
#   DISCLAIMER:
#   This script is provided "as is" without warranty or guarantees.
#   The authors are not responsible for data loss or damages.
#
#   You can read the full license here: https://www.gnu.org/licenses/gpl-3.0.txt
#           =============================================================
#
##############################################################################
#
#   Author:   Solpy89
#   Mail:     solberg_89@hotmail.it
#   Date:     02/01/2025
#   Scope:    This script is meant to partially solve the synchronization between ldap/Active Directory and Mailcow.
#             The future use of the script may be useless when all the bugs in the Nightly branch of mailcow are solved.
#
##############################################################################
#
#                                 INSTALL.SH
#
##############################################################################

#🔹Default path pre-install
CONFIG_FILE="/etc/mailcow_ldap_sync.conf"
CERT_FILE="/etc/mailcow_ldap.crt"
PRIVATE_KEY_FILE="/etc/mailcow_ldap_private.key"
DEFAULT_LOG_FILE="/var/log/mailcow_ldap_sync.log"


# 🔹 Function to display license and disclaimer
show_license() {
    clear
    echo "============================================================="
    echo "          Mailcow LDAP Sync Script - GNU GPL v3.0"
    echo "============================================================="
    echo "This software is licensed under the GNU General Public License v3.0."
    echo "You are free to use, modify, and distribute this software under the"
    echo "terms of the GPL v3.0 license."
    echo
    echo "DISCLAIMER:"
    echo "This script is provided 'as is' without warranty or guarantees."
    echo "The authors are not responsible for data loss or damages."
    echo
}

# 🔹 License Acceptance Function
license_acceptance() {
    clear
    show_license
    echo "Do you accept the terms and conditions? [y/N]"
    read -r ACCEPT_LICENSE
    if [[ "$ACCEPT_LICENSE" != "y" ]]; then
        echo "License terms not accepted. Exiting."
        exit 1
    fi
}

# 🔹 Check and Install Dependencies
check_dependencies() {
    echo "🔍 Checking dependencies..."
    REQUIRED_PKGS=("openssl" "ldap-utils" "jq" "cron" "curl" "systemd")
    
    if command -v apt-get &>/dev/null; then
        PKG_MANAGER="apt-get"
        INSTALL_CMD="sudo apt-get install -y"
        UPDATE_CMD="sudo apt-get update"
    elif command -v yum &>/dev/null; then
        PKG_MANAGER="yum"
        INSTALL_CMD="sudo yum install -y"
        UPDATE_CMD="sudo yum update -y"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
        INSTALL_CMD="sudo dnf install -y"
        UPDATE_CMD="sudo dnf update -y"
    else
        echo "❌ Error: Unable to determine package manager. Please install required packages manually."
        exit 1
    fi
    
    echo "🔄 Updating package repository..."
    $UPDATE_CMD
    
    for pkg in "${REQUIRED_PKGS[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            echo "⚠️ $pkg not found! Installing..."
            $INSTALL_CMD "$pkg"
        else
            echo "✅ $pkg is already installed."
        fi
    done
    echo "🎉 All dependencies are installed!"
}

show_license
license_acceptance
check_dependencies