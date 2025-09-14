FROM ubuntu:24.04

# Remove default ubuntu user to free UID/GID 1000
RUN userdel -r ubuntu 2>/dev/null || true

# System deps + SSH
RUN apt-get update \
    && apt-get install -y \
        iproute2 iputils-ping openssh-server telnet sudo \
        curl wget git unzip build-essential \
        postgresql-client redis-tools \
        ca-certificates gnupg lsb-release \
        python3 python3-pip python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /run/sshd \
    && chmod 755 /run/sshd \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "PermitRootLogin no" >> /etc/ssh/sshd_config \
    && echo "MaxAuthTries 3" >> /etc/ssh/sshd_config \
    && echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config \
    && echo "ClientAliveCountMax 2" >> /etc/ssh/sshd_config \
    && echo "Protocol 2" >> /etc/ssh/sshd_config

# Node.js 20.x LTS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# ripgrep (Claude Code needs this)
RUN curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb \
    && dpkg -i ripgrep_14.1.1-1_amd64.deb \
    && rm ripgrep_14.1.1-1_amd64.deb

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Railway CLI (no Ruby needed)
RUN npm install -g @railway/cli

# Copy helper scripts
COPY ssh-user-config.sh /usr/local/bin/
COPY setup-dev-tools.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/ssh-user-config.sh \
    && chmod +x /usr/local/bin/setup-dev-tools.sh

# Clean SSH login
RUN rm -f /etc/motd \
    && rm -f /etc/update-motd.d/* \
    && touch /etc/motd \
    && chmod 644 /etc/motd

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pgrep sshd > /dev/null || exit 1

EXPOSE 22 3000 3001 8080

CMD ["/usr/local/bin/ssh-user-config.sh"]
