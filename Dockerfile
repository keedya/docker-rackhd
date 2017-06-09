FROM node:4


RUN apt-get update &&\
    apt-get install -y git apt-utils \
    ipmitool openipmi unzip curl \
    libsnmp-dev snmp

WORKDIR /RackHD/on-tasks

RUN git clone https://github.com/rackhd/on-tasks . &&\
    npm install --production

WORKDIR /RackHD/on-core

RUN git clone https://github.com/rackhd/on-core . &&\
    npm install --production

WORKDIR /RackHD/on-taskgraph

RUN git clone https://github.com/rackhd/on-taskgraph . &&\
    mkdir -p ./node_modules &&\
    ln -s /RackHD/on-tasks ./node_modules/on-tasks &&\
    ln -s /RackHD/on-core ./node_modules/on-core &&\
    npm install --production

WORKDIR /RackHD/on-http

RUN git clone https://github.com/rackhd/on-http . &&\
    mkdir -p ./node_modules &&\
    ln -s /RackHD/on-core ./node_modules/on-core &&\
    npm install \
 && /RackHD/on-http/install-web-ui.sh \
 && /RackHD/on-http/install-swagger-ui.sh \
 && npm prune --production

WORKDIR /RackHD/on-tftp

RUN git clone https://github.com/rackhd/on-tftp . &&\ 
    mkdir -p ./node_modules &&\
    ln -s /RackHD/on-core ./node_modules/on-core &&\
    npm install --production

WORKDIR /RackHD/on-dhcp-proxy

RUN git clone https://github.com/rackhd/on-dhcp-proxy . &&\
    mkdir -p ./node_modules &&\
    ln -s /RackHD/on-core ./node_modules/on-core &&\
    npm install --production


WORKDIR /RackHD/on-syslog

RUN git clone https://github.com/rackhd/on-syslog . &&\
    mkdir -p ./node_modules &&\
    ln -s /RackHD/on-core ./node_modules/on-core &&\
    npm install --production

WORKDIR /RackHD
COPY ./rackhd-pm2-config.yml rackhd-pm2-config.yml
COPY ./monorail /opt/monorail
COPY ./download_static_files.sh download_static_files.sh

RUN npm install -g pm2

RUN apt-get install -y rabbitmq-server mongodb netmask isc-dhcp-server
COPY ./conf/dhcpd.conf /etc/dhcp/dhcpd.conf

RUN rm -rf /var/lib/apt/lists/*

CMD service isc-dhcp-server start &&\
    service mongodb start &&\
    service rabbitmq-server start &&\
    ./download_static_files.sh &&\
    pm2 start rackhd-pm2-config.yml
