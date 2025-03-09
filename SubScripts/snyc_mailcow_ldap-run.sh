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

LDAP_PASSWORD=$(echo -n "$LDAP_PASSWORD_ENC" | base64 -d | openssl smime -decrypt -binary -inform DER -inkey "$PRIVATE_KEY_FILE" |  sed 's/^ *//;s/ *$//')

#Only for Debug
echo "❗ DEBUG KEY ENCRIPTED"
echo $LDAP_PASSWORD

echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - Decrypted LDAP Password" | tee -a "$LOG_FILE"

}


ldap_query(){

echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - LDAP Query in execution" | tee -a "$LOG_FILE"

#Only for Debug
echo "❗ DEBUG QUERY STRING"
echo "ldapsearch -LLL -x -H "$LDAP_SERVER" -D "$LDAP_BIND_DN" -w "$LDAP_PASSWORD" -b "$LDAP_BASE_DN" "$LDAP_FILTER" mail sAMAccountName cn userAccountControl"

    AD_USERS=$(ldapsearch -LLL -x -H "$LDAP_SERVER" \
      -D "$LDAP_BIND_DN" \
      -w "$LDAP_PASSWORD" \
      -b "$LDAP_BASE_DN" \
      '"$LDAP_FILTER"' mail sAMAccountName cn userAccountControl | \
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
        echo "✅ $(date '+%Y-%m-%d %H:%M:%S') - LDAP query successful." | tee -a "$LOG_FILE"
        echo
        echo "List of Users Found:" | tee -a "$LOG_FILE"
        echo                        | tee -a "$LOG_FILE"

        ldapsearch -LLL -x -H "$LDAP_SERVER" \
    -D "$LDAP_BIND_DN" \
    -w "$LDAP_PASSWORD" \
    -b "$LDAP_BASE_DN" \
    '"$LDAP_FILTER"' \
    mail sAMAccountName cn userAccountControl | awk '
    BEGIN {
        count=0
        column1_width=40  # MAIL
        column2_width=20  # CN (sAMAccountName)
        column3_width=25  # DISPLAY NAME (cn)
        column4_width=5   # UAC
        format = "%-" column1_width "s | %-" column2_width "s | %-" column3_width "s | %-" column4_width "s\n"

        printf format, "MAIL", "CN", "DISPLAY NAME", "UAC"
        printf "%s\n", str_repeat("-", column1_width + column2_width + column3_width + column4_width + 9)
    }

    function str_repeat(char, num) {
        result = ""
        for (i=0; i<num; i++) result = result char
        return result
    }

    /^dn:/ {mail=""; sam=""; name=""; uac=""}
    /^mail:/ {mail=$2}
    /^sAMAccountName:/ {sam=$2}
    /^cn:/ {name=$0; sub(/^cn: /, "", name)}
    /^userAccountControl:/ {uac=$2}
    /^$/ {
        if (mail && sam) {
            printf format, mail, sam, name, uac
            count++
            mail=""; sam=""; name=""; uac=""
        }
    }

    END {
        printf "%s\n", str_repeat("-", column1_width + column2_width + column3_width + column4_width + 9)
        printf "Total Accounts Found: %d\n", count
    }' | tee -a "$LOG_FILE"


#Only for Debug
echo
echo "❗ DEBUG QUERY OUTPUT"
echo "$AD_USERS"

    fi
}

mailcow_query(){

    echo "🚀 $(date '+%Y-%m-%d %H:%M:%S') - Mailcow Query in execution" | tee -a "$LOG_FILE"    

    MAILCOW_USERS=$(curl -s "$MAILCOW_API_URL/get/mailbox/all/$MAILCOW_DOMAIN" -H "X-API-Key: $MAILCOW_API_KEY" | jq -r '.[].username')

    #Only for Debug
echo
echo "❗ DEBUG QUERY OUTPUT"
echo "$MAILCOW_USERS"


}

search_file
source $CONFIG_FILE
decrypy
ldap_query
mailcow_query