FROM ubuntu:latest

# Maintainer
LABEL maintainer="uschti@gmail.com"

# Install system dependencies
RUN apt-get update && apt-get install python3 python3-pip curl git -y

RUN mkdir -p /data/letsencrypt
WORKDIR /data/letsencrypt

# Install Cert/Acme dependencies
RUN git clone https://github.com/lukas2511/dehydrated
RUN ./dehydrated/dehydrated --register --accept-terms

# Set HOOK_CHAIN=yes to allow wildcard certificates (https://github.com/josteink/le-godaddy-dns#hook_chain)
RUN echo HOOK_CHAIN=\"yes\" >> /data/letsencrypt/dehydrated/config

RUN git clone https://github.com/josteink/le-godaddy-dns
RUN cd le-godaddy-dns && python3 -m pip install -r requirements.txt --user

# Get domains and godaddy parameters
ARG GD_KEY=undefined
ARG GD_SECRET=undefined
ARG SLACK_URL=undefined
ARG SLACK_DOMAIN_TITLE=undefined
ARG SLACK_CHANNEL=undefined

ENV GD_KEY $GD_KEY
ENV GD_SECRET $GD_SECRET
ENV SLACK_URL $SLACK_URL
ENV SLACK_DOMAIN_TITLE $SLACK_DOMAIN_TITLE
ENV SLACK_CHANNEL $SLACK_CHANNEL


# Copy config and script files
COPY renew_certificates.sh ./

# Mount volues to store certs and keys outside docker
VOLUME ["/data/letsencrypt/dehydrated/certs", "/data/certs", "/data/keys"]

ENTRYPOINT ["./renew_certificates.sh"]
