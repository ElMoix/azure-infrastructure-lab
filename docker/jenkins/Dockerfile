FROM jenkins/jenkins:lts-jdk21

USER root

WORKDIR /tmp

COPY setup-jenkins.sh .

RUN chmod +x setup-jenkins.sh && \
    ./setup-jenkins.sh

USER jenkins

COPY ./plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY ./jobs /usr/share/jenkins/ref/jobs

RUN jenkins-plugin-cli \
    --plugin-file /usr/share/jenkins/ref/plugins.txt


COPY ./casc/jenkins.yaml /usr/share/jenkins/ref/casc_configs/jenkins.yaml
