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
#                                 RUN.SH
#
##############################################################################

# 🔹 Search File and Config Function
search_file(){

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

#mailcow_ldap_sync.conf
echo "🔍 Search mailcow_ldap_sync.conf"
FILE=$(find /etc /usr/local/etc "$HOME/.config" / \  -type f -name "mailcow_ldap_sync.conf" 2>/dev/null | head -n 1)

     if [[ -f "$FILE" ]]; then
        
        echo "✅  Found mailcow_ldap_sync.conf"

        CONFIG_FILE=$FILE

        echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - Found mailcow_ldap_sync.conf" | tee -a "$LOG_FILE"

    else
        echo "❌ mailcow_ldap_sync.conf not found in:"
        echo "   - /etc/"
        echo "   - /usr/local/etc/"
        echo "   - $HOME/.config/"
        echo "   - $(dirname "$0")/"
        echo
        echo "‼️ ERROR: Please run .\snyc_mailcow_ldap.sh first --install or reinstall the solution after uninstalling."
        exit 1
    fi

    #mailcow_ldap_private.key
echo "🔍 Search mailcow_ldap_private.key"
FILE=$(find /etc /usr/local/etc "$HOME/.config" / \  -type f -name "mailcow_ldap_private.key" 2>/dev/null | head -n 1)

     if [[ -f "$FILE" ]]; then
        
        echo "✅  Found mailcow_ldap_private.key"

        PRIVATE_KEY_FILE=$FILE

        echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - Found mailcow_ldap_private.key" | tee -a "$LOG_FILE"
   
    else
        echo "❌ mailcow_ldap_private.key not found in:"
        echo "   - /etc/"
        echo "   - /usr/local/etc/"
        echo "   - $HOME/.config/"
        echo "   - $(dirname "$0")/"
        echo
        echo "‼️ ERROR: Please run .\snyc_mailcow_ldap.sh first --install or reinstall the solution after uninstalling."
        exit 1

    fi

}

decrypy(){

#Only for Debug
echo "❗ DEBUG KEY CRIPTED"
echo $LDAP_PASSWORD_ENC

#Only for Debug
echo "❗ DEBUG KEY FILE"
echo $PRIVATE_KEY_FILE

LDAP_PASSWORD=$(echo -n "$LDAP_PASSWORD_ENC" | base64 -d | openssl smime -decrypt -binary -inform DER -inkey "$PRIVATE_KEY_FILE")

#Only for Debug
echo "❗ DEBUG KEY ENCRIPTED"
echo $LDAP_PASSWORD

echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - Decrypted LDAP Password" | tee -a "$LOG_FILE"

}


ldap_query(){

echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - LDAP Query in execution" | tee -a "$LOG_FILE"

 AD_USERS=$(ldapsearch -LLL -x -H "$LDAP_SERVER" \
      -D "$LDAP_BIND_DN" \
      -w "$LDAP_PASSWORD" \
      -b "$LDAP_BASE_DN" \
      "$LDAP_FILTER" mail sAMAccountName cn userAccountControl | \
    awk '
      /^dn:/ {mail=""; sam=""; name=""; uac=""}
      /^mail:/ {mail=$2}
      /^sAMAccountName:/ {sam=$2}
      /^cn:/ {name=$0; sub(/^cn: /, "", name)}
      /^userAccountControl:/ {uac=$2}
      /^$/ {
        if (mail && sam) {
          print mail, sam, name, uac
          mail=""; sam=""; name=""; uac=""
        }
      }')

    if [[ -z "$AD_USERS" ]]; then
        echo "❌ $(date '+%Y-%m-%d %H:%M:%S') - LDAP query returned no results. Check your LDAP settings." | tee -a "$LOG_FILE"
        exit 1
    else
        echo "✅ $(date '+%Y-%m-%d %H:%M:%S') - LDAP query successful. Users found:" | tee -a "$LOG_FILE"
        echo "$AD_USERS" | tee -a "$LOG_FILE"
    fi

}

search_file
source $CONFIG_FILE
decrypy
ldap_query
 
