# Suricata Configuration
Suricata is an open source network intrusion detection/prevention software. You can learn more about it [HERE](https://suricata-ids.org/). We'll feed Suricata our network traffic, Suricata will run it through the ruleset we've configured and then will send alerts and logs to our Elastic stack for investigation.

## Installing Suricata
We're going to use the PPA provided by OSIF to make our updating a little bit easier. More information about OSIF can be found [HERE](https://redmine.openinfosecfoundation.org/projects/suricata/wiki/Ubuntu_Installation_-_Personal_Package_Archives_(PPA))

When we install Suricata this way, it also downloads the latest EmergingThreats IDS ruleset. We'll talk more about rules and configuration a bit later.

```
sudo add-apt-repository ppa:oisf/suricata-stable
sudo apt-get update
sudo apt-get install suricata
```

## Configuring Suricata

Useful Reference: [Suricata Documentation](http://suricata.readthedocs.io/en/latest/)

First we need to stop the process that started when we installed Suricata with the PPA, but enable the service to start on boot.
```
systemctl stop suricata
systemctl enable suricata
```

Next we'll work on getting through the important bits of the Suricata config file. There are thousands of lines, and many tweaks you can do to improve performance and enable features, but we'll focus on the basics. As we make changes to the configuration, we'll be launching Suricata on the command line to ensure everything is working.

#### HOME_NET and EXTERNAL_NET : address-groups
Each rule written for Suricata has a direction of traffic flow that it's looking for. The setting list `HOME_NET` is considered the local network that you're monitoring. `EXTERNAL_NET` is the outside networks that you're monitoring traffic from.

It is important to get these settings right, as it impacts how the rules are interpreted. Incorrect address-groups can lead to both false positives and false negatives. In larger networks, this could also lead to a LOT of alerts that are garbage. Other than `HOME_NET` and `EXTERNAL_NET` you also need to evaluate each of the other address groups (eg: `HTTP_SERVERS`). You don't want HTTP alerts for non-HTTP servers.

For example settings, my `HOME_NET` is going to be configured as ` HOME_NET: "[192.168.1.0/24]"` since I have a small homelab network on that IP space. For `EXTERNAL_NET`, my network is configured as `EXTERNAL_NET: "!$HOME_NET"` which is shorthand for everything else that isn't inside `HOME_NET`.
