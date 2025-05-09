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
#   Author:   Solpy89Git
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
DEFAULT_LDAP_FILTER="(&(objectClass=person)(|(sAMAccountName=%uid)(mail=%uid)))"


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

cert(){
    echo "🔐 Generating SSL Certificate for Encryption..."
    openssl genpkey -algorithm RSA -out "$PRIVATE_KEY_FILE"
    openssl req -new -key "$PRIVATE_KEY_FILE" -out /tmp/mailcow_ldap.csr -subj "/CN=Mailcow LDAP Sync"
    openssl x509 -req -days 3650 -in /tmp/mailcow_ldap.csr -signkey "$PRIVATE_KEY_FILE" -out "$CERT_FILE"
    chmod 600 "$PRIVATE_KEY_FILE"
    chmod 644 "$CERT_FILE"
    rm /tmp/mailcow_ldap.csr
}

show_license
license_acceptance
check_dependencies
cert

echo "🔑 LDAP Configuration:"
    read -p "LDAP Server (e.g., ldap://XXX.XXX.XXX.XXX or ldap://myldap.local): " LDAP_SERVER
    read -p "LDAP Bind DN (e.g., CN=usertest,OU=Service,OU=Company,DC=domain,DC=local): " LDAP_BIND_DN
    read -s -p "LDAP Bind User Password: " LDAP_PASSWORD; echo
    read -p "LDAP Base DN (e.g., DC=domain,DC=local): " LDAP_BASE_DN
    read -p "LDAP Filter [$DEFAULT_LDAP_FILTER]: " LDAP_FILTER
    LDAP_FILTER=${LDAP_FILTER:-$DEFAULT_LDAP_FILTER}
    read -p "Mailcow API URL (e.g., https://yourmailcowserver.com/api or http://xxx.xxx.xxx.xxx/api): " MAILCOW_API_URL
    read -p "Mailcow API Key: " MAILCOW_API_KEY
    read -p "Mailcow Mailbox Domain: " MAILCOW_DOMAIN
    read -p "Mailcow Mailbox Quota (MiB): " MAILCOW_QUOTA
    read -p "Log File [$DEFAULT_LOG_FILE]: " LOG_FILE
    LOG_FILE=${LOG_FILE:-$DEFAULT_LOG_FILE}
    read -p "Cron interval in minutes [15]: " CRON_INTERVAL
    CRON_INTERVAL=${CRON_INTERVAL:-15}

echo "🔑 Encryption LDAP Configuration"
LDAP_PASSWORD_ENC=$(echo -n "$LDAP_PASSWORD" | openssl smime -encrypt -aes-256-cbc -binary -outform DER "$CERT_FILE" | base64)

echo "✅ Encryption LDAP Configuration Done"

# 🔹 Creation Config File

sudo tee "$CONFIG_FILE" > /dev/null <<EOL
    LDAP_SERVER="$LDAP_SERVER"
    LDAP_BIND_DN="$LDAP_BIND_DN"
    LDAP_PASSWORD_ENC="$LDAP_PASSWORD_ENC"
    LDAP_BASE_DN="$LDAP_BASE_DN"
    LDAP_FILTER="$LDAP_FILTER"
    MAILCOW_API_URL="$MAILCOW_API_URL"
    MAILCOW_API_KEY="$MAILCOW_API_KEY"
    MAILCOW_QUOTA="$MAILCOW_QUOTA"
    MAILCOW_DOMAIN="$MAILCOW_DOMAIN"
    LOG_FILE="$LOG_FILE"
EOL

echo "✅ Config File Creation Done"

# 🔹 Creation Log File

    echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - LDAP_SERVER CONFIGURATED" > $LOG_FILE
    echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - LDAP_BIND_DN CONFIGURATED" >> $LOG_FILE
    echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - LDAP_PASSWORD_ENC CONFIGURATED" >> $LOG_FILE
    echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - LDAP_BASE_DN CONFIGURATED" >> $LOG_FILE
    echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - LDAP_FILTER CONFIGURATED" >> $LOG_FILE
    echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - MAILCOW_API_URL CONFIGURATED" >> $LOG_FILE
    echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - MAILCOW_API_KEY CONFIGURATED" >> $LOG_FILE
    echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - MAILCOW_DOMAIN CONFIGURATED" >> $LOG_FILE
    echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - MAILCOW_QUOTA CONFIGURATED" >> $LOG_FILE
    echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - LOG_FILE CONFIGURATED" >> $LOG_FILE


echo "✅ Log File Creation Done"

# 🔹 Cron

    #(crontab -l 2>/dev/null; echo "*/$CRON_INTERVAL * * * * /bin/bash $(realpath "$0") --run >> $LOG_FILE 2>&1") | crontab -
    #(crontab -l 2>/dev/null; echo "@reboot /bin/bash $(realpath "$0") --run >> $LOG_FILE 2>&1") | crontab -
    
    #sudo systemctl daemon-reload
    #sudo systemctl enable mailcow-ldap-sync.service
    #sudo systemctl start mailcow-ldap-sync.service

#echo "✅ $(date '+%Y-%m-%d %H:%M:%S') - Installation completed! The script will start automatically on boot and run at regular intervals."
echo "✅ $(date '+%Y-%m-%d %H:%M:%S') - Installation completed!"
echo ""
echo "❗ Please execute the command ./sync_mailcow_ldap.sh --run to made the first sync."
echo ""
echo "😁 Good Work from Solpy89Git!"
