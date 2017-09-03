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
If everything is configured properly, this command should grab the Suricata rules from Emerging Threats and save them to `/etc/suricata/rules/downloaded.rules`. This command should be run every time we want to update the ruleset. ET updates rules quite often, so we'll want to put a script that updates these rules and restart Suricata.

**Note:** PulledPork saves the downloaded rules tarbal to `/tmp/`. It will not process the rules or download them again if they match. If you wish to test this command again, you may have to delete the downloaded rules from `/tmp/`

```
root@grIDS:~# pulledpork.pl -c /etc/pulledpork/pulledpork.conf -T -S suricata-4.0.0

    https://github.com/shirkdog/pulledpork
      _____ ____
     `----,\    )
      `--==\\  /    PulledPork v0.7.3 - Making signature updates great again!
       `--==\\/
     .-~~~~-.Y|\\_  Copyright (C) 2009-2016 JJ Cummings
  @_/        /  66\_  cummingsj@gmail.com
    |    \   \   _(")
     \   /-| ||'--'  Rules give me wings!
      \_\  \_\\
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Checking latest MD5 for emerging.rules.tar.gz....
Rules tarball download of emerging.rules.tar.gz....
        They Match
        Done!
Prepping rules from emerging.rules.tar.gz for work....
        Done!
Reading rules...
Reading rules...
Setting Flowbit State....
        Enabled 109 flowbits
        Done
Writing /etc/suricata/rules/downloaded.rules....
        Done
Generating sid-msg.map....
        Done
Writing v1 /etc/suricata/rules/sid-msg.map....
        Done
Writing /var/log/sid_changes.log....
        Done
Rule Stats...
        New:-------0
        Deleted:---0
        Enabled Rules:----18053
        Dropped Rules:----0
        Disabled Rules:---4744
        Total Rules:------22797
No IP Blacklist Changes

Done
Please review /var/log/sid_changes.log for additional details
Fly Piggy Fly!
```

## Automated scripts and cron setup
Since the Emerging Threats ruleset can change as often as they push new rules, we'll want to download them as soon as they're out. We'll do that with our `update-rules.sh` script found [here](https://github.com/gradiuscypher/grIDS/blob/master/scripts/update_rules.sh).

### Download update-rules.sh and chmod

Prep the file location:
```
gradius@grIDS:~$ sudo -i
root@grIDS:~# mkdir scripts
root@grIDS:~# cd scripts/
```

Download the raw file via Github with wget:
```
root@grIDS:~/scripts# wget https://raw.githubusercontent.com/gradiuscypher/grIDS/master/scripts/update_rules.sh
--2017-09-03 14:47:31--  https://raw.githubusercontent.com/gradiuscypher/grIDS/master/scripts/update_rules.sh
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 151.101.0.133, 151.101.64.133, 151.101.128.133, ...
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|151.101.0.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1127 (1.1K) [text/plain]
Saving to: ‘update_rules.sh’

update_rules.sh                                             100%[========================================================================================================================================>]   1.10K  --.-KB/s    in 0s

2017-09-03 14:47:31 (250 MB/s) - ‘update_rules.sh’ saved [1127/1127]

root@grIDS:~/scripts# ls
update_rules.sh
```

chmod the file to make it executable:
```
root@grIDS:~/scripts# chmod +x update_rules.sh
```

### Configure root crontab
Now that we have a script to run, let's set it up in crontab to execute every 15 minutes, that way we can pick up the rules as soon as possible.

```
root@grIDS:~/scripts# crontab -e
```

Add this to the bottom:
```
*/15 * * * * /root/scripts/update-rules.sh
```
