FROM gcr.io/spinnaker-marketplace/halyard:stable

USER root 
WORKDIR /

#Install awscli
RUN apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel awscli && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

#Install gcloud
ENV PATH /google-cloud-sdk/bin:$PATH
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-290.0.0-linux-x86_64.tar.gz && \
	tar -xvf google-cloud-sdk-290.0.0-linux-x86_64.tar.gz && \
	gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version

COPY backup.sh /backup.sh

COPY entrypoint.sh /entrypoint.sh

RUN deluser spinnaker && \
    adduser -h /home/spinnaker \
    -s /bin/bash spinnaker \
    --disabled-password

RUN chown -R spinnaker:spinnaker /home/spinnaker

WORKDIR /home/spinnaker
