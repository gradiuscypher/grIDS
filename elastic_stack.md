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
