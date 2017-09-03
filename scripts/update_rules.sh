#!/bin/bash
# Script for updating Suricata rules via pulledpork.pl and restarting the Suricata service once complete.
# Author: gradiuscypher | Last Modified: 2017-09-03
# TODO: Include steps for downloading/updating local.rules from a remote source

# Run pulledpork.pl to download newest rules, process disabled rules, and save new ruleset.
update_rules () {
    # md5sum the current file to see if the rules change
    if [ -f /etc/suricata/rules/downloaded.rules ]; then
        OLD_MD5=`md5sum /etc/suricata/rules/downloaded.rules | cut -d' ' -f1`
    else
        OLD_MD5=""
    fi

    # Get suricata version for pulledpork
    SURI_VERSION=`suricata -V | cut -d' ' -f5`

    # run pulledpork.pl
    pulledpork.pl -c /etc/pulledpork/pulledpork.conf -T -S suricata-$SURI_VERSION

    # get md5sum of new file
    NEW_MD5=`md5sum /etc/suricata/rules/downloaded.rules | cut -d' ' -f1`
}

restart_suricata () {
    if [ "$OLD_MD5" != "$NEW_MD5" ]; then
        echo "Restarting Suricata..."
        systemctl restart suricata
    fi
}

# Main Loop
main () {
    update_rules
    restart_suricata
}

# Execute main loop
main
