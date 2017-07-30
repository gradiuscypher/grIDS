# roughsetup.md
First pass setup guide. This will be edited and cleaned up in the future.

# Network Configuration
This will be left as an exercise for the reader. Essentially, you'll need the capabiltiy to mirror the port on your switch that's attached to your next hop (modem, next hop network, etc). This way, you will be able to collect all information coming in and out of this network. This does come with the limitation of missing traffic that doesn't traverse this port, like intra-switch traffic. I'm not a networking hardware person though, so there might better way of doing this.

TL;DR - Get the traffic you want to see on the IDS to a network port on the IDS.

# Hardware Configuration
You'll want a system that matches your network throughput. A key requirement is multiple NICs - one as the management interface, and one for traffic monitoring from your mirror port.

# OS Configuration

## OS Installation
I'm using Ubuntu 16.04 LTS Server for compatability with most tools available. Other flavors of Linux can be used, but I'll be writing this guide with Ubuntu 16.04 in mind.

## NIC Configuration
### Management Interface
Configure your management interface as you would any other server. Either leverage DHCP or static addresses, whichever your network calls for.

### Monitoring Port
Now we'll configure the other port to monitor traffic from.

#### What device?
Find the name of the device that you'll be monitoring from (YAY SYSTEMD NAMING). In this example, we're concerned with enp8s0.

`root@grIDS:~# ip a`

```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
  <SNIP>
2: enp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
  <SNIP>
3: enp7s0: <NO-CARRIER,BROADCAST,PROMISC,UP> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
    link/ether 00:0a:cd:21:47:23 brd ff:ff:ff:ff:ff:ff
4: enp8s0: <BROADCAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0a:cd:21:47:24 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::20a:cdff:fe21:4724/64 scope link
       valid_lft forever preferred_lft forever
```

#### Disable multicast
```
ip link set enp8s0 multicast off
```

#### Enable promiscuous mode
```
root@grIDS:~# ip link set enp8s0 promisc on
```

#### Turn on the link
```
root@grIDS:~# ip link set enp8s0 up
```

#### Validate traffic
Validating traffic is difficult if you're not aware of what might be passing through the network. The best approach I've found to ensure you're not only seeing broadcast traffic is to use tcpdump to check that you're seeing common network traffic like HTTP/DNS/etc.

```
root@grIDS:~# tcpdump -i enp8s0
```

#### Promisc on boot
Now that the configuration has been validated, save these settings to `/etc/network/interfaces`:
```
up ip link set $INTERFACE multicast off
up ip link set $INTERFACE up
up ip link set $INTERFACE promisc on
```

# Elastic stack setup and configuration

## Pre-requisite - Java
This is to install the default OpenJRE, but you can also install Oracle Java if you'd prefer. I'm unaware of performance impact recently between the two, but it's something to consider.

```
sudo apt-get install default-jre
```

## Elasticsearch
Reference documenation [HERE](https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html)

### Install the PGP key for the Elastic DEB repo
```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
```

#### Configure the APT repo for Elastic products
```
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
```

#### Update APT and install ElasticSearch
```
sudo apt-get update && sudo apt-get install elasticsearch
```
#### Configure Elasticsearch to listen on 0.0.0.0
Edit the file `/etc/elasticsearch/elasticsearch.yml` and find the lines below, change network.host to 0.0.0.0

```
# ---------------------------------- Network -----------------------------------
#
# Set the bind address to a specific IP (IPv4 or IPv6):
#
network.host: 0.0.0.0
```

#### Configure the JVM settings
Edit the file `/etc/elasticsearch/jvm.options`

Change the heap size to something appropriate to how much ram your system has. The documentation is good. For example:
```
# Xms represents the initial size of total heap space
# Xmx represents the maximum size of total heap space

-Xms3g
-Xmx3g
```


#### Enable Elasticsearch to start on boot
```
systemctl enable elasticsearch
```

#### Start Elasticsearch
```
systemctl start elasticsearch
```

#### Check the logs to ensure Elasticsearch is happy
```
root@grIDS:~# journalctl -u elasticsearch
-- Logs begin at Fri 2017-07-21 10:31:00 PDT, end at Fri 2017-07-21 12:06:17 PDT. --
Jul 21 12:06:17 grIDS systemd[1]: Starting Elasticsearch...
Jul 21 12:06:17 grIDS systemd[1]: Started Elasticsearch.
```

#### Use curl to check Elasticsearch's API
```
root@grIDS:~# curl localhost:9200
{
  "name" : "9NabvE3",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "mKQHCf_HTySXM0Ze96isWw",
  "version" : {
    "number" : "5.5.0",
    "build_hash" : "260387d",
    "build_date" : "2017-06-30T23:16:05.735Z",
    "build_snapshot" : false,
    "lucene_version" : "6.6.0"
  },
  "tagline" : "You Know, for Search"
}
```

## Kibana

#### Installation
If you followed the previous instructions for setting up the Elastic APT repo, you can now just install Kibana via apt

```
apt-get install kibana
```

#### Configure Kibana to listen on 0.0.0.0
Edit the file `/etc/kibana/kibana.yml` and find the lines below, change server.host to 0.0.0.0

```
# Specifies the address to which the Kibana server will bind. IP addresses and host names are both valid values.
# The default is 'localhost', which usually means remote machines will not be able to connect.
# To allow connections from remote users, set this parameter to a non-loopback address.
server.host: 0.0.0.0
```

#### Enable Kibana to start at boot
```
systemctl enable kibana
```

#### Start Kibana
```
systemctl start kibana
```

#### Check the logs to ensure Kibana is happy
```
root@grIDS:~# journalctl -u kibana
-- Logs begin at Fri 2017-07-21 10:31:00 PDT, end at Fri 2017-07-21 12:17:06 PDT. --
Jul 21 12:16:58 grIDS systemd[1]: Started Kibana.
```

#### Connect to the Kibana web interface
Navigate your browser to the IP you set up earlier on the port 5601. You should be greeted with an index setup page, for example:
```
http://192.168.1.209:5601
```

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

#### HOME_NET and EXTERNAL_NET
Each rule written for Suricata has a direction of traffic flow that it's looking for. The setting list `HOME_NET` is considered the local network that you're monitoring. `EXTERNAL_NET` is the outside networks that you're monitoring traffic from.

It is important to get these settings right, as it impacts how the rules are interpreted. For example, my `HOME_NET` is going to be configured as ` HOME_NET: "[192.168.1.0/24]"` since I have a small homelab network on that IP space. For `EXTERNAL_NET`, my network is configured as `EXTERNAL_NET: "!$HOME_NET"` which is shorthand for everything else that isn't inside `HOME_NET`.