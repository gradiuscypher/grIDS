# Dockerfile to build a Suricata docker container

# Set the base image to Ubuntu
FROM ubuntu

# File Author
LABEL maintainer='gradiuscypher' \
      source_repo='https://github.com/gradiuscypher/grIDS'

# Update the main repo, add repos and install filebeat and suricata
RUN apt update && \
    apt install -y software-properties-common wget apt-transport-https && \
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list && \
    add-apt-repository -y ppa:oisf/suricata-stable && \
    apt update && apt install -y suricata && \
    apt install -y filebeat

# Copy the suricata config to its config location
ADD filebeat.yml /etc/filebeat
RUN chown root /etc/filebeat/filebeat.yml && \
    chmod 0644 /etc/filebeat/filebeat.yml

# Copy the suricata config to its config location
ADD suricata.yaml /etc/suricata/suricata.yaml

# Start the Suricata/Filebeat service when the container is started
CMD service suricata start && service filebeat start && tail -F /var/log/suricata/suricata.log
