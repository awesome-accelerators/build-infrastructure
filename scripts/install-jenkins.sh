#!/bin/bash
set -exu

plugins=$1

function wait_jenkins_to_start() {
    echo "Waiting jenkins to launch on 8080..."

    while ! nc -z localhost 8080; do
      sleep 0.1 # wait for 1/10 of the second before check again
    done

    echo "Jenkins launched"
    sleep 2        
}

sudo yum update -y
echo "* Installing java 1.8"
sudo yum install -y java-1.8.0-openjdk-devel

echo "* Set default java"
sudo /usr/sbin/alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
sudo yum remove -y java-1.7*


echo "* Import GPG key"
curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo

echo "* add jenkins repo"
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key


echo "* Install latest Jenkins under /var/lib/jenkins"
# pay attention to version needs to be used latter on disabling the setup wizard
sudo yum install -y jenkins-2.150.2-1.1.noarch

echo "Tool for handling xml files"
sudo yum install -y xmlstarlet

echo "* Start Jenkins without asking to install plugins"
export JAVA_OPTS=-Djenkins.install.runSetupWizard=false

sudo service jenkins start
sudo chkconfig --add jenkins
sudo chkconfig jenkins on

# disable setup wizard
sudo mkdir -p /var/lib/jenkins/init.groovy.d
sudo chmod 777 -R /var/lib/jenkins/init.groovy.d
cat <<EOF >> /var/lib/jenkins/init.groovy.d/basic-security.groovy
#!groovy

import jenkins.model.*
import jenkins.install.*;
import hudson.util.*;
import hudson.security.*
import static jenkins.model.Jenkins.instance as jenkins
import jenkins.install.InstallState

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)


hudsonRealm.createAccount('{{ jenkins_admin_username }}','{{ jenkins_admin_password }}')
instance.setSecurityRealm(hudsonRealm)

instance.setAuthorizationStrategy(strategy)
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
instance.setNumExecutors(1)
instance.save()

if (!jenkins.installState.isSetupComplete()) {
  println '--> Initial Setup Completed'
  InstallState.INITIAL_SETUP_COMPLETED.initializeState()
}

EOF

wait_jenkins_to_start
sleep 20
ADMIN_PASSW=$(sudo bash -c "cat /var/lib/jenkins/secrets/initialAdminPassword")

sudo wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O /var/lib/jenkins/jenkins-cli.jar

echo "* Installing the following plugins: ${plugins}"
for i in ${plugins//,/ }
do
  sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -auth admin:$ADMIN_PASSW install-plugin "$i"
done

sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -auth admin:$ADMIN_PASSW restart

echo "Cleanup"
sudo yum -y clean all
sudo find /var/log -type f -delete
sudo find /tmp -type f -delete
sudo find /root /home -name '.*history' -delete
wait_jenkins_to_start

sleep 30
# delete init.groovy.d configuration folder
sudo rm -rf /var/lib/jenkins/init.groovy.d

echo "Admin Password is: ${ADMIN_PASSW}"
