# BitSend (BSD) Masternode - Dockerfile (05-2018)
#
# The Dockerfile will install all required stuff to run a BitSend (BSD) Masternode and is based on script bsdsetup.sh (see: https://github.com/dArkjON/BSD-Masternode-Setup-1604/blob/master/bsdsetup.sh)
# BitSend Repo : https://github.com/LIMXTEC/BitSend
# E-Mail: info@bitsend.info
# 
# To build a docker image for bsd-masternode from the Dockerfile the bitsend.conf is also needed.
# See BUILD_README.md for further steps.

# Use an official Ubuntu runtime as a parent image
FROM ubuntu:16.04

LABEL maintainer="Jon D. (dArkjON), David B. (dalijolijo)"
LABEL version="0.1"

# Make ports available to the world outside this container
EXPOSE 8886 8800

USER root

# Change sh to bash
SHELL ["/bin/bash", "-c"]

# Define environment variable
ENV BSDPWD "bitsend"

RUN echo '********************************' && \
    echo '*** BitSend (BSD) Masternode ***' && \
    echo '********************************'

#
# Step 1/10 - creating bitsend user
#
RUN echo '*** Step 1/10 - creating bitsend user ***' && \
    adduser --disabled-password --gecos "" bitsend && \
    usermod -a -G sudo,bitsend bitsend && \
    echo bitsend:$BSDPWD | chpasswd && \
    echo '*** Done 1/10 ***'

#
# Step 2/10 - Allocating 2GB Swapfile
#
RUN echo '*** Step 2/10 - Allocating 2GB Swapfile ***' && \
    echo 'not needed: skipped' && \
    echo '*** Done 2/10 ***'

#
# Step 3/10 - Running updates and installing required packages
#
RUN echo '*** Step 3/10 - Running updates and installing required packages ***' && \
    apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y  apt-utils \
                        autoconf \
                        automake \
                        autotools-dev \
                        build-essential \
                        curl \
                        git \
                        libboost-all-dev \
                        libevent-dev \
                        libminiupnpc-dev \
                        libssl-dev \
                        libtool \
                        libzmq5-dev \
                        pkg-config \
                        software-properties-common \
                        sudo \
                        supervisor \
                        vim \
                        wget && \
    add-apt-repository -y ppa:bitcoin/bitcoin && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y  libdb4.8-dev \
                        libdb4.8++-dev && \
    echo '*** Done 3/10 ***'

#
# Step 4/10 - Cloning and Compiling BitSend Wallet
#
RUN echo '*** Step 4/10 - Cloning and Compiling BitSend Wallet ***' && \
    cd && \
    echo "Execute a git clone of LIMXTEC/BitSend. Please wait..." && \
    git clone --branch v0.14 --depth 1 https://github.com/LIMXTEC/BitSend && \
    cd BitSend && \
    ./autogen.sh && \
    ./configure --disable-dependency-tracking --enable-tests=no --without-gui && \
    make && \
    cd && \
    cd BitSend/src && \
    strip bitsendd && \
    cp bitsendd /usr/local/bin && \
    strip bitsend-cli && \
    cp bitsend-cli /usr/local/bin && \
    chmod 775 /usr/local/bin/bitsend* && \   
    cd && \
    rm -rf BitSend && \
    echo '*** Done 4/10 ***'

#
# Step 5/10 - Adding firewall rules
#
RUN echo '*** Step 5/10 - Adding firewall rules ***' && \
    echo 'must be configured on the socker host: skipped' && \
    echo '*** Done 5/10 ***'

#
# Step 6/10 - Configure bitsend.conf
#
COPY bitsend.conf /tmp
RUN echo '*** Step 6/10 - Configure bitsend.conf ***' && \
    chown bitsend:bitsend /tmp/bitsend.conf && \
    sudo -u bitsend mkdir -p /home/bitsend/.bitsend && \
    sudo -u bitsend cp /tmp/bitsend.conf /home/bitsend/.bitsend/ && \
    echo '*** Done 6/10 ***'

#
# Step 7/10 - Adding bitsendd daemon as a service
#
RUN echo '*** Step 7/10 - Adding bitsendd daemon ***' && \
    echo 'docker not supported systemd: skipped' && \
    echo '*** Done 7/10 ***'

#
# Supervisor Configuration
#
COPY *.sv.conf /etc/supervisor/conf.d/

#
# Logging outside docker container
#
VOLUME /var/log

#
# Start script
#
COPY start.sh /usr/local/bin/start.sh
RUN \
  rm -f /var/log/access.log && mkfifo -m 0666 /var/log/access.log && \
  chmod 755 /usr/local/bin/*

ENV TERM linux
CMD ["/usr/local/bin/start.sh"]
