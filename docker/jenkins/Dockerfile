FROM jenkins/jenkins:lts-jdk21

USER root

WORKDIR /tmp

COPY setup-docker.sh .

RUN chmod +x setup-docker.sh && \
    ./setup-docker.sh

USER jenkins

COPY jenkins/plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY jenkins/jobs /usr/share/jenkins/ref/jobs

RUN jenkins-plugin-cli \
    --plugin-file /usr/share/jenkins/ref/plugins.txt


COPY jenkins/casc/jenkins.yaml /var/jenkins_home/jenkins.yaml


ENV CASC_JENKINS_CONFIG=/var/jenkins_home/jenkins.yaml
