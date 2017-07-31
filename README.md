# grIDS
Pronounced "grr eye dee es" - My network monitoring solution and tools that go along with it.

# Configuration Steps

## Setup the Hardware and the OS
This step is all about getting the system ready for the suite of tools we're going to be installing.

[Hardware/OS configuration](hardware_and_os.md)

## Configuring the Elastic Stack
This step is about configuring our Elastic stack to store the data that we're generating, and make it easily searchable.

[Elastic Stack Configuration](elastic_stack.md)

## Suricata Configuration
This step is about configuring the IDS/IPS software, Suricata.

[Suricata Configuration](suricata_configuration.md)

## PulledPork Configuration - TODO
This step is about configuring the Suricata rule management tool, PulledPork

[PulledPork Configuration]()

## Bro Configuration - TODO
This step is all about configuring the NSM tool called Bro

[Bro Configuration]()

# Future Additions + Modifications
This is a list of future tools that could be added to this toolset for even more features. Also includes modifications.

#### Features
* Sysmon logging
* Centralized Logging
* Webhook integration for alerts
* Kibana dashboard exports
* FPC and usability tools

#### Modifications
* Performance tuning for Elastic Stack
* Performance tuning of Suricata - spread load between CPU threads
