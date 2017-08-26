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
