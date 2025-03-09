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
#                                 INDEX.SH
#
##############################################################################

# 🔹 Sub Scripts

install(){
   
    echo "🔍 Search for installation function."
    echo "🙏 Please wait ..."

    INSTALL_FILE=$(find /etc /usr/local/etc "$HOME/.config" / \  -type f -name "snyc_mailcow_ldap-install.sh" 2>/dev/null | head -n 1)

     if [[ -f "$INSTALL_FILE" ]]; then
        
        echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - Starting Install"
        bash $INSTALL_FILE
    
    else
        echo "❌ Installation File not found in:"
        echo "   - /etc/"
        echo "   - /usr/local/etc/"
        echo "   - $HOME/.config/"
        echo "   - $(dirname "$0")/"
        echo
        echo "Please try to download again the files and resubmit installation."
        exit 1
    fi
}

uninstall(){
    
    echo "🔍 Search for uninstallation function."
    echo "🙏 Please wait ..."

    UNINSTALL_FILE=$(find /etc /usr/local/etc "$HOME/.config" / \  -type f -name "snyc_mailcow_ldap-uninstall.sh" 2>/dev/null | head -n 1)

     if [[ -f "$UNINSTALL_FILE" ]]; then
        
        echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - Starting Unistall"
        bash $UNINSTALL_FILE

    else
        echo "❌ Uninstallation File not found in:"
        echo "   - /etc/"
        echo "   - /usr/local/etc/"
        echo "   - $HOME/.config/"
        echo "   - $(dirname "$0")/"
        echo
        echo "Please try to download again the files and resubmit installation."
        exit 1
    fi
}

run(){
   
    echo "🔍 Search for run function."
    echo "🙏 Please wait ..."

    RUN_FILE=$(find /etc /usr/local/etc "$HOME/.config" / \  -type f -name "snyc_mailcow_ldap-run.sh" 2>/dev/null | head -n 1)

     if [[ -f "$RUN_FILE" ]]; then
        
        echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - Starting Run"
        bash $RUN_FILE

    else
        echo "❌ Uninstallation File not found in:"
        echo "   - /etc/"
        echo "   - /usr/local/etc/"
        echo "   - $HOME/.config/"
        echo "   - $(dirname "$0")/"
        echo
        echo "Please try to download again the files and resubmit installation."
        exit 1
    fi
}

# 🔹 Log viewer
log() { 

    #mailcow_ldap_sync.log
echo "🔍 Search mailcow_ldap_sync.log"
FILE=$(find /etc /usr/local/etc "$HOME/.config" / \  -type f -name "mailcow_ldap_sync.log" 2>/dev/null | head -n 1)

     if [[ -f "$FILE" ]]; then
        
        echo "✅  Found mailcow_ldap_sync.log"

        LOG_FILE=$FILE

        echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - Found mailcow_ldap_sync.log" | tee -a "$LOG_FILE"

    else
        echo "❌ mailcow_ldap_sync.log not found in:"
        echo "   - /etc/"
        echo "   - /usr/local/etc/"
        echo "   - $HOME/.config/"
        echo "   - $(dirname "$0")/"
        echo
        echo "‼️ ERROR: Please run .\snyc_mailcow_ldap.sh first --install or reinstall the solution after uninstalling."
        exit 1
    fi

    tail -n 20 "$LOG_FILE"; 
    
}


# 🔹 Help Function
help() {
    cat <<EOF
Mailcow LDAP Sync Script

Usage:
  $0 [OPTIONS]

Options:
  --help       Show help, license, and disclaimer
  --install    Run guided installation and setup
  --run        Execute LDAP synchronization
  --log        Display synchronization logs

DESCRIPTION:
This script synchronizes users from an LDAP server to a Mailcow server.

License:
GNU General Public License v3.0
You can read it here: https://www.gnu.org/licenses/gpl-3.0.txt

DISCLAIMER:
This script is provided "as is" without warranty or guarantees.
The authors are not responsible for data loss or damages.

EOF
}


# 🔹 Main Execution
case "$1" in
    --help) help ;;
    --install) install ;;
	--uninstall) uninstall ;;
    --run) run ;;
    --log) log ;;
    *) help; exit 1;;
esac