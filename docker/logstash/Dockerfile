# Dockerfile to build a Logstash container with the proper configuration

# Set the base image to Elastic's Logstash docker container
FROM docker.elastic.co/logstash/logstash:6.4.1

# File Author
MAINTAINER gradiuscypher

# Remove the old Logstash config
# Reference: https://www.elastic.co/guide/en/logstash/current/_configuring_logstash_for_docker.html#_custom_images
RUN rm -f /usr/share/logstash/pipeline/logstash.conf

# Copy the config to its config location
ADD beats_to_elastic.conf /usr/share/logstash/pipeline/beats_to_elastic.conf
