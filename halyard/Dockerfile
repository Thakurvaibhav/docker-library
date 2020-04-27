FROM ubuntu:14.04

USER root 
RUN useradd -ms /bin/bash spinnaker

#Install awscli
RUN apt-get update && \
	apt-get install -y python python-pip curl apt-transport-https ca-certificates software-properties-common && \
	pip install --default-timeout=100 awscli && \
	rm -rf /var/lib/apt/lists/*

#Install kubectl 
RUN curl -sSL https://storage.googleapis.com/kubernetes-release/release/v1.16.8/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

#Install halyard
RUN curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh && \
    bash InstallHalyard.sh --user spinnaker

RUN chown -R spinnaker:spinnaker /home/spinnaker/

COPY backup.sh /backup.sh

RUN chmod 755 /backup.sh

COPY entrypoint.sh /entrypoint.sh

RUN chmod 755 /entrypoint.sh
