# syntax=docker/dockerfile:1

#########################################################################
#                                                                       #
#   Thought Bridge application - Dockerfile                             #
#                                                                       #
#   Create a docker image with Apache Tomcat for a web application      #
#   load a .WAR file into Tomcat for the bridge application             #
#   load ThoughtJ blockchain on Tomcat start                            #
#   Install hardhat for smartcontract deploying                         #
#                                                                       #
#########################################################################

#######################
#   Docker commands   #
#######################

# Use base image node:18-alpine
FROM ubuntu:20.04 

# The working directory of the application in the container
WORKDIR /app

#######################
#   Ubuntu commands   #
#######################

# Update packages and remove temps
RUN apt-get update && \
    apt-get install --no-install-recommends -y  wget curl cmake default-jdk make gcc g++ autoconf autotools-dev bsdmainutils libevent-dev libboost-system-dev \
                                                libboost-filesystem-dev libboost-test-dev libboost-thread-dev libboost-all-dev nodejs build-essential git && \
                                                libcurl4-openssl-dev libdb++-dev libssl-dev libtool pkg-config python python3-pip libzmq3-dev\
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

##########################
#   Hardhat + Avalanche  # https://docs.avax.network/build/dapp/smart-contracts/toolchains/hardhat
##########################

# Install Golang 1.20
ENV GOLANG_VERSION 1.20
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 5a9ebcc65c1cce56e0d2dc616aff4c4cedcfbda8cc6f0288cc08cda3b18dcbf1

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
  && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
  && tar -C /usr/local -xzf golang.tar.gz \
  && rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# Install hardhat for Smart Contracts
RUN npm install --save-dev hardhat

# Install yarn
RUN npm install -g yarn

# Get avalanche
RUN git clone https://github.com/ava-labs/avalanche-smart-contract-quickstart.git
RUN cd avalanche-smart-contract-quickstart
RUN yarn

# Start avalanche network runner
# RUN cd /path/to/Avalanche-Network-Runner
# RUN avalanche-network-runner server \
#     --log-level debug \
#     --port=":30200" \
#     --grpc-gateway-port=":30201"

# Fund accounts
#RUN cd /path/to/avalanche-smart-contract-quickstart
#RUN yarn fund-cchain-addresses

# Check Balances
#RUN yarn balances --network local

# Compile smart contract
#RUN yarn compile

# Deploy the smart contract
#RUN yarn deploy --network local

# Interact with smart contract
#RUN yarn console --network local

# Create and expose a JSON-RPC node of Hardhat
# This will expose a JSON-RPC interface to Hardhat Network. To use it connect your wallet or application to http://127.0.0.1:8545
#RUN npx hardhat node

# Deploy smart contract in localhost network
#RUN npx hardhat run --network localhost scripts/deploy.js

# Copy hardhat config into app
COPY ./config/hardhat.config.js /app/thought-bridge

# Build Avalanche
RUN ./scripts/build.sh

# Run Avalanche daemon
RUN ./build/avalanchego

#####################
#   Apache Tomcat   #
#####################

# Add a user for Tomcat service
RUN useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat

# Get the Apache Tomcat package
RUN wget -c https://downloads.apache.org/tomcat/tomcat-9/v9.0.34/bin/apache-tomcat-9.0.34.tar.gz

# Untar the package
RUN tar xf apache-tomcat-9.0.34.tar.gz -C /opt/tomcat

# Create a symbolic link to Tomcat installation directory
RUN ln -s /opt/tomcat/apache-tomcat-9.0.34 /opt/tomcat/updated

# Provide ownership to Tomcate directory to the Tomcat User
RUN chown -R tomcat: /opt/tomcat/*

# Make Tomcat scripts executable
RUN sh -c 'chmod +x /opt/tomcat/updated/bin/*.sh'


# Copy tomcat config into app
COPY ./config/tomcat.service /etc/systemd/system/tomcat.service

# Update system about new file
RUN systemctl daemon-reload

# Start Tomcat
RUN systemctl start tomcat

# Enable run on startup
RUN systemctl enable tomcat

# Allow port 8080 for communication
RUN ufw allow 8080/tcp



# Describe which ports your application is listening on
EXPOSE 8080

#
# use "docker build -t getting-started ."                       to build the docker image
#
# use "docker run -dp 127.0.0.1:3000:3000 getting-started"      to run the image
# 
# =============
# FLAGS
# =============
#
# -dp = --detach (runs container in background), --publish (creates a portmapping between HOST:CONTAINER)
#
