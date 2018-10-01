# Dockerfile to build a Suricata docker container

# Set the base image to Ubuntu
FROM ubuntu

# File Author
MAINTAINER gradiuscypher

# Update the repos
RUN apt update

# Allows us to add repositories
RUN apt install -y software-properties-common wget apt-transport-https

# Add the Elastic key for Filebeat and add repo
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list

# Add the Suricata repository
RUN add-apt-repository -y ppa:oisf/suricata-stable

# Update the repos and install Suricata
RUN apt update && apt install -y suricata

# Install Filebeat
RUN apt install -y filebeat

# Copy the suricata config to its config location
ADD filebeat.yml /etc/filebeat

# Modify the filebeat config to only be editable by the owner
CMD chmod go-w /etc/filebeat/filebeat.yml

# Copy the suricata config to its config location
ADD suricata.yaml /etc/suricata/suricata.yaml

# Start the Suricata/Filebeat service when the container is started
CMD service suricata start && service filebeat start && tail -F /var/log/suricata/suricata.log
