#!/bin/bash

set -e

echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
export DEBIAN_FRONTEND=noninteractive

echo "Checking disk space..."
df -h 

sudo useradd -m -s /bin/bash jenkins

sudo mkdir -p /var/lib/jenkins /usr/share/jenkins/ref /var/lib/jenkins/plugins

sudo mv /tmp/plugins.txt /usr/share/jenkins/ref/plugins.txt

sudo chown -R jenkins:jenkins /var/lib/jenkins /usr/share/jenkins


# JAVA INSTALLATION - jdk17

echo " JAVA INSTALLTION BEGINS....."

sudo apt-get update 

sudo add-apt-repository universe

sudo apt-get install -y openjdk-17-jdk

echo "java version is  $(java --version)"

# Jenkins Installation

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

sudo wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.2/jenkins-plugin-manager-2.13.2.jar

sudo wget -O /usr/share/jenkins/jenkins.war https://get.jenkins.io/war-stable/latest/jenkins.war




sudo java -jar jenkins-plugin-manager-*.jar \
  --war /usr/share/jenkins/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins/ \
  --plugin-file /usr/share/jenkins/ref/plugins.txt \
  --plugins delivery-pipeline-plugin:1.3.2 deployit-plugin




sudo mkdir -p /etc/jenkins/casc
sudo cp /tmp/jenkins.yaml /etc/jenkins/casc/jenkins.yaml
sudo chown -R jenkins:jenkins /etc/jenkins

sudo mkdir -p /etc/systemd/system/jenkins.service.d

echo "[Service]
Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false\"
Environment=\"CASC_JENKINS_CONFIG=/etc/jenkins/casc/jenkins.yaml\"
" | sudo tee /etc/systemd/system/jenkins.service.d/override.conf



sudo systemctl daemon-reexec
sudo systemctl daemon-reload



sudo systemctl enable jenkins 
sudo systemctl start jenkins
sudo ufw allow 8080
sudo rm -f /var/lib/jenkins/secrets/initialAdminPassword
sudo sleep 10
