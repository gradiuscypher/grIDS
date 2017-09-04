#!/bin/bash
# Script for updating Suricata rules via pulledpork.pl and restarting the Suricata service once complete.
# Author: gradiuscypher | Last Modified: 2017-09-03
# TODO: Include steps for downloading/updating local.rules from a remote source

# Run pulledpork.pl to download newest rules, process disabled rules, and save new ruleset.

check_state() {
    if [[ $(id -u) != "0" ]]; then
        echo "Please run this as root"
        exit 1
    fi
    for i in "pulledpork.pl" "suricata"; do
        if ! type -p $i; then
            echo "Please install $i"
            exit 1
        fi
    done
}

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
        if type -p systemctl; then
       	    systemctl restart suricata
        else
            /etc/init.d/suricata restart
        fi
    fi
}

# Main
main () {
    check_state
    update_rules
    restart_suricata
}

# Execute main
main
