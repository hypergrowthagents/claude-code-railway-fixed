#!/bin/bash

# Set SSH_USERNAME and SSH_PASSWORD by default or create an .env file (refer to.env.example)
: ${SSH_USERNAME:="myuser"}
: ${SSH_PASSWORD:="mypassword"}

# Set root password if root login is enabled
: ${ROOT_PASSWORD:=""}
if [ -n "$ROOT_PASSWORD" ]; then
    echo "root:$ROOT_PASSWORD" | chpasswd
    echo "Root password set"
else
    echo "Root password not set"
fi

# Set authorized keys if applicable
: ${AUTHORIZED_KEYS:=""}

# Set timezone if provided
: ${TZ:=""}
if [ -n "$TZ" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
    echo "Timezone set to: $TZ"
fi

# Set SSH banner if provided
: ${SSH_BANNER:=""}
if [ -n "$SSH_BANNER" ]; then
    echo "$SSH_BANNER" > /etc/ssh/banner
    echo "Banner /etc/ssh/banner" >> /etc/ssh/sshd_config
    echo "SSH banner configured"
fi

# Check if SSH_USERNAME or SSH_PASSWORD is empty and raise an error
if [ -z "$SSH_USERNAME" ] || [ -z "$SSH_PASSWORD" ]; then
    echo "Error: SSH_USERNAME and SSH_PASSWORD must be set." >&2
    exit 1
fi

# Create the user with the provided username and set the password
if id "$SSH_USERNAME" &>/dev/null; then
    echo "User $SSH_USERNAME already exists"
else
    useradd -ms /bin/bash "$SSH_USERNAME"
    echo "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd
    # Add user to sudo group
    usermod -aG sudo "$SSH_USERNAME"
    echo "User $SSH_USERNAME created with the provided password and added to sudo group"
fi

# Set the authorized keys from the AUTHORIZED_KEYS environment variable (if provided)
if [ -n "$AUTHORIZED_KEYS" ]; then
    mkdir -p /home/$SSH_USERNAME/.ssh
    echo "$AUTHORIZED_KEYS" > /home/$SSH_USERNAME/.ssh/authorized_keys
    chown -R $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME/.ssh
    chmod 700 /home/$SSH_USERNAME/.ssh
    chmod 600 /home/$SSH_USERNAME/.ssh/authorized_keys
    echo "Authorized keys set for user $SSH_USERNAME"
    # Disable password authentication if authorized keys are provided
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
else
    echo "Authorized keys not set"
fi

# Set up development tools and configure environment
echo "Setting up development environment..."
if [ -f "/usr/local/bin/setup-dev-tools.sh" ]; then
    bash /usr/local/bin/setup-dev-tools.sh
else
    echo "Warning: setup-dev-tools.sh not found"
fi

# Create development directory
echo "Setting up development workspace..."
mkdir -p "/home/$SSH_USERNAME/dev"
chown "$SSH_USERNAME:$SSH_USERNAME" "/home/$SSH_USERNAME/dev"

echo "Development environment setup completed"

# Configure logging
: ${LOG_LEVEL:="INFO"}
echo "LogLevel $LOG_LEVEL" >> /etc/ssh/sshd_config
echo "SyslogFacility AUTH" >> /etc/ssh/sshd_config

# Start the SSH server
echo "Starting SSH server with log level: $LOG_LEVEL"
exec /usr/sbin/sshd -D