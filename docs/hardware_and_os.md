# Network Hardware Configuration
Essentially, you'll need the ability to get network traffic from the ports you want to monitor to the monitoring port on the IDS system. This can be done a few different ways, either with hardware or software (if your router has the ability). 

With hardware, you can use a switch to span/mirror the port going to your WAN. This way, you're capturing all traffic that comes into and leaves your network. One downside to spanning the WAN is that you miss traffic that never crosses the WAN, but we still see most traffic including malware callbacks, C&C, etc (the things you want to spot).

With hardware, you can also build a network tap that goes between your LAN and WAN. I'm not using this method, so I don't have documentation for this approach. I personally don't like this approach, as it puts our system inbetween LAN and WAN traffic, and if it fails incorrectly, the network can be taken offline. I'll collect some network tap guides for a later update for those that want to try this approach.

With software (if your router hardware supports it), you could use iptables to mirror all traffic to another device on the network. I haven't tried this method yet, but I know people have successfully used this approach in the past. Currently, I don't have any documentation for this approach, but I'll collect some guides for a later update.

TL;DR - Get the traffic you want to see on the IDS to a network port on the IDS system. I'm currently using a Ubiquiti 8 port PoE switch, mirroring the WAN port to the second NIC of my IDS box. If your router supports iptables, you can also mirror the traffic using iptables rules. You can also use a hardware network tap.

# PC Hardware Configuration
You'll want a system that matches your network throughput. A key requirement is multiple NICs - one as the management interface, and one for traffic monitoring from your mirror port.

For a rough baseline, on a 200Mbs down/20Mbs up Internet connection, I'm using a Shuttle Mini PC with a Core i5 and 8GB of RAM, along with a 128GB SSD. Even while running a full Elastic stack along with Suricata, it's not struggling to keep up. The only real limitation you'll have to pay attention to is how long you'll want to retain PCAP files, as that's all about storage.

# OS Configuration

## OS Installation
I'm using Ubuntu 16.04 LTS Server for compatability with most tools available. Other flavors of Linux can be used, but I'll be writing this guide with Ubuntu 16.04 in mind.

## NIC Configuration
### Management Interface
Configure your management interface as you would any other server. Either leverage DHCP or static addresses, whichever your network calls for.

### Monitoring Port
Now we'll configure the other port to monitor traffic from.

#### What device?
Find the name of the device that you'll be monitoring from. In this example, we're concerned with enp8s0 (YAY SYSTEMD NAMING).

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
Validating traffic is difficult if you're not aware of what might be passing through the network. The best approach I've found to ensure you're not only seeing broadcast traffic is to use tcpdump to check that you're seeing common network traffic like HTTP/DNS/etc. Try navigating to a site that uses only HTTP (`ragu.com` is an option).

```
root@grIDS:~# tcpdump -i $INTERFACE port 80
```

#### Promisc on boot
Now that the configuration has been validated, save these settings to `/etc/network/interfaces` where `$INTERFACE` is the name of the interface you configured earlier:

```
up ip link set $INTERFACE multicast off
up ip link set $INTERFACE up
up ip link set $INTERFACE promisc on
```
