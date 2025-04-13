# GPU 容器建置教學

## 前置需求

1. 安裝 Docker 和 Docker Compose
2. 安裝 NVIDIA Container Toolkit
3. 確保系統有 NVIDIA GPU 驅動程式

## 專案結構

```
.
├── Dockerfile          # 容器映像檔定義
├── docker-compose.yml  # 容器服務配置
├── vsftpd.conf        # FTP 服務配置
├── entrypoint.sh      # 容器啟動腳本
└── .env               # 環境變數設定
```

## 1. 容器映像檔設定 (Dockerfile)

```dockerfile
FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# 安裝必要套件
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 python3-pip curl wget git vim ca-certificates \
    build-essential openssh-server sudo software-properties-common \
    vsftpd nano && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 設定 SSH 和 FTP
RUN mkdir -p /var/run/sshd && ssh-keygen -A && \
    mkdir -p /var/ftp && touch /etc/vsftpd.userlist

# 設定 SSH 配置
RUN echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "ListenAddress 0.0.0.0" >> /etc/ssh/sshd_config

# 設定 FTP 配置
RUN mkdir -p /var/run/vsftpd/empty && \
    chown root:root /var/run/vsftpd/empty && \
    chmod 755 /var/run/vsftpd/empty

# 複製配置檔案
COPY vsftpd.conf /etc/vsftpd.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 21 21000-21010

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
```

## 2. Docker Compose 配置 (docker-compose.yml)

```yaml
version: "3.9"

services:
  cuda-ssh:
    build:
      context: .
      dockerfile: Dockerfile
    image: gpu-server-image
    container_name: gpu-container
    ports:
      - "2152:22"        # SSH
      - "2151:21"        # FTP
      - "21000-21010:21000-21010"  # FTP Passive ports
    runtime: nvidia
    environment:
      - USERS=${USERS}   # 使用者帳號設定
    volumes:
      - /mnt/d/containers/ubuntu/home:/home
    restart: unless-stopped
```

## 3. FTP 服務配置 (vsftpd.conf)

```conf
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022

chroot_local_user=YES
allow_writeable_chroot=YES

user_sub_token=$USER
local_root=/home/$USER

userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO

# 被動模式設定
pasv_enable=YES
pasv_min_port=21000
pasv_max_port=21010
pasv_address=127.0.0.1

# 其他設定
xferlog_enable=YES
ftpd_banner=Welcome to your container FTP server.
use_localtime=YES
seccomp_sandbox=NO
```

## 4. 環境變數設定 (.env)

```
USERS=gmm:pass1,dev1:pass2
```

## 5. 容器啟動腳本 (entrypoint.sh)

```bash
#!/bin/bash

# 建立使用者帳號
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
    fi

    # 建立 ftp userlist
    echo "$username" >> /etc/vsftpd.userlist
done

# 啟動服務
/usr/sbin/vsftpd /etc/vsftpd.conf &
exec "$@"
```

## 6. 建置與啟動容器

1. 建立專案目錄並複製所有必要檔案
2. 設定環境變數檔案 (.env)
3. 執行以下命令：

```bash
# 建置並啟動容器
docker-compose up -d --build

# Windows 端口轉發設定
netsh interface portproxy add v4tov4 listenport=8152 listenaddress=0.0.0.0 connectport=2152 connectaddress=127.0.0.1
netsh interface portproxy add v4tov4 listenport=8151 listenaddress=0.0.0.0 connectport=2151 connectaddress=127.0.0.1
```

## 7. 連線方式

### SSH 連線
```bash
ssh dev1@172.16.201.84 -p 8152
```

### FTP 連線 (使用 FileZilla)
- Host: 172.16.201.84
- Username: dev1
- Password: dev1123
- Port: 8151

## 8. 注意事項

1. 確保主機有足夠的磁碟空間
2. 檢查 NVIDIA GPU 驅動程式是否正確安裝
3. 確認 Docker 和 NVIDIA Container Toolkit 已正確配置
4. 定期備份重要資料
5. 注意安全性設定，定期更新密碼

## 9. 故障排除

1. 檢查容器日誌：
```bash
docker-compose logs
```

2. 檢查 GPU 是否可用：
```bash
nvidia-smi
```

3. 檢查容器狀態：
```bash
docker-compose ps
```

4. 重新啟動容器：
```bash
docker-compose restart
``` 