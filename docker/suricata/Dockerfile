# Dockerfile to build a Suricata docker container

# Set the base image to Ubuntu
FROM ubuntu

# File Author
MAINTAINER gradiuscypher

# Update the repos
RUN apt update

# Allows us to add repositories
RUN apt install -y software-properties-common

# Add the Suricata repository
RUN add-apt-repository -y ppa:oisf/suricata-stable

# Update the repos and install Suricata
RUN apt update && apt install -y suricata

# Copy the config from Github to its config location
ADD https://raw.githubusercontent.com/gradiuscypher/grIDS/containerization/docker/suricata/suricata.yaml /etc/suricata/suricata.yaml

# Make the nsmdata folder
RUN mkdir -p /nsmdata/logs/suricata

# Start the Suricata service when the container is started
CMD service suricata start && tail -F /var/log/suricata/suricata.log
