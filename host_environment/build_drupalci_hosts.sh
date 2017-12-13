#!/bin/bash


# EC2 configuration
. ~/.ec2creds
. ~/.atlascreds
# Exit immediately on uninitialized variable or error, and print each command.
# But do this after the .ec2creds so as to not display secrets everywhere
set -uex
export EC2_HOME=/opt/ec2/ec2-api-tools-1.7.3.2
export EC2_URL=ec2.us-west-2.amazonaws.com
export JAVA_HOME=/usr

# Packer configuration
export PACKER_HOME=/usr/local/bin
export PACKER_LOG=1
export AWS_POLL_DELAY_SECONDS=5
cd /usr/local/drupalci_environments/host_environment/debian-testbot
source packer_variables.sh
${PACKER_HOME}/packer build -force drupalci-jesse.json
