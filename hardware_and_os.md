# Network Hardware Configuration
This will be left as an exercise for the reader. Essentially, you'll need the capabiltiy to mirror the port on your switch that's attached to your next hop (modem, next hop network, etc). This way, you will be able to collect all information coming in and out of this network. This does come with the limitation of missing traffic that doesn't traverse this port, like intra-switch traffic. I'm not a networking hardware person though, so there might better way of doing this.

TL;DR - Get the traffic you want to see on the IDS to a network port on the IDS.

# PC Hardware Configuration
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
