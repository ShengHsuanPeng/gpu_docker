#!/bin/bash

# Convert USERS=gmm:pass1,dev1:pass2 format to create multiple users
IFS=',' read -ra accounts <<< "$USERS"
for account in "${accounts[@]}"; do
    IFS=':' read -ra parts <<< "$account"
    username="${parts[0]}"
    password="${parts[1]}"

    if ! id "$username" &>/dev/null; then
        echo "🧑 Creating user $username"
        useradd -ms /bin/bash "$username"
        echo "$username:$password" | chpasswd
        usermod -aG sudo "$username"

        # Permission settings: Only allow owner read/write (Not supported with Windows Volume mount)
        # chown -R $username:$username /home/$username
        # chmod 700 /home/$username
    fi

    # Check and add FTP user (avoid duplicates)
    if ! grep -q "^$username$" /etc/vsftpd.userlist; then
        echo "$username" >> /etc/vsftpd.userlist
    fi
done

# Start vsftpd (if not already running)
if ! pgrep -x "vsftpd" > /dev/null; then
    echo "🔄 Starting vsftpd service"
    /usr/sbin/vsftpd /etc/vsftpd.conf &
fi

# Start sshd or other passed commands
exec "$@"
