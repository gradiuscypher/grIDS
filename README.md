# grIDS
Pronounced "grr eye dee es" - My network monitoring solution and tools that go along with it.

# Configuration Steps - System, Data storage, IDS software

## Setup the Hardware and the OS
This step is all about getting the system ready for the suite of tools we're going to be installing.

[Hardware/OS configuration](docs/hardware_and_os.md)

## Configuring the Elastic Stack
This step is about configuring our Elastic stack to store the data that we're generating, and make it easily searchable.

[Elastic Stack Configuration](docs/elastic_stack.md)

## Suricata Configuration
This step is about configuring the IDS/IPS software, Suricata.

[Suricata Configuration](docs/suricata_configuration.md)

## PulledPork Configuration - TODO
This step is about configuring the Suricata rule management tool, PulledPork

[PulledPork Configuration](docs/pulledpork_setup.md)

## Kibana Visualization and Saved Searches - TODO
This step will help get Kibana configured with useful dashboards, visualizations, and saved searches

[Kibana Visualization and Searches]()

# Future Additions + Modifications + Ideas
This is a list of future tools that could be added to this toolset for even more features. Also includes modifications.

#### Features
* Sysmon logging
* Bro logging
* Centralized Logging
* Webhook integration for alerts
* FPC and usability tools

#### Modifications
* Performance tuning for Elastic Stack
* Performance tuning of Suricata - spread load between CPU threads
