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
LABEL version="0.2"

# Make ports available to the world outside this container
EXPOSE 8886 8800

USER root

# Change sh to bash
SHELL ["/bin/bash", "-c"]

# Define environment variable
ENV BSDPWD "bitsend"

RUN echo '*** BitSend (BSD) Masternode ***'

#
# Creating bitsend user
#
RUN echo '*** Creating bitsend user ***' && \
    adduser --disabled-password --gecos "" bitsend && \
    usermod -a -G sudo,bitsend bitsend && \
    echo bitsend:$BSDPWD | chpasswd

#
# Running updates and installing required packages
#
RUN echo '*** Running updates and installing required packages ***' && \
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
                        libdb4.8++-dev

#
# Cloning and Compiling BitSend Wallet
#
RUN echo '*** Cloning and Compiling BitSend Wallet ***' && \
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
    rm -rf BitSend

#
# Copy Supervisor Configuration and bitsend.conf
#
RUN echo '*** Copy Supervisor Configuration and bitsend.conf ***'
COPY *.sv.conf /etc/supervisor/conf.d/
COPY bitsend.conf /tmp

#
# Logging outside docker container
#
VOLUME /var/log

#
# Copy start script
#
RUN echo '*** Copy start script ***'
COPY start.sh /usr/local/bin/start.sh
RUN rm -f /var/log/access.log && mkfifo -m 0666 /var/log/access.log && \
    chmod 755 /usr/local/bin/*

ENV TERM linux
CMD ["/usr/local/bin/start.sh"]
