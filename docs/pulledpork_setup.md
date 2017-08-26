# PulledPork Configuration

## Summary
PulledPork is a Perl script that's used to manage rules for Suricata and Snort. PulledPork creates bundled rule files into a single file. It can modify/disable which rules get included in the bundled file, can can pull from multiple sources. PulledPork has multiple configuration files that determine which rules to enable or disable.

### enablesid.conf / disablesid.conf / modifysid.conf
When PulledPork is creating a new bundled ruleset, it references this configuration file to determine which rules to included as commented out. This is helpful when tuning your IDS, for example when disabling/modifying noisy or low-value rules.

### dropsid.conf
Modify a signature to drop traffic when a rule is triggered rather than alerting. In the grIDS setup, the sensor is not inline, so it cannot do any blocking. We won't be touching this file.

## Setup
### Download from Github
Download PulledPork from their [Github](https://github.com/shirkdog/pulledpork) repo.

```
root@grIDS:~# git clone https://github.com/shirkdog/pulledpork.git
```

### Install required PulledPork modules
```
root@grIDS:~/pulledpork# apt-get install libwww-perl libcrypt-ssleay-perl
```

### Copy pulledpork.pl to /usr/bin and test execution
```
root@grIDS:~# cd pulledpork/
root@grIDS:~/pulledpork# cp pulledpork.pl /usr/bin/
root@grIDS:~/pulledpork# pulledpork.pl -V
```

Expected output:
```
PulledPork v0.7.3 - Making signature updates great again!
```

### Copy config files
```
root@grIDS:~/pulledpork# cd etc/
root@grIDS:~/pulledpork/etc# mkdir /etc/pulledpork
root@grIDS:~/pulledpork/etc# cp * /etc/pulledpork/
```

### Modify pulledpork.conf
We'll prep the pulledpork.conf with the settings that we need.

#### Remove rule_urls
The EmergingThreats ruleset contains Suricata specific rules, which is what we'll be using.

We'll disable these rules by commenting them out:
```
rule_url=https://www.snort.org/reg-rules/|snortrules-snapshot.tar.gz|<oinkcode>
rule_url=https://snort.org/downloads/community/|community-rules.tar.gz|Community
rule_url=https://talosintelligence.com/documents/ip-blacklist|IPBLACKLIST|open
rule_url=https://snort.org/downloads/community/|opensource.gz|Opensource
```

We'll enable this EmergingThreats URL by uncommenting its line:
```
rule_url=https://rules.emergingthreats.net/|emerging.rules.tar.gz|open-nogpl
```

#### Modify rule_paths
This is where PulledPork stores the rules it's downloaded. We're going to change its location to where Suricata reads its rules:

Modify this line:
```
rule_path=/usr/local/etc/snort/rules/snort.rules
```

To:
```
rule_path=/etc/suricata/rules/downloaded.rules
```

Secondly, we'll want to modify where PulledPork finds its `local.rules`. This file is where you can store custom written rules that will be incorproated into `downloaded.rules`.

Modify this line:
```
local_rules=/usr/local/etc/snort/rules/local.rules
```

To:
```
local_rules=/etc/suricata/rules/local.rules
```

Lastly, modify the sid-msg.map to a directory that exists. sid-msg is used for Snort and a process called unified2, for identifying alert IDs. It's not used our process, but PulledPork needs a valid directory here or it won't run.

From:
```
sid_msg=/usr/local/etc/snort/sid-msg.map
```

To:
```
sid_msg=/etc/suricata/rules/sid-msg.map
```

## Doing a test-run of PulledPork
TODO

## Automated scripts and cron setup
TODO
