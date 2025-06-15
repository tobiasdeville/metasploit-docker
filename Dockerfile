FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install system packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    unzip \
    ca-certificates \
    build-essential \
    python3 \
    python3-pip \
    python3-dev \
    ruby \
    ruby-dev \
    postgresql-client \
    nmap \
    netcat-openbsd \
    openssl \
    hydra \
    john \
    sqlmap \
    net-tools \
    iputils-ping \
    dnsutils \
    whois \
    perl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install only essential Python packages
RUN pip3 install --no-cache-dir --break-system-packages \
    requests \
    beautifulsoup4 \
    dnspython

# Install Nikto
WORKDIR /opt
RUN git clone https://github.com/sullo/nikto.git && \
    chmod +x /opt/nikto/program/nikto.pl && \
    ln -s /opt/nikto/program/nikto.pl /usr/local/bin/nikto

# Install Metasploit
RUN curl -s https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
    chmod 755 msfinstall && \
    ./msfinstall && \
    rm msfinstall

# Create user with specific UID/GID
RUN groupadd -g 1000 pentester && \
    useradd -u 1000 -g 1000 -m -s /bin/bash pentester && \
    echo "pentester:pentester" | chpasswd && \
    usermod -aG sudo pentester && \
    echo "pentester ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to pentester user and create directories
USER pentester
WORKDIR /home/pentester

# Create directories as the pentester user
RUN mkdir -p scripts shared wordlists results .msf4 && \
    chmod 755 .msf4

# Copy the setup script and make it executable
COPY --chown=pentester:pentester setup-metasploit.sh /home/pentester/scripts/setup-metasploit.sh
RUN chmod +x /home/pentester/scripts/setup-metasploit.sh

EXPOSE 4444 8080 8443
CMD ["/bin/bash"]
