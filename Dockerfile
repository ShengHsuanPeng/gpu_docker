FROM nvidia/cuda:12.8.1-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# 安裝必要套件（Python、SSH、FTP）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 python3-pip curl wget git vim ca-certificates \
    build-essential openssh-server sudo software-properties-common \
    vsftpd nano && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 安裝 PyTorch 和相關套件
# RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
# RTX 5080 support sm_120 which is not supported by cu126
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128

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

# 設定 bash history 和 PATH
RUN echo "export HISTSIZE=10000" >> /etc/bash.bashrc && \
    echo "export HISTFILESIZE=20000" >> /etc/bash.bashrc && \
    echo "export HISTCONTROL=ignoredups:erasedups" >> /etc/bash.bashrc && \
    echo "shopt -s histappend" >> /etc/bash.bashrc && \
    echo "PROMPT_COMMAND='history -a'" >> /etc/bash.bashrc && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> /etc/skel/.bashrc && \
    mkdir -p /etc/skel/.local/bin

# 複製 FTP 設定檔與 entrypoint
COPY vsftpd.conf /etc/vsftpd.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 21 21000-21010

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
