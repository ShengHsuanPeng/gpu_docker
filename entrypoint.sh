#!/bin/bash

# 將 USERS=gmm:pass1,dev1:pass2 格式轉成多位使用者建立
IFS=',' read -ra accounts <<< "$USERS"
for account in "${accounts[@]}"; do
    IFS=':' read -ra parts <<< "$account"
    username="${parts[0]}"
    password="${parts[1]}"

    if ! id "$username" &>/dev/null; then
        echo "🧑 建立使用者 $username"
        useradd -ms /bin/bash "$username"
        echo "$username:$password" | chpasswd
        usermod -aG sudo "$username"

        # 權限設定：只允許本人讀寫 (Windows Volume 掛載下不支援)
        # chown -R $username:$username /home/$username
        # chmod 700 /home/$username

        # 安裝 sympy 到該使用者 ~/.local/bin
        # su - $username -c "PATH=/home/$username/.local/bin:$PATH pip3 install --user sympy"
    fi

    # 建立 ftp userlist 條目
    echo "$username" >> /etc/vsftpd.userlist

done

# 啟動 vsftpd
/usr/sbin/vsftpd /etc/vsftpd.conf &

# 啟動 sshd 或其他傳入命令
exec "$@"
