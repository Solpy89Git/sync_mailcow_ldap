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
#                                 UNINSTALL.SH
#
##############################################################################

# 🔹 Uninstall confirm
uninstall_confirm() {
    
    echo "⚠️ ⚠️ ⚠️  ALLERT! ⚠️ ⚠️ ⚠️"
    echo ""
    echo "Are you sure to proceed with unistall?"
    echo ""
    echo "If you proceed, logs, configurations and certificates will be removed."
    echo ""
    echo "⁉️  Do you want proceed?[y/N]"

    read -r ACCEPT_UNISTALL
    if [[ "$ACCEPT_UNISTALL" != "y" ]]; then
        echo "Uninstallation process stopped."
        exit 1
    fi
}

uninstall_confirm

echo "🔍 Search all file..."

#mailcow_ldap_private.key
echo "🔍 Search mailcow_ldap_private.key"
R_FILE=$(find /etc /usr/local/etc "$HOME/.config" / \  -type f -name "mailcow_ldap_private.key" 2>/dev/null | head -n 1)

     if [[ -f "$R_FILE" ]]; then
        
        echo "✅  Found mailcow_ldap_private.key"

        rm $R_FILE
    
        echo "❎  Removed mailcow_ldap_private.key"

    else
        echo "❌ mailcow_ldap_private.key not found in:"
        echo "   - /etc/"
        echo "   - /usr/local/etc/"
        echo "   - $HOME/.config/"
        echo "   - $(dirname "$0")/"
        echo
        echo "❎  mailcow_ldap_private.key already removed."
    fi

#mailcow_ldap.crt
echo "🔍 Search mailcow_ldap.crt"
R_FILE=$(find /etc /usr/local/etc "$HOME/.config" / \  -type f -name "mailcow_ldap.crt" 2>/dev/null | head -n 1)

     if [[ -f "$R_FILE" ]]; then
        
        echo "✅  Found mailcow_ldap.crt"

        rm $R_FILE
    
        echo "❎  Removed mailcow_ldap.crt"

    else
        echo "❌ mailcow_ldap.crt not found in:"
        echo "   - /etc/"
        echo "   - /usr/local/etc/"
        echo "   - $HOME/.config/"
        echo "   - $(dirname "$0")/"
        echo
        echo "❎  mailcow_ldap.crt already removed."
    fi

#mailcow_ldap_sync.conf
echo "🔍 Search mailcow_ldap_sync.conf"
R_FILE=$(find /etc /usr/local/etc "$HOME/.config" / \  -type f -name "mailcow_ldap_sync.conf" 2>/dev/null | head -n 1)

     if [[ -f "$R_FILE" ]]; then
        
        echo "✅  Found mailcow_ldap_sync.conf"

        rm $R_FILE
    
        echo "❎  Removed mailcow_ldap_sync.conf"

    else
        echo "❌ mailcow_ldap_sync.conf not found in:"
        echo "   - /etc/"
        echo "   - /usr/local/etc/"
        echo "   - $HOME/.config/"
        echo "   - $(dirname "$0")/"
        echo
        echo "❎  mailcow_ldap_sync.conf already removed."
    fi

#mailcow_ldap_sync.log
echo "🔍 Search mailcow_ldap_sync.log"
R_FILE=$(find /etc /usr/local/etc "$HOME/.config" / \  -type f -name "mailcow_ldap_sync.log" 2>/dev/null | head -n 1)

     if [[ -f "$R_FILE" ]]; then
        
        echo "✅  Found mailcow_ldap_sync.log"

        rm $R_FILE
    
        echo "❎  Removed mailcow_ldap_sync.log"

    else
        echo "❌ mailcow_ldap_sync.log not found in:"
        echo "   - /etc/"
        echo "   - /usr/local/etc/"
        echo "   - $HOME/.config/"
        echo "   - $(dirname "$0")/"
        echo
        echo "❎  mailcow_ldap_sync.log already removed."
    fi

echo "🧹 Uninstall complete."
	echo "Thank you in every way for using me."
	echo "See you soon!"
	echo "Solpy89Git"
