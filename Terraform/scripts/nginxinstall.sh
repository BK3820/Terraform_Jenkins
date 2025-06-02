#!/bin/bash

JENKINS_PRIVATE_IP="$1"

# Validate input
if [ -z "$JENKINS_PRIVATE_IP" ]; then
    echo "Error: JENKINS_PRIVATE_IP is not provided."
    exit 1
fi

# Update and install Nginx
sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx

# Export the variable for envsubst
export JENKINS_PRIVATE_IP

echo "Jenkins private IP is: $JENKINS_PRIVATE_IP"

# Substitute the variable in the template and write to Nginx config using tee
envsubst '$JENKINS_PRIVATE_IP' < /tmp/jenkins.conf.template | sudo tee /etc/nginx/conf.d/jenkins.conf > /dev/null

# Display the generated config for verification
sudo cat /etc/nginx/conf.d/jenkins.conf

# Install SELinux utils (optional, as SELinux is disabled)
sudo apt install selinux-utils -y
sudo setenforce permissive || echo "SELinux is disabled or not installed"

sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/conf.d/default.conf 2>/dev/null


# Test and reload Nginx
sudo nginx -t
if [ $? -eq 0 ]; then
    sudo systemctl reload nginx
else
    echo "Nginx configuration test failed. Please check /etc/nginx/conf.d/jenkins.conf"
    exit 1
fi