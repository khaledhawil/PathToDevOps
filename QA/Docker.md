# Docker Interview Questions and Answers for Linux Admins & DevOps Engineers

## Table of Contents
1. [Docker Basics](#docker-basics)
2. [Docker Architecture](#docker-architecture)
3. [Images and Containers](#images-and-containers)
4. [Dockerfile](#dockerfile)
5. [Docker Networking](#docker-networking)
6. [Docker Storage and Volumes](#docker-storage-and-volumes)
7. [Docker Compose](#docker-compose)
8. [Docker Registry](#docker-registry)
9. [Container Orchestration](#container-orchestration)
10. [Security](#security)
11. [Performance and Monitoring](#performance-and-monitoring)
12. [Troubleshooting](#troubleshooting)
13. [Production Best Practices](#production-best-practices)
14. [Advanced Topics](#advanced-topics)

---

## Docker Basics

### 1. What is Docker and how does it differ from virtual machines?

**Short Answer:** Docker is a containerization platform that packages applications with their dependencies into lightweight, portable containers that share the host OS kernel.

**Detailed Explanation:**

**Docker Benefits:**
- **Lightweight**: Containers share host OS kernel, no full OS overhead
- **Fast startup**: Containers start in seconds vs minutes for VMs
- **Resource efficient**: Less memory and CPU overhead
- **Portable**: Runs consistently across different environments
- **Scalable**: Easy to scale horizontally

**Docker vs Virtual Machines:**

| Feature | Docker Containers | Virtual Machines |
|---------|------------------|------------------|
| OS | Shares host kernel | Full guest OS |
| Resource Usage | Lightweight | Heavy overhead |
| Startup Time | Seconds | Minutes |
| Isolation | Process-level | Hardware-level |
| Portability | High | Medium |
| Security | Good | Excellent |

**Example:**
```bash
# Docker container
docker run -d nginx:latest        # Starts in 1-2 seconds

# VM equivalent would require:
# - Full OS boot
# - Service initialization
# - Much more memory/CPU
```

### 2. Explain the Docker architecture and its components.

**Short Answer:** Docker uses a client-server architecture with Docker Engine (daemon), Docker CLI (client), and Docker Registry for image storage.

**Detailed Explanation:**

**Core Components:**

1. **Docker Daemon (dockerd)**
   - Background service managing containers
   - Listens for Docker API requests
   - Manages images, containers, networks, volumes

2. **Docker Client (docker CLI)**
   - Command-line interface
   - Communicates with daemon via REST API
   - Can connect to remote daemons

3. **Docker Registry**
   - Stores and distributes Docker images
   - Docker Hub is the default public registry
   - Private registries for enterprise use

4. **Docker Objects**
   - **Images**: Read-only templates for containers
   - **Containers**: Runnable instances of images
   - **Networks**: Communication channels
   - **Volumes**: Persistent data storage

**Architecture Flow:**
```bash
# Client sends command to daemon
docker run nginx

# Daemon process:
# 1. Checks if image exists locally
# 2. Pulls from registry if needed
# 3. Creates container from image
# 4. Starts container
# 5. Returns container ID to client
```

### 3. What are the different states of a Docker container?

**Short Answer:** Docker containers can be in states: Created, Running, Paused, Stopped, Killed, or Removed.

**Detailed Explanation:**

**Container States:**

1. **Created**: Container created but not started
2. **Running**: Container is executing
3. **Paused**: Container processes are paused
4. **Restarting**: Container is restarting
5. **Exited/Stopped**: Container has stopped
6. **Dead**: Container stopped but cannot be removed
7. **Removing**: Container is being removed

**State Management Commands:**
```bash
# Check container states
docker ps                          # Running containers
docker ps -a                       # All containers
docker ps -f status=exited         # Only stopped containers

# State transitions
docker create nginx                # Created state
docker start container_name        # Created → Running
docker pause container_name        # Running → Paused
docker unpause container_name      # Paused → Running
docker stop container_name         # Running → Exited
docker kill container_name         # Running → Killed
docker restart container_name      # Restart container
docker rm container_name           # Remove container

# Advanced filtering
docker ps --filter "status=running"
docker ps --filter "name=web*"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---

## Images and Containers

### 4. How do you create, manage, and optimize Docker images?

**Short Answer:** Create images using Dockerfile, manage with docker build/tag/push commands, and optimize using multi-stage builds and layer caching.

**Detailed Explanation:**

**Image Creation:**
```dockerfile
# Basic Dockerfile
FROM ubuntu:20.04
LABEL maintainer="admin@company.com"
LABEL version="1.0"

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy application
COPY requirements.txt .
RUN pip3 install -r requirements.txt
COPY . .

# Expose port
EXPOSE 8000

# Set user
USER 1000

# Start application
CMD ["python3", "app.py"]
```

**Image Management:**
```bash
# Build image
docker build -t myapp:1.0 .
docker build -t myapp:latest --build-arg ENV=prod .

# Tag images
docker tag myapp:1.0 registry.company.com/myapp:1.0
docker tag myapp:1.0 myapp:latest

# List and inspect images
docker images
docker image ls --filter dangling=true
docker inspect myapp:1.0
docker history myapp:1.0

# Remove images
docker rmi myapp:1.0
docker image prune              # Remove dangling images
docker image prune -a           # Remove unused images
```

**Image Optimization:**
```dockerfile
# Multi-stage build for smaller images
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]

# Optimization techniques:
# 1. Use specific, smaller base images (alpine)
# 2. Minimize layers by combining RUN commands
# 3. Use .dockerignore to exclude unnecessary files
# 4. Install only production dependencies
# 5. Use multi-stage builds
# 6. Run as non-root user
```

### 5. Explain Docker layers and image caching.

**Short Answer:** Docker images are built in layers, where each Dockerfile instruction creates a new layer. Docker caches layers to speed up builds.

**Detailed Explanation:**

**Layer Structure:**
```bash
# Each instruction creates a layer
FROM ubuntu:20.04          # Layer 1: Base OS
RUN apt-get update         # Layer 2: Package update
RUN apt-get install nginx  # Layer 3: Nginx installation
COPY index.html /var/www/  # Layer 4: Copy files
CMD ["nginx", "-g", "daemon off;"]  # Layer 5: Command

# View image layers
docker history nginx:latest
docker inspect nginx:latest
```

**Caching Mechanism:**
```dockerfile
# Inefficient - cache breaks on any file change
FROM node:16
WORKDIR /app
COPY . .                    # This invalidates cache for all subsequent layers
RUN npm install
CMD ["npm", "start"]

# Efficient - leverage cache
FROM node:16
WORKDIR /app
COPY package*.json ./       # Copy dependency files first
RUN npm install            # This layer caches if package.json unchanged
COPY . .                   # Copy source code last
CMD ["npm", "start"]
```

**Cache Management:**
```bash
# Build without cache
docker build --no-cache -t myapp .

# Force rebuild from specific layer
docker build --cache-from myapp:base -t myapp:latest .

# Clean build cache
docker builder prune
docker system prune

# Multi-stage cache
docker build --target builder -t myapp:builder .
docker build --cache-from myapp:builder -t myapp:latest .
```

### 6. How do you run and manage Docker containers?

**Short Answer:** Use docker run to create and start containers, then manage them with start/stop/restart commands and various runtime options.

**Detailed Explanation:**

**Basic Container Operations:**
```bash
# Run containers
docker run nginx                    # Foreground
docker run -d nginx                 # Background (detached)
docker run -it ubuntu bash         # Interactive with TTY
docker run --name web nginx        # Named container
docker run -p 8080:80 nginx        # Port mapping
docker run -v /data:/app/data nginx # Volume mount

# Container lifecycle
docker start container_name         # Start stopped container
docker stop container_name          # Graceful stop
docker restart container_name       # Restart container
docker kill container_name          # Force stop
docker pause container_name         # Pause container
docker unpause container_name       # Unpause container
```

**Advanced Run Options:**
```bash
# Resource limits
docker run -d \
  --name web \
  --memory=512m \
  --cpus=1.5 \
  --restart=unless-stopped \
  nginx

# Environment variables
docker run -d \
  -e ENV=production \
  -e DB_HOST=database \
  --env-file .env \
  myapp

# Network configuration
docker run -d \
  --name web \
  --network mynetwork \
  --ip 172.20.0.10 \
  nginx

# Security options
docker run -d \
  --user 1000:1000 \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  nginx
```

**Container Management:**
```bash
# Monitor containers
docker ps                          # Running containers
docker stats                       # Real-time resource usage
docker logs container_name          # View logs
docker logs -f --tail 100 container_name

# Execute commands in containers
docker exec -it container_name bash
docker exec container_name ls -la /app
docker exec -u root container_name apt update

# Copy files
docker cp file.txt container_name:/app/
docker cp container_name:/app/logs ./logs

# Container inspection
docker inspect container_name
docker port container_name
docker diff container_name          # File system changes
```

---

## Dockerfile

### 7. Explain Dockerfile best practices and optimization techniques.

**Short Answer:** Use specific base images, minimize layers, leverage caching, run as non-root, and use multi-stage builds for optimal Dockerfiles.

**Detailed Explanation:**

**Best Practices:**

1. **Use Specific Base Images:**
```dockerfile
# Bad - latest tag is unpredictable
FROM node:latest

# Good - specific version
FROM node:16.17.0-alpine

# Better - use digest for immutability
FROM node:16.17.0-alpine@sha256:f21f35732...
```

2. **Minimize Layers:**
```dockerfile
# Bad - multiple layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get clean

# Good - single layer
RUN apt-get update && \
    apt-get install -y curl wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

3. **Optimize for Caching:**
```dockerfile
# Copy dependency files first
COPY package*.json ./
RUN npm ci --only=production

# Copy source code last (changes more frequently)
COPY src/ ./src/
```

4. **Use .dockerignore:**
```dockerignore
# .dockerignore file
node_modules
.git
.gitignore
README.md
Dockerfile
.dockerignore
npm-debug.log
coverage/
.nyc_output
```

5. **Security Best Practices:**
```dockerfile
# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Change ownership
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Use COPY instead of ADD for local files
COPY requirements.txt .

# Specify exact versions
RUN pip install --no-cache-dir -r requirements.txt
```

**Multi-stage Build Example:**
```dockerfile
# Build stage
FROM golang:1.19-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Production stage
FROM alpine:3.16
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
CMD ["./main"]
```

### 8. What are the differences between COPY, ADD, RUN, and CMD instructions?

**Short Answer:** COPY copies files, ADD has additional features, RUN executes commands during build, CMD sets default runtime command.

**Detailed Explanation:**

**COPY vs ADD:**
```dockerfile
# COPY - simple file copying (preferred)
COPY src/ /app/src/
COPY package.json requirements.txt /app/

# ADD - additional features (use sparingly)
ADD https://example.com/file.tar.gz /app/    # Downloads files
ADD archive.tar.gz /app/                     # Auto-extracts archives

# Best practice: Use COPY for local files, ADD only for auto-extraction
```

**RUN Instruction:**
```dockerfile
# RUN - executes during image build
RUN apt-get update && apt-get install -y python3
RUN pip install flask
RUN chmod +x /app/script.sh

# Multiple commands in single RUN (better for caching)
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    pip install flask && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

**CMD vs ENTRYPOINT:**
```dockerfile
# CMD - default command (can be overridden)
CMD ["python", "app.py"]
CMD python app.py                    # Shell form

# ENTRYPOINT - always executes (not overridden)
ENTRYPOINT ["python", "app.py"]

# Combined usage
ENTRYPOINT ["python", "app.py"]
CMD ["--port", "8000"]               # Default arguments

# Examples:
# docker run myapp                   # Runs: python app.py --port 8000
# docker run myapp --port 9000       # Runs: python app.py --port 9000
```

**Working Directory and User:**
```dockerfile
# WORKDIR - sets working directory
WORKDIR /app                         # Creates directory if it doesn't exist
WORKDIR relative/path                # Relative to previous WORKDIR

# USER - sets user for subsequent instructions
USER 1000                           # By UID
USER appuser                        # By username
USER appuser:appgroup               # User and group
```

---

## Docker Networking

### 9. Explain Docker networking modes and how containers communicate.

**Short Answer:** Docker provides bridge, host, overlay, and custom networks for container communication with different isolation and connectivity levels.

**Detailed Explanation:**

**Network Drivers:**

1. **Bridge Network (Default):**
```bash
# Default bridge network
docker run -d --name web nginx      # Uses default bridge

# Custom bridge network
docker network create mynetwork
docker run -d --name web --network mynetwork nginx
docker run -d --name app --network mynetwork myapp

# Containers can communicate by name
docker exec app ping web           # Works with custom networks
```

2. **Host Network:**
```bash
# Container uses host network stack
docker run -d --network host nginx  # Binds directly to host ports
# No port mapping needed, but less isolation
```

3. **Overlay Network (Swarm):**
```bash
# Multi-host networking
docker network create -d overlay myoverlay
docker service create --network myoverlay nginx
```

**Network Management:**
```bash
# List networks
docker network ls

# Inspect network
docker network inspect bridge
docker network inspect mynetwork

# Connect/disconnect containers
docker network connect mynetwork container_name
docker network disconnect mynetwork container_name

# Remove network
docker network rm mynetwork
docker network prune               # Remove unused networks
```

**Container Communication:**
```bash
# Port publishing
docker run -d -p 8080:80 nginx     # Host:Container
docker run -d -P nginx             # Auto-assign ports

# Internal communication (custom networks)
docker network create app-network
docker run -d --name database --network app-network postgres
docker run -d --name webapp --network app-network \
  -e DB_HOST=database myapp         # Use container name as hostname

# Check connectivity
docker exec webapp ping database
docker exec webapp nslookup database
```

### 10. How do you configure container networking for production?

**Short Answer:** Use custom bridge networks, implement service discovery, configure load balancing, and secure with network policies.

**Detailed Explanation:**

**Production Network Setup:**
```bash
# Create isolated networks for different tiers
docker network create \
  --driver bridge \
  --subnet=172.20.0.0/16 \
  --gateway=172.20.0.1 \
  frontend-network

docker network create \
  --driver bridge \
  --subnet=172.21.0.0/16 \
  --gateway=172.21.0.1 \
  backend-network

docker network create \
  --driver bridge \
  --subnet=172.22.0.0/16 \
  --gateway=172.22.0.1 \
  database-network
```

**Multi-tier Application:**
```yaml
# docker-compose.yml for production networking
version: '3.8'
services:
  nginx:
    image: nginx:alpine
    networks:
      - frontend
    ports:
      - "80:80"
      - "443:443"
    
  webapp:
    image: myapp:latest
    networks:
      - frontend
      - backend
    environment:
      - DB_HOST=database
    
  database:
    image: postgres:13
    networks:
      - backend
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - db_data:/var/lib/postgresql/data

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true        # No external access

volumes:
  db_data:
```

**Service Discovery and Load Balancing:**
```bash
# Using Docker Swarm for service discovery
docker swarm init
docker service create \
  --name webapp \
  --replicas 3 \
  --network mynetwork \
  myapp:latest

# External load balancer configuration
# nginx.conf
upstream webapp {
    server container1:8000;
    server container2:8000;
    server container3:8000;
}

server {
    listen 80;
    location / {
        proxy_pass http://webapp;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## Docker Storage and Volumes

### 11. Explain Docker storage options: volumes, bind mounts, and tmpfs.

**Short Answer:** Docker provides volumes (managed by Docker), bind mounts (host filesystem), and tmpfs (memory storage) for persistent and temporary data.

**Detailed Explanation:**

**Storage Types Comparison:**

| Feature | Volumes | Bind Mounts | tmpfs |
|---------|---------|-------------|--------|
| Management | Docker managed | Host managed | Memory only |
| Performance | Good | Variable | Excellent |
| Backup | Easy | Manual | Not applicable |
| Sharing | Between containers | Host accessible | Container only |
| Platform | Cross-platform | Platform dependent | Linux only |

**Volume Management:**
```bash
# Create volumes
docker volume create myvolume
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.1,rw \
  --opt device=:/path/to/dir \
  nfs-volume

# List and inspect volumes
docker volume ls
docker volume inspect myvolume

# Use volumes
docker run -d -v myvolume:/app/data nginx
docker run -d --mount source=myvolume,target=/app/data nginx

# Remove volumes
docker volume rm myvolume
docker volume prune              # Remove unused volumes
```

**Bind Mounts:**
```bash
# Bind mount syntax
docker run -d \
  -v /host/path:/container/path \
  nginx

docker run -d \
  --mount type=bind,source=/host/path,target=/container/path \
  nginx

# Read-only bind mount
docker run -d \
  -v /host/config:/app/config:ro \
  myapp

# Development example
docker run -d \
  -v $(pwd)/src:/app/src \
  -v $(pwd)/config:/app/config:ro \
  -p 3000:3000 \
  node:16
```

**tmpfs Mounts:**
```bash
# Temporary filesystem in memory
docker run -d \
  --tmpfs /app/tmp \
  nginx

docker run -d \
  --mount type=tmpfs,destination=/app/tmp,tmpfs-size=100M \
  nginx

# Multiple tmpfs mounts
docker run -d \
  --tmpfs /tmp \
  --tmpfs /var/cache \
  myapp
```

### 12. How do you backup and restore Docker volumes?

**Short Answer:** Use docker run with volume mounts to backup/restore data, or use specialized tools for automated backup strategies.

**Detailed Explanation:**

**Volume Backup:**
```bash
# Backup volume to tar file
docker run --rm \
  -v myvolume:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/myvolume-backup.tar.gz -C /data .

# Backup with timestamp
BACKUP_NAME="myvolume-$(date +%Y%m%d-%H%M%S).tar.gz"
docker run --rm \
  -v myvolume:/data \
  -v $(pwd)/backups:/backup \
  ubuntu tar czf /backup/$BACKUP_NAME -C /data .

# Backup multiple volumes
docker run --rm \
  -v vol1:/vol1 \
  -v vol2:/vol2 \
  -v $(pwd)/backups:/backup \
  ubuntu bash -c "
    tar czf /backup/vol1-backup.tar.gz -C /vol1 .
    tar czf /backup/vol2-backup.tar.gz -C /vol2 .
  "
```

**Volume Restore:**
```bash
# Restore from backup
docker run --rm \
  -v myvolume:/data \
  -v $(pwd)/backups:/backup \
  ubuntu tar xzf /backup/myvolume-backup.tar.gz -C /data

# Restore to new volume
docker volume create myvolume-restored
docker run --rm \
  -v myvolume-restored:/data \
  -v $(pwd)/backups:/backup \
  ubuntu tar xzf /backup/myvolume-backup.tar.gz -C /data
```

**Automated Backup Script:**
```bash
#!/bin/bash
# backup-volumes.sh

BACKUP_DIR="/backups/docker-volumes"
DATE=$(date +%Y%m%d-%H%M%S)
LOG_FILE="/var/log/docker-backup.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

backup_volume() {
    local volume_name=$1
    local backup_file="$BACKUP_DIR/${volume_name}-${DATE}.tar.gz"
    
    log_message "Starting backup of volume: $volume_name"
    
    docker run --rm \
        -v "$volume_name":/data:ro \
        -v "$BACKUP_DIR":/backup \
        ubuntu tar czf "/backup/${volume_name}-${DATE}.tar.gz" -C /data .
    
    if [ $? -eq 0 ]; then
        log_message "Backup completed: $backup_file"
    else
        log_message "Backup failed for volume: $volume_name"
        return 1
    fi
}

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup all volumes
docker volume ls -q | while read volume; do
    backup_volume "$volume"
done

# Cleanup old backups (keep 7 days)
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete

log_message "Backup process completed"
```

---

## Docker Compose

### 13. How do you use Docker Compose for multi-container applications?

**Short Answer:** Docker Compose uses YAML files to define and run multi-container applications with services, networks, and volumes.

**Detailed Explanation:**

**Basic Docker Compose Structure:**
```yaml
# docker-compose.yml
version: '3.8'

services:
  # Web application
  webapp:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=database
    depends_on:
      - database
      - redis
    volumes:
      - ./app:/app
      - logs:/app/logs
    networks:
      - app-network
    restart: unless-stopped
  
  # Database
  database:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - db_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - app-network
    restart: unless-stopped
  
  # Cache
  redis:
    image: redis:6-alpine
    volumes:
      - redis_data:/data
    networks:
      - app-network
    restart: unless-stopped

volumes:
  db_data:
  redis_data:
  logs:

networks:
  app-network:
    driver: bridge
```

**Docker Compose Commands:**
```bash
# Start services
docker-compose up                   # Foreground
docker-compose up -d                # Background
docker-compose up --build           # Rebuild images

# Scale services
docker-compose up -d --scale webapp=3

# View services
docker-compose ps
docker-compose top
docker-compose logs webapp
docker-compose logs -f --tail=100

# Stop and remove
docker-compose stop
docker-compose down
docker-compose down -v              # Remove volumes
docker-compose down --rmi all       # Remove images

# Execute commands
docker-compose exec webapp bash
docker-compose exec database psql -U user myapp
```

**Environment Configuration:**
```yaml
# docker-compose.override.yml (development)
version: '3.8'
services:
  webapp:
    build:
      target: development
    volumes:
      - ./src:/app/src
    environment:
      - NODE_ENV=development
      - DEBUG=true
    ports:
      - "3000:3000"
      - "9229:9229"              # Debug port

# docker-compose.prod.yml (production)
version: '3.8'
services:
  webapp:
    image: myapp:latest
    environment:
      - NODE_ENV=production
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
```

### 14. How do you handle service dependencies and health checks in Docker Compose?

**Short Answer:** Use depends_on for startup order, healthcheck for service health monitoring, and wait scripts for robust dependency management.

**Detailed Explanation:**

**Service Dependencies:**
```yaml
version: '3.8'
services:
  webapp:
    image: myapp:latest
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_started
    
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
  
  redis:
    image: redis:6-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
```

**Advanced Health Checks:**
```yaml
services:
  webapp:
    image: myapp:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    
  nginx:
    image: nginx:alpine
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
  
  database:
    image: mysql:8
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 20s
      timeout: 10s
      retries: 5
      start_period: 80s
```

**Wait Scripts for Dependencies:**
```bash
#!/bin/bash
# wait-for-it.sh
set -e

host="$1"
port="$2"
shift 2
cmd="$@"

until nc -z "$host" "$port"; do
  >&2 echo "Waiting for $host:$port..."
  sleep 1
done

>&2 echo "$host:$port is available - executing command"
exec $cmd
```

```dockerfile
# Add wait script to application
COPY wait-for-it.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wait-for-it.sh

# Use in docker-compose
command: ["wait-for-it.sh", "database:5432", "--", "npm", "start"]
```

---

## Performance and Monitoring

### 15. How do you monitor Docker containers and troubleshoot performance issues?

**Short Answer:** Use docker stats, logs, and monitoring tools like Prometheus, Grafana, and cAdvisor to track container performance and resource usage.

**Detailed Explanation:**

**Basic Monitoring Commands:**
```bash
# Resource usage
docker stats                        # Real-time stats all containers
docker stats container_name         # Specific container stats
docker stats --no-stream           # One-time snapshot

# System information
docker system df                    # Disk usage
docker system events               # Real-time events
docker system info                 # System-wide information

# Container inspection
docker inspect container_name       # Detailed container info
docker logs container_name          # Container logs
docker logs -f --tail 100 container_name  # Follow logs

# Process monitoring
docker exec container_name ps aux   # Processes in container
docker exec container_name top      # Real-time process info
```

**Advanced Monitoring Setup:**
```yaml
# monitoring-stack.yml
version: '3.8'
services:
  # Prometheus
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    
  # Grafana
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
  
  # cAdvisor for container metrics
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    privileged: true
  
  # Node Exporter for host metrics
  node_exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro

volumes:
  prometheus_data:
  grafana_data:
```

**Performance Troubleshooting:**
```bash
# CPU and Memory analysis
docker exec container_name cat /proc/cpuinfo
docker exec container_name free -h
docker exec container_name cat /proc/meminfo

# Disk I/O monitoring
docker exec container_name iostat -x 1
docker exec container_name iotop

# Network monitoring
docker exec container_name netstat -tuln
docker exec container_name ss -tuln
docker exec container_name iftop

# Application-specific monitoring
docker exec webapp curl http://localhost:8000/metrics
docker exec database mysql -e "SHOW PROCESSLIST;"
```

### 16. How do you optimize Docker container performance?

**Short Answer:** Optimize through resource limits, efficient base images, proper application configuration, and monitoring resource usage patterns.

**Detailed Explanation:**

**Resource Optimization:**
```bash
# Set resource limits
docker run -d \
  --name webapp \
  --memory=512m \
  --memory-swap=1g \
  --cpus=1.5 \
  --cpu-shares=1024 \
  myapp:latest

# Advanced resource controls
docker run -d \
  --name webapp \
  --memory=1g \
  --memory-reservation=512m \
  --oom-kill-disable=false \
  --cpu-period=100000 \
  --cpu-quota=50000 \
  myapp:latest
```

**Image Optimization:**
```dockerfile
# Use multi-stage builds
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:16-alpine
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001
WORKDIR /app
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --chown=nextjs:nodejs . .
USER nextjs
CMD ["node", "server.js"]
```

**Application-Level Optimization:**
```yaml
# docker-compose with optimizations
version: '3.8'
services:
  webapp:
    image: myapp:latest
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
    environment:
      - NODE_ENV=production
      - UV_THREADPOOL_SIZE=16    # Node.js optimization
    ulimits:
      nproc: 65535
      nofile:
        soft: 65535
        hard: 65535
```

**Monitoring and Alerting:**
```yaml
# Prometheus alert rules
groups:
- name: docker
  rules:
  - alert: ContainerHighCPU
    expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
    for: 5m
    annotations:
      summary: "Container {{ $labels.name }} high CPU usage"
  
  - alert: ContainerHighMemory
    expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.9
    for: 5m
    annotations:
      summary: "Container {{ $labels.name }} high memory usage"
```

---

## Security

### 17. What are Docker security best practices?

**Short Answer:** Run containers as non-root, use minimal base images, scan for vulnerabilities, implement secrets management, and apply security policies.

**Detailed Explanation:**

**Container Security Fundamentals:**
```dockerfile
# Use minimal, secure base images
FROM alpine:3.16                    # Minimal attack surface
# FROM scratch                     # For static binaries

# Create non-root user
RUN addgroup -g 1001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser

# Set secure permissions
COPY --chown=appuser:appgroup app /app
RUN chmod 755 /app

# Drop to non-root user
USER appuser

# Use specific versions
FROM node:16.17.0-alpine@sha256:f21f35732...

# Remove unnecessary packages
RUN apk del .build-deps
```

**Runtime Security:**
```bash
# Run with security options
docker run -d \
  --name webapp \
  --user 1001:1001 \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /var/cache \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --no-new-privileges \
  --security-opt no-new-privileges \
  myapp:latest

# Network security
docker run -d \
  --name webapp \
  --network custom-network \
  --publish 127.0.0.1:8080:8080 \
  myapp:latest
```

**Secrets Management:**
```bash
# Docker secrets (Swarm mode)
echo "db_password_123" | docker secret create db_password -
docker service create \
  --name webapp \
  --secret db_password \
  myapp:latest

# Using external secrets management
docker run -d \
  --name webapp \
  -v /run/secrets:/run/secrets:ro \
  myapp:latest
```

**Image Security Scanning:**
```bash
# Using Docker Scout
docker scout cves myapp:latest
docker scout recommendations myapp:latest

# Using Trivy
trivy image myapp:latest
trivy image --severity HIGH,CRITICAL myapp:latest

# Using Clair
clairctl analyze myapp:latest
```

### 18. How do you implement container security scanning and compliance?

**Short Answer:** Use vulnerability scanners like Trivy, Snyk, or Docker Scout in CI/CD pipelines and implement security policies with tools like OPA Gatekeeper.

**Detailed Explanation:**

**CI/CD Security Pipeline:**
```yaml
# .github/workflows/security.yml
name: Security Scan
on: [push, pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build image
      run: docker build -t myapp:${{ github.sha }} .
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: myapp:${{ github.sha }}
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'
    
    - name: Fail on high vulnerabilities
      run: |
        HIGH_VULNS=$(trivy image --severity HIGH,CRITICAL --format json myapp:${{ github.sha }} | jq '.Results[].Vulnerabilities | length')
        if [ "$HIGH_VULNS" -gt 0 ]; then
          echo "High severity vulnerabilities found"
          exit 1
        fi
```

**Security Policies with OPA:**
```rego
# security-policy.rego
package docker.security

deny[msg] {
    input.User == "root"
    msg := "Container should not run as root user"
}

deny[msg] {
    input.SecurityOpt[_] == "no-new-privileges=false"
    msg := "Container should run with no-new-privileges"
}

deny[msg] {
    not input.ReadonlyRootfs
    msg := "Container should have read-only root filesystem"
}

allow {
    count(deny) == 0
}
```

**Compliance Automation:**
```bash
#!/bin/bash
# compliance-check.sh

# CIS Docker Benchmark checks
check_docker_version() {
    docker_version=$(docker version --format '{{.Server.Version}}')
    echo "Docker version: $docker_version"
    # Add version compliance check
}

check_user_namespaces() {
    if docker info | grep -q "userns"; then
        echo "✓ User namespaces enabled"
    else
        echo "✗ User namespaces not enabled"
    fi
}

check_content_trust() {
    if [ "$DOCKER_CONTENT_TRUST" = "1" ]; then
        echo "✓ Content trust enabled"
    else
        echo "✗ Content trust not enabled"
    fi
}

# Run compliance checks
check_docker_version
check_user_namespaces
check_content_trust
```

---

## Production Best Practices

### 19. How do you deploy Docker containers in production?

**Short Answer:** Use orchestration platforms (Kubernetes, Docker Swarm), implement CI/CD pipelines, configure monitoring, and follow security best practices.

**Detailed Explanation:**

**Production Deployment Strategy:**
```yaml
# Production docker-compose.yml
version: '3.8'
services:
  webapp:
    image: registry.company.com/myapp:${VERSION}
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
    networks:
      - app-network
    secrets:
      - db_password
      - api_key
    configs:
      - source: app_config
        target: /app/config.yml
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  app-network:
    external: true

secrets:
  db_password:
    external: true
  api_key:
    external: true

configs:
  app_config:
    external: true
```

**Blue-Green Deployment:**
```bash
#!/bin/bash
# blue-green-deploy.sh

GREEN_COMPOSE="docker-compose.green.yml"
BLUE_COMPOSE="docker-compose.blue.yml"
CURRENT_COLOR=$(docker-compose -f $GREEN_COMPOSE ps -q | wc -l)

if [ "$CURRENT_COLOR" -gt 0 ]; then
    DEPLOY_COLOR="blue"
    CURRENT_COLOR="green"
    DEPLOY_COMPOSE=$BLUE_COMPOSE
else
    DEPLOY_COLOR="green"
    CURRENT_COLOR="blue"
    DEPLOY_COMPOSE=$GREEN_COMPOSE
fi

echo "Deploying to $DEPLOY_COLOR environment"

# Deploy new version
docker-compose -f $DEPLOY_COMPOSE up -d

# Health check
echo "Performing health checks..."
for i in {1..30}; do
    if curl -f http://localhost:8080/health; then
        echo "Health check passed"
        break
    fi
    sleep 5
done

# Switch traffic (update load balancer)
echo "Switching traffic to $DEPLOY_COLOR"
# Update nginx config or load balancer

# Stop old environment
if [ "$CURRENT_COLOR" != "" ]; then
    echo "Stopping $CURRENT_COLOR environment"
    docker-compose -f docker-compose.$CURRENT_COLOR.yml down
fi
```

**CI/CD Pipeline Integration:**
```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - security
  - deploy

build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

security_scan:
  stage: security
  script:
    - trivy image $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy:latest image $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

deploy_production:
  stage: deploy
  script:
    - docker stack deploy -c docker-compose.prod.yml myapp
  environment:
    name: production
  only:
    - master
```

### 20. How do you handle logging and monitoring in production Docker environments?

**Short Answer:** Implement centralized logging with ELK/EFK stack, use monitoring tools like Prometheus/Grafana, and configure alerting for critical metrics.

**Detailed Explanation:**

**Centralized Logging Setup:**
```yaml
# logging-stack.yml
version: '3.8'
services:
  # Elasticsearch
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
  
  # Logstash
  logstash:
    image: docker.elastic.co/logstash/logstash:8.5.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    ports:
      - "5044:5044"
    depends_on:
      - elasticsearch
  
  # Kibana
  kibana:
    image: docker.elastic.co/kibana/kibana:8.5.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch
  
  # Filebeat
  filebeat:
    image: docker.elastic.co/beats/filebeat:8.5.0
    user: root
    volumes:
      - ./filebeat.yml:/usr/share/filebeat/filebeat.yml
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    depends_on:
      - logstash

volumes:
  elasticsearch_data:
```

**Application Logging Configuration:**
```yaml
# Application with structured logging
version: '3.8'
services:
  webapp:
    image: myapp:latest
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service,environment"
    labels:
      - "service=webapp"
      - "environment=production"
    environment:
      - LOG_LEVEL=info
      - LOG_FORMAT=json
```

**Monitoring and Alerting:**
```yaml
# monitoring.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./alerts.yml:/etc/prometheus/alerts.yml
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'
  
  alertmanager:
    image: prom/alertmanager:latest
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
    ports:
      - "9093:9093"
  
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./dashboards:/etc/grafana/provisioning/dashboards
      - ./datasources:/etc/grafana/provisioning/datasources
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin

volumes:
  grafana_data:
```

This comprehensive Docker interview guide covers all essential topics for Linux administrators and DevOps engineers, providing both quick answers and detailed explanations with practical examples and real-world scenarios.