# GPU Container Setup Guide

## Prerequisites

1. Install Docker and Docker Compose
2. Install NVIDIA Container Toolkit
3. Ensure NVIDIA GPU drivers are installed

## Project Structure

```
.
├── Dockerfile          # Container image definition
├── docker-compose.yml  # Container service configuration
├── vsftpd.conf        # FTP service configuration
├── entrypoint.sh      # Container startup script
└── .env               # Environment variables configuration
```

## Build and Start Container

1. Create project directory and copy all necessary files
2. Configure environment variables file (.env)
3. Execute the following commands:

```bash
# Build and start container
docker-compose up -d --build

# Windows port forwarding settings
netsh interface portproxy add v4tov4 listenport=8152 listenaddress=0.0.0.0 connectport=2152 connectaddress=127.0.0.1
netsh interface portproxy add v4tov4 listenport=8151 listenaddress=0.0.0.0 connectport=2151 connectaddress=127.0.0.1
```

## Connection Methods

### SSH Connection
```bash
ssh dev1@172.16.201.84 -p 8152
```

### FTP Connection (e.g., using FileZilla)
- Host: 172.16.201.84
- Username: user1
- Password: pass1
- Port: 8151

## Important Notes

1. Ensure sufficient disk space on the host
2. Verify NVIDIA GPU drivers are correctly installed
3. Confirm Docker and NVIDIA Container Toolkit are properly configured
4. Regularly backup important data
5. Pay attention to security settings and update passwords periodically

## Troubleshooting

1. Check container logs:
```bash
docker-compose logs
```

2. Check GPU availability:
```bash
nvidia-smi
```

3. Check container status:
```bash
docker-compose ps
```

4. Restart container:
```bash
docker-compose restart
``` 