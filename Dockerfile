FROM nvidia/cuda:12.8.1-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# 安裝必要套件（Python、SSH、FTP）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 python3-pip curl wget git vim ca-certificates \
    build-essential openssh-server sudo software-properties-common \
    vsftpd nano && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 建立 SSH 與 FTP 需要的基礎設定
RUN mkdir -p /var/run/sshd && ssh-keygen -A && \
    mkdir -p /var/ftp && touch /etc/vsftpd.userlist

# 設定 SSH 設定檔
RUN echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "ListenAddress 0.0.0.0" >> /etc/ssh/sshd_config

# 設定 FTP 需要的基礎設定
RUN mkdir -p /var/run/vsftpd/empty && \
    chown root:root /var/run/vsftpd/empty && \
    chmod 755 /var/run/vsftpd/empty

# 複製 FTP 設定檔與 entrypoint
COPY vsftpd.conf /etc/vsftpd.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 21 21000-21010

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
