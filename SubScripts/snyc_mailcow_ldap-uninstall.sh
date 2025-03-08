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
    
    echo "⚠️⚠️⚠️ ALLERT! ⚠️⚠️⚠️"
    echo ""
    echo "Are you sure to proceed with unistall?"
    echo ""
    echo "If you proceed, all script files, configurations and certificates will be removed."
    echo ""
    echo "⁉️ Do you want proceed?[y/N]"

    read -r ACCEPT_UNISTALL
    if [[ "$ACCEPT_UNISTALL" != "y" ]]; then
        echo "Uninstallation process stopped."
        exit 1
    fi
}

uninstall_confirm