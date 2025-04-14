#!/bin/bash

# 將 USERS=user1:pass1,user2:pass2 格式轉成多位使用者建立
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

    # 檢查並添加 FTP 使用者（避免重複）
    if ! grep -q "^$username$" /etc/vsftpd.userlist; then
        echo "$username" >> /etc/vsftpd.userlist
    fi
done

# 啟動 vsftpd（如果尚未運行）
if ! pgrep -x "vsftpd" > /dev/null; then
    echo "🔄 啟動 vsftpd 服務"
    /usr/sbin/vsftpd /etc/vsftpd.conf &
fi

# 啟動 sshd 或其他傳入命令
exec "$@"
