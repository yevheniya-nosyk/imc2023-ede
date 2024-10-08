# Copyright 2023 Yevheniya Nosyk
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

# Install all the required packages
RUN apt-get update && apt-get install -y wget build-essential libssl-dev libexpat1-dev bison flex && rm -rf /var/lib/apt/lists/*

# Download the source code
RUN cd /usr/bin && wget https://www.nlnetlabs.nl/downloads/unbound/unbound-1.20.0.tar.gz && tar -xf unbound-1.20.0.tar.gz 

# Build
RUN cd /usr/bin/unbound-1.20.0 && ./configure && make && make install

ENV LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH

# Listen on the IPv4 interface
RUN sed -i 's/# interface: 192.0.2.153/interface: 0.0.0.0/g' /usr/local/etc/unbound/unbound.conf
# Allow queries from all the hosts
RUN sed -i 's/# access-control: 127.0.0.0\/8 allow/access-control: 0.0.0.0\/0 allow/g' /usr/local/etc/unbound/unbound.conf
# Do not use unbound username
RUN sed -i 's/# username: "unbound"/username: ""/g' /usr/local/etc/unbound/unbound.conf
# Enable extended DNS errors
RUN sed -i 's/# ede: no/ede: yes/g' /usr/local/etc/unbound/unbound.conf
RUN sed -i 's/# ede-serve-expired: no/ede-serve-expired: yes/g' /usr/local/etc/unbound/unbound.conf

# Generate the root zone key
RUN unbound-anchor; exit 0
# Load it
RUN sed -i 's\# auto-trust-anchor-file: "/usr/local/etc/unbound/root.key"\auto-trust-anchor-file: "/usr/local/etc/unbound/root.key"\g' /usr/local/etc/unbound/unbound.conf

# Expose ports
EXPOSE 53/udp 53/tcp

# Run unbound daemon
CMD ["unbound", "-d"]
