FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

# Install all the required packages
RUN apt-get update && apt-get install -y wget xz-utils build-essential libnghttp2-dev libcap-dev libssl-dev perl pkg-config python3-pip && rm -rf /var/lib/apt/lists/*
RUN pip3 install ply

# Download the source code
RUN cd /usr/bin && wget https://downloads.isc.org/isc/bind9/9.11.9/bind-9.11.9.tar.gz && tar -xf bind-9.11.9.tar.gz

# Build
RUN cd /usr/bin/bind-9.11.9 && ./configure && make && make install

# Create the empty configuration file at the default location
RUN touch /etc/named.conf
