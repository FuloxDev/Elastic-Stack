# 🔍 Elastic Stack (ELK) - Docker Compose

[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-8.8.2-005571?logo=elasticsearch&logoColor=white)](https://www.elastic.co/elasticsearch/)
[![Kibana](https://img.shields.io/badge/Kibana-8.8.2-005571?logo=kibana&logoColor=white)](https://www.elastic.co/kibana/)
[![Logstash](https://img.shields.io/badge/Logstash-8.8.2-005571?logo=logstash&logoColor=white)](https://www.elastic.co/logstash/)
[![Docker](https://img.shields.io/badge/Docker-24.x-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)

Production-ready Elastic Stack (ELK) with Docker Compose. Includes Elasticsearch, Kibana, Logstash, Filebeat, Metricbeat, and Fleet Server with full TLS encryption and automated certificate management.

## 📋 Table of Contents

- [Overview](#overview)
- [Stack Components](#stack-components)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Use Cases](#use-cases)
- [Management Scripts](#management-scripts)
- [Security](#security)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This is a complete, production-ready Elastic Stack deployment featuring:

- **Automated Certificate Management**: Self-signed TLS certificates auto-generated
- **Full TLS Encryption**: All inter-service communication encrypted
- **Comprehensive Monitoring**: Self-monitoring with Metricbeat
- **Log Collection**: Filebeat for file and Docker container logs
- **Syslog Ingestion**: Logstash with syslog input
- **Fleet Management**: Centralized agent management with Fleet Server
- **APM Ready**: Elastic APM server for application performance monitoring

## 🏗️ Stack Components

| Component | Version | Purpose | Ports |
|-----------|---------|---------|-------|
| **Elasticsearch** | 8.8.2 | Search and analytics engine | 9200 |
| **Kibana** | 8.8.2 | Visualization and UI | 5601 |
| **Logstash** | 8.8.2 | Log processing pipeline | 5515 (syslog) |
| **Filebeat** | 8.8.2 | Log shipper (files + Docker) | - |
| **Metricbeat** | 8.8.2 | Metrics collector | - |
| **Fleet Server** | 8.8.2 | Elastic agent management | 8220 |
| **APM Server** | 8.8.2 | Application performance monitoring | 8200 |

## ✨ Features

### Data Collection
- ✅ **Syslog Ingestion**: TCP syslog receiver on port 5515
- ✅ **File Logs**: Collect logs from file paths
- ✅ **Docker Logs**: Auto-discover and collect container logs
- ✅ **System Metrics**: CPU, memory, disk, network
- ✅ **Stack Metrics**: Self-monitoring of ELK components

### Security
- 🔒 **Full TLS/SSL**: All communication encrypted
- 🔒 **Auto Certificate Management**: Certificates generated on setup
- 🔒 **Basic Authentication**: Password-protected access
- 🔒 **Secure Inter-Service Communication**: Internal TLS

### Management
- 📊 **Kibana Dashboard**: Web UI for visualization
- 🤖 **Fleet Server**: Centralized agent management
- 🔄 **Index Lifecycle Management**: Automated data retention
- 📈 **Self-Monitoring**: Built-in metrics collection
- 🧹 **Cleanup Scripts**: Automated index management

## 📦 Prerequisites

- Docker 24.x+
- Docker Compose 2.x+
- 8GB+ RAM (recommended)
- 50GB+ disk space
- Linux/macOS (Windows with WSL2)

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/your-org/elk-stack-docker.git
cd elk-stack-docker
```

### 2. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit configuration
nano .env
```

**Required Configuration:**

```bash
# Stack Version
STACK_VERSION=8.8.2
CLUSTER_NAME=docker-cluster

# Ports
ES_PORT=9200
KIBANA_PORT=5601

# Security (Change these!)
ELASTIC_PASSWORD=your-strong-password
KIBANA_PASSWORD=your-strong-password
ELASTIC_APM_SECRET_TOKEN=your-secret-token
ENCRYPTION_KEY=generate-32-byte-hex-key

# Memory Limits (adjust based on your system)
ES_MEM_LIMIT=3073741824  # 3GB
KB_MEM_LIMIT=1073741824  # 1GB
LS_MEM_LIMIT=1073741824  # 1GB
```

**Generate Encryption Key:**
```bash
openssl rand -hex 32
```

### 3. Start the Stack

```bash
# Start all services
docker-compose up -d

# The setup container will:
# 1. Generate CA certificate
# 2. Generate certificates for all services
# 3. Configure Kibana password
# 4. Wait for Elasticsearch to be ready
```

### 4. Verify Deployment

```bash
# Check all containers are running
docker-compose ps

# Check Elasticsearch health
curl -k -u elastic:your-password https://localhost:9200/_cluster/health?pretty

# Access Kibana
# Open: https://localhost:5601
# Username: elastic
# Password: (from .env ELASTIC_PASSWORD)
```

### 5. Wait for Setup

First startup takes 2-5 minutes:
- Certificate generation
- Service initialization
- Kibana configuration

Monitor setup progress:
```bash
docker-compose logs -f setup
```

## ⚙️ Configuration

### Elasticsearch

Single-node cluster with TLS enabled:
```yaml
environment:
  - discovery.type=single-node
  - xpack.security.enabled=true
  - xpack.security.http.ssl.enabled=true
```

**Memory Settings:**
Adjust in `.env`:
```bash
ES_MEM_LIMIT=3073741824  # 3GB for Elasticsearch
```

### Kibana

HTTPS-enabled with Elasticsearch integration:
```yaml
environment:
  - SERVER_SSL_ENABLED=true
  - ELASTICSEARCH_HOSTS=https://es01:9200
```

Access: https://localhost:5601

### Logstash

**Generic Syslog Input:**

Edit `logstash.conf`:
```ruby
input {
  tcp {
    port => 5515
    codec => json_lines  # or 'json' or 'plain'
  }
  
  # UDP syslog
  udp {
    port => 5514
    codec => plain
  }
}

filter {
  # Add your filters here
  # Parse JSON, grok patterns, etc.
}

output {
  elasticsearch {
    hosts => "${ELASTIC_HOSTS}"
    user => "${ELASTIC_USER}"
    password => "${ELASTIC_PASSWORD}"
    ssl_certificate_authorities => "certs/ca/ca.crt"
    ssl_enabled => true
    index => "logstash-%{+YYYY.MM.dd}"
  }
}
```

**Common Use Cases:**

**JSON Logs:**
```ruby
input {
  tcp {
    port => 5515
    codec => json_lines
  }
}

filter {
  # JSON already parsed
  mutate {
    add_field => { "[@metadata][target_index]" => "app-logs" }
  }
}
```

**Syslog:**
```ruby
input {
  tcp {
    port => 5515
    codec => syslog
  }
}

filter {
  # Syslog already parsed by codec
}
```

**Custom Application Logs:**
```ruby
input {
  tcp {
    port => 5515
    codec => plain
  }
}

filter {
  grok {
    match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{GREEDYDATA:msg}" }
  }
  
  date {
    match => [ "timestamp", "ISO8601" ]
    target => "@timestamp"
  }
}
```

### Filebeat

**Collect File Logs:**

Edit `filebeat.yml`:
```yaml
filebeat.inputs:
- type: filestream
  id: custom-logs
  paths:
    - /var/log/app/*.log
    - /var/log/nginx/*.log
  
  # Parse JSON logs
  json.keys_under_root: true
  json.add_error_key: true
```

**Mount Log Directories:**

Edit `docker-compose.yml`:
```yaml
filebeat01:
  volumes:
    - /var/log/app:/var/log/app:ro
    - /var/log/nginx:/var/log/nginx:ro
```

### Metricbeat

Self-monitoring enabled by default:
- Elasticsearch metrics
- Kibana metrics
- Logstash metrics
- Docker container metrics

Add more modules in `metricbeat.yml`:
```yaml
- module: system
  metricsets:
    - cpu
    - memory
    - network
  period: 10s
```

### Fleet Server

Centralized agent management available at:
- Fleet UI: https://localhost:5601/app/fleet
- API: https://localhost:8220

## 🎯 Use Cases

### 1. Application Log Collection

**Scenario:** Collect logs from Node.js/Python/Java applications

**Setup:**
1. Configure app to send JSON logs to Logstash:
   ```bash
   # App configuration
   LOG_OUTPUT=tcp://logstash:5515
   LOG_FORMAT=json
   ```

2. Update `logstash.conf`:
   ```ruby
   input {
     tcp {
       port => 5515
       codec => json_lines
       tags => ["application"]
     }
   }
   
   filter {
     if "application" in [tags] {
       # Add custom filters
     }
   }
   ```

3. View in Kibana → Discover → Index: `logstash-*`

### 2. Syslog Collection (Network Devices, Servers)

**Scenario:** Collect syslog from firewalls, routers, servers

**Setup:**
1. Configure device to send syslog:
   ```bash
   # On device
   logging host 192.168.1.100 port 5515
   ```

2. Update `logstash.conf`:
   ```ruby
   input {
     tcp {
       port => 5515
       codec => syslog
       tags => ["syslog"]
     }
   }
   
   filter {
     if "syslog" in [tags] {
       grok {
         match => { "message" => "your-pattern" }
       }
     }
   }
   
   output {
     elasticsearch {
       index => "syslog-%{+YYYY.MM.dd}"
     }
   }
   ```

### 3. Docker Container Logs

**Scenario:** Collect all Docker container logs

**Setup:**
Already configured! Filebeat auto-discovers containers.

View in Kibana:
- Discover → Index: `filebeat-*`
- Filter: `container.name: "your-container"`

### 4. Metrics Monitoring

**Scenario:** Monitor system and application metrics

**Setup:**
Metricbeat is pre-configured for:
- System metrics (CPU, memory, disk)
- Docker metrics
- ELK stack metrics

View in Kibana:
- Dashboard → [Metricbeat System] Overview
- Dashboard → [Metricbeat Docker] Overview

### 5. APM (Application Performance Monitoring)

**Scenario:** Monitor application performance and traces

**Setup:**
1. APM Server is running on port 8200
2. Install APM agent in your app:
   ```bash
   # Node.js
   npm install elastic-apm-node
   
   # Python
   pip install elastic-apm
   ```

3. Configure agent:
   ```javascript
   // Node.js
   const apm = require('elastic-apm-node').start({
     serverUrl: 'https://localhost:8200',
     secretToken: 'your-secret-token'
   })
   ```

4. View in Kibana → APM

## 🛠️ Management Scripts

### Index Lifecycle Management (ILM)

**Setup automated data retention:**

```bash
./limit.sh
```

This creates an ILM policy that:
- **Hot phase** (0 days): Active indexing
- **Warm phase** (7 days): Shrink to 1 shard, force merge
- **Delete phase** (30 days): Delete old data

Applied to indices: `filebeat-*`, `metricbeat-*`, `logstash-*`

### Index Cleanup

**Manual cleanup of old indices:**

```bash
./cleanUp.sh
```

Deletes indices older than 30 days (configurable in script).

**Customize retention:**
```bash
# Edit cleanUp.sh
DAYS_TO_KEEP=30  # Change to your preference
```

**Automated cleanup (cron):**
```bash
# Add to crontab
0 2 * * * /path/to/elk-stack/cleanUp.sh >> /var/log/elk-cleanup.log 2>&1
```

### Monitor Disk Usage

**Check index sizes:**

```bash
./monitor-disk.sh
```

Output shows indices sorted by size:
```
health status index                    size
green  open   logstash-2024.12.01     2.3gb
green  open   filebeat-2024.12.01     1.8gb
green  open   metricbeat-2024.12.01   456mb
```

## 🔐 Security

### TLS Certificates

**Auto-generated on first startup:**
- CA certificate
- Elasticsearch certificate
- Kibana certificate
- Logstash certificate
- Fleet Server certificate

**Certificate locations:**
```
certs/
├── ca/
│   ├── ca.crt
│   └── ca.key
├── es01/
│   ├── es01.crt
│   └── es01.key
├── kibana/
│   ├── kibana.crt
│   └── kibana.key
└── ...
```

**Regenerate certificates:**
```bash
docker-compose down
docker volume rm elk-stack_certs
docker-compose up -d
```

### Authentication

**Default user:** `elastic`  
**Password:** Set in `.env` as `ELASTIC_PASSWORD`

**Change password:**
```bash
curl -k -X POST "https://localhost:9200/_security/user/elastic/_password" \
  -u elastic:old-password \
  -H "Content-Type: application/json" \
  -d '{"password":"new-password"}'
```

**Create additional users:**
```bash
curl -k -X POST "https://localhost:9200/_security/user/myuser" \
  -u elastic:password \
  -H "Content-Type: application/json" \
  -d '{
    "password": "user-password",
    "roles": ["kibana_admin", "monitoring_user"],
    "full_name": "My User"
  }'
```

### Best Practices

1. ✅ **Change default passwords** immediately
2. ✅ **Use strong passwords** (20+ characters)
3. ✅ **Rotate credentials** every 90 days
4. ✅ **Limit network access** (use firewall rules)
5. ✅ **Enable audit logging** in production
6. ✅ **Regular backups** of Elasticsearch data
7. ✅ **Monitor disk usage** to prevent outages

## 📊 Monitoring

### Stack Health

**Cluster Health:**
```bash
curl -k -u elastic:password https://localhost:9200/_cluster/health?pretty
```

**Node Stats:**
```bash
curl -k -u elastic:password https://localhost:9200/_nodes/stats?pretty
```

**Check Indices:**
```bash
curl -k -u elastic:password https://localhost:9200/_cat/indices?v
```

### Container Status

```bash
# All containers
docker-compose ps

# Resource usage
docker stats

# Logs
docker-compose logs -f
docker-compose logs -f elasticsearch
docker-compose logs -f logstash
```

### Kibana Monitoring

Built-in monitoring available at:
- **Stack Monitoring**: Kibana → Management → Stack Monitoring
- **Metrics**: View Elasticsearch, Kibana, Logstash metrics
- **Logs**: Centralized log viewer

## 🔧 Troubleshooting

### Elasticsearch Won't Start

**Issue:** Container keeps restarting

```bash
# Check logs
docker-compose logs es01

# Common issues:
# 1. Insufficient memory
docker stats es01

# 2. File permissions
docker-compose exec es01 ls -la /usr/share/elasticsearch/data

# 3. vm.max_map_count too low
sudo sysctl -w vm.max_map_count=262144
# Make permanent:
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

### Kibana Can't Connect

**Issue:** Kibana shows "Unable to retrieve version information"

```bash
# Check Elasticsearch is healthy
curl -k -u elastic:password https://localhost:9200/_cluster/health

# Check Kibana logs
docker-compose logs kibana

# Verify Kibana password
docker-compose exec es01 curl -k -u elastic:password \
  https://localhost:9200/_security/user/kibana_system
```

### Logstash Not Receiving Logs

**Issue:** Logs not appearing in Elasticsearch

```bash
# Check Logstash is running
docker-compose ps logstash01

# Check Logstash logs
docker-compose logs -f logstash01

# Test TCP connection
telnet localhost 5515

# Send test log
echo '{"message":"test"}' | nc localhost 5515

# Check Logstash pipeline
docker-compose exec logstash01 curl http://localhost:9600/_node/stats/pipelines?pretty
```

### Certificate Issues

**Issue:** SSL/TLS errors

```bash
# Verify certificates exist
docker-compose exec es01 ls -la /usr/share/elasticsearch/config/certs/

# Check certificate validity
docker-compose exec es01 openssl x509 -in config/certs/ca/ca.crt -text -noout

# Regenerate certificates
docker-compose down
docker volume rm elk-stack_certs
docker-compose up -d setup
```

### Out of Disk Space

**Issue:** Elasticsearch stops indexing

```bash
# Check disk usage
df -h

# Check index sizes
./monitor-disk.sh

# Delete old indices
./cleanUp.sh

# Adjust retention in limit.sh
```

### High Memory Usage

**Issue:** System running out of memory

```bash
# Check memory usage
docker stats

# Reduce memory limits in .env
ES_MEM_LIMIT=2147483648  # 2GB instead of 3GB

# Restart with new limits
docker-compose down
docker-compose up -d
```

### Data Not Appearing in Kibana

**Issue:** No data in Discover

```bash
# 1. Check if indices exist
curl -k -u elastic:password https://localhost:9200/_cat/indices?v

# 2. Create index pattern in Kibana
# Kibana → Management → Index Patterns → Create

# 3. Verify time range in Discover
# Set time range to "Last 15 minutes" or wider

# 4. Check if data is being indexed
curl -k -u elastic:password \
  https://localhost:9200/logstash-*/_search?pretty
```

## 📈 Performance Tuning

### Elasticsearch

**Heap Size:**
Set to 50% of available RAM (max 32GB):
```bash
# In .env
ES_MEM_LIMIT=4294967296  # 4GB (2GB heap)
```

**Shards:**
- Small indices (<50GB): 1 shard
- Medium indices (50-200GB): 2-5 shards
- Large indices (>200GB): 5-10 shards

**Refresh Interval:**
For high-volume indexing:
```bash
curl -k -X PUT "https://localhost:9200/my-index/_settings" \
  -u elastic:password \
  -H "Content-Type: application/json" \
  -d '{"index":{"refresh_interval":"30s"}}'
```

### Logstash

**Pipeline Workers:**
```ruby
# In logstash.conf or docker-compose
pipeline.workers: 4  # Equal to CPU cores
```

**Batch Size:**
```ruby
pipeline.batch.size: 125
pipeline.batch.delay: 50
```

### Kibana

**Response Timeout:**
```yaml
# In kibana.yml
elasticsearch.requestTimeout: 90000
```

## 📦 Backup & Restore

### Snapshot Repository

**Setup filesystem repository:**
```bash
curl -k -X PUT "https://localhost:9200/_snapshot/my_backup" \
  -u elastic:password \
  -H "Content-Type: application/json" \
  -d '{
    "type": "fs",
    "settings": {
      "location": "/usr/share/elasticsearch/backup"
    }
  }'
```

**Create snapshot:**
```bash
curl -k -X PUT "https://localhost:9200/_snapshot/my_backup/snapshot_1?wait_for_completion=true" \
  -u elastic:password
```

**Restore snapshot:**
```bash
curl -k -X POST "https://localhost:9200/_snapshot/my_backup/snapshot_1/_restore" \
  -u elastic:password
```

## 🔄 Updates

**Update stack version:**

```bash
# 1. Backup data
./backup.sh

# 2. Update version in .env
STACK_VERSION=8.9.0

# 3. Pull new images
docker-compose pull

# 4. Restart stack
docker-compose down
docker-compose up -d

# 5. Verify
curl -k -u elastic:password https://localhost:9200
```

## 📄 License

MIT License - see LICENSE file

## 👤 Author

**DevSecOps Team**

## 📞 Support

- **Issues**: GitHub Issues
- **Documentation**: https://www.elastic.co/guide/
- **Community**: https://discuss.elastic.co/

---

**Production-ready Elastic Stack for log aggregation and analysis** 🔍📊