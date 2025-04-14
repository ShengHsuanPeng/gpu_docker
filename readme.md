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

## 建置與啟動容器

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

## 連線方式

### SSH 連線
```bash
ssh dev1@172.16.201.84 -p 8152
```

### FTP 連線 (ex: 使用 FileZilla)
- Host: 172.16.201.84
- Username: user1
- Password: pass1
- Port: 8151

## 注意事項

1. 確保主機有足夠的磁碟空間
2. 檢查 NVIDIA GPU 驅動程式是否正確安裝
3. 確認 Docker 和 NVIDIA Container Toolkit 已正確配置
4. 定期備份重要資料
5. 注意安全性設定，定期更新密碼

## 故障排除

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