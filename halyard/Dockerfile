FROM ubuntu:14.04

USER root 
RUN useradd -ms /bin/bash spinnaker

#Install awscli
RUN apt-get update && \
	apt-get install -y python python-pip curl apt-transport-https ca-certificates software-properties-common && \
	pip install --default-timeout=100 awscli && \
	rm -rf /var/lib/apt/lists/*

#Install kubectl 
RUN	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
	echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list && \
	apt-get update && \
	apt-get install -y kubectl && \
	rm -rf /var/lib/apt/lists/*

#Install halyard
RUN curl -O https://quid.jfrog.io/quid/http-quid/public/halyard/InstallHalyard.sh && \
    bash InstallHalyard.sh --user spinnaker

RUN chown -R spinnaker:spinnaker /home/spinnaker/

COPY backup.sh /backup.sh

RUN chmod 755 /backup.sh

COPY entrypoint.sh /entrypoint.sh

RUN chmod 755 /entrypoint.sh
