#!/bin/bash
# Script for updating Suricata rules via pulledpork.pl and restarting the Suricata service once complete.
# Author: gradiuscypher | Last Modified: 2017-09-03
# TODO: Include steps for downloading/updating local.rules from a remote source

# Run pulledpork.pl to download newest rules, process disabled rules, and save new ruleset.
update_rules () {
    # md5sum the current file to see if the rules change
    if [[ -f /etc/suricata/rules/downloaded.rules ]]; then
        old_md5=$(md5sum /etc/suricata/rules/downloaded.rules | cut -d' ' -f1)
    else
        old_md5=""
    fi

    # Get suricata version for pulledpork
    suri_version=$(suricata -V | cut -d' ' -f5)

    # run pulledpork.pl
    pulledpork.pl -c /etc/pulledpork/pulledpork.conf -T -S suricata-"${suri_version}"

    # get md5sum of new file
    new_md5=$(md5sum /etc/suricata/rules/downloaded.rules | cut -d' ' -f1)
}

restart_suricata () {
    if [[ "${old_md5}" != "${new_md5}" ]]; then
        echo "Restarting Suricata..."
	if [[ -f /bin/systemctl || -f /usr/bin/systemctl ]]; then
       	    systemctl restart suricata
	else
	    /etc/init.d/suricata restart
	fi
    fi
}

# Main
main () {
    update_rules
    restart_suricata
}

# Execute main
main
