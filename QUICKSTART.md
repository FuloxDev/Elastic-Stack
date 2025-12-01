# 🚀 Quick Start Guide - Elastic Stack

Get your ELK stack up and running in under 10 minutes!

## Prerequisites

- Docker and Docker Compose installed
- 8GB+ RAM available
- 50GB+ disk space

## Step 1: Clone & Configure

```bash
# Clone repository
git clone https://github.com/your-org/elk-stack-docker.git
cd elk-stack-docker

# Copy environment template
cp .env.example .env

# Edit configuration
nano .env
```

## Step 2: Set Passwords

**IMPORTANT**: Change these in `.env`:

```bash
# Generate encryption key
openssl rand -hex 32

# Update .env with:
ELASTIC_PASSWORD=your-strong-password
KIBANA_PASSWORD=your-strong-password
ELASTIC_APM_SECRET_TOKEN=your-secret-token
ENCRYPTION_KEY=paste-generated-key-here
```

## Step 3: System Configuration

**Required for Elasticsearch:**

```bash
# Increase virtual memory
sudo sysctl -w vm.max_map_count=262144

# Make it permanent
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

## Step 4: Start Stack

```bash
# Start all services
docker-compose up -d

# Monitor setup (takes 2-5 minutes)
docker-compose logs -f setup
```

Wait for message: **"All done!"**

## Step 5: Verify

```bash
# Check all containers are running
docker-compose ps

# Should show 7 containers in "Up" state:
# - setup (exits when done - this is normal)
# - es01 (Elasticsearch)
# - kibana
# - logstash01
# - filebeat01
# - metricbeat01
# - fleet-server
```

## Step 6: Access Kibana

Open browser: **https://localhost:5601**

**Login:**
- Username: `elastic`
- Password: (from `.env` ELASTIC_PASSWORD)

**⚠️ Accept self-signed certificate warning**

## Step 7: Send Test Log

```bash
# Send JSON log to Logstash
echo '{"message":"Hello ELK!","level":"INFO","timestamp":"'$(date -Iseconds)'"}' | nc localhost 5515

# Wait 10 seconds for indexing

# View in Kibana:
# 1. Menu → Discover
# 2. Create index pattern: logstash-*
# 3. Select @timestamp as time field
# 4. View your logs!
```

## Common Commands

```bash
# View logs
docker-compose logs -f
docker-compose logs -f elasticsearch
docker-compose logs -f logstash

# Restart services
docker-compose restart

# Stop stack
docker-compose down

# Stop and remove volumes (DELETES DATA!)
docker-compose down -v

# Check Elasticsearch health
curl -k -u elastic:your-password https://localhost:9200/_cluster/health?pretty
```

## What's Monitored By Default

✅ **Docker Containers** - All container logs via Filebeat  
✅ **ELK Stack Metrics** - Self-monitoring via Metricbeat  
✅ **System Metrics** - CPU, memory, disk, network  

## Next Steps

### 1. Configure Log Sources

**Send application logs:**
```bash
# From your app, send JSON to:
tcp://logstash:5515

# Example (Python):
import socket
import json

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('localhost', 5515))
sock.send(json.dumps({"message": "App log", "level": "INFO"}).encode() + b'\n')
sock.close()
```

### 2. Setup Index Lifecycle Management

```bash
# Configure automatic data retention
./limit.sh

# This sets up:
# - Hot phase: 0 days (active indexing)
# - Warm phase: 7 days (read-only, optimized)
# - Delete phase: 30 days (data deleted)
```

### 3. Monitor Disk Usage

```bash
# Check index sizes
./monitor-disk.sh

# Manual cleanup (deletes indices >30 days old)
./cleanUp.sh
```

### 4. Create Visualizations

In Kibana:
1. **Discover** → View raw logs
2. **Dashboard** → Create visualizations
3. **Alerting** → Setup alerts
4. **Machine Learning** → Anomaly detection

## Troubleshooting

### Elasticsearch won't start
```bash
# Check vm.max_map_count
sysctl vm.max_map_count

# Should be at least 262144
# If not, run:
sudo sysctl -w vm.max_map_count=262144
```

### Kibana shows "Kibana server is not ready yet"
```bash
# Wait 2-5 minutes for full startup
# Check if Elasticsearch is healthy:
curl -k -u elastic:password https://localhost:9200/_cluster/health
```

### Can't connect to Logstash
```bash
# Check if port is open
telnet localhost 5515

# Check Logstash logs
docker-compose logs -f logstash01

# Test with netcat
echo "test" | nc localhost 5515
```

### Forgot password
```bash
# Reset elastic user password
docker-compose exec es01 bin/elasticsearch-reset-password -u elastic
```

## Access URLs

- **Kibana**: https://localhost:5601
- **Elasticsearch**: https://localhost:9200
- **Fleet Server**: https://localhost:8220
- **APM Server**: https://localhost:8200

## Default Credentials

- **Username**: `elastic`
- **Password**: (from `.env` ELASTIC_PASSWORD)

## Resource Usage

**Minimum System Requirements:**
- CPU: 4 cores
- RAM: 8GB
- Disk: 50GB

**Actual Usage:**
- Elasticsearch: ~2-3GB RAM
- Kibana: ~1GB RAM
- Other services: ~1-2GB RAM
- Total: ~5-6GB RAM

## Need Help?

- Read full [README.md](README.md)
- Check [Elastic Documentation](https://www.elastic.co/guide/)
- Review logs: `docker-compose logs -f`

---

**You're all set! Your ELK stack is ready for log collection and analysis.** 🎉

## Quick Reference Card

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Logs
docker-compose logs -f

# Health check
curl -k -u elastic:password https://localhost:9200/_cluster/health

# Send test log
echo '{"message":"test"}' | nc localhost 5515

# Kibana
https://localhost:5601

# Monitor disks
./monitor-disk.sh

# Setup ILM
./limit.sh

# Cleanup old indices
./cleanUp.sh
```