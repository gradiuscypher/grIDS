# Rough Outline of tasks

### Elastic Setup
* Install Java
* Install and configure Elasticsearch
  * Adjust JVM settings for Elasticsearch
  * Change Elasticsearch configuration to be accessable on 0.0.0.0
* Install and configure Kibana
  * Change Kibana configuration to be accessable on 0.0.0.0
  
### Bro Setup
* TODO

### Suricata Setup
* TODO

### Filebeats Setup
* Configure Filebeats to pick up NSM logs
* Configure Filebeats to ship to local Elastic, might need Logstash in-between, not sure if want to use filebeats JSON sender yet.

### FPC Setup
* Copying of FPC to spinning disk after a limit
* Accessablity of packets - interface needed?

### PulledPork Setup
* TODO

### Other tooling
* Webhook alerting/notifications

### Finishing Touches
* Configure Kibana Dashboards and export settings
