# Docker Fundamentals

## What is Docker

Docker is a containerization platform that packages applications with their dependencies into standardized units called containers.

**Container vs Virtual Machine:**

Virtual Machine:
```
App A  |  App B
OS A   |  OS B
Hypervisor
Host OS
Hardware
```

Container:
```
App A  |  App B
Docker Engine
Host OS
Hardware
```

**Advantages of Containers:**
- Lightweight (no full OS)
- Fast startup (seconds vs minutes)
- Consistent across environments
- Efficient resource usage
- Easy to scale
- Portable

## Installing Docker

**Ubuntu/Debian:**
```bash
# Update packages
sudo apt update

# Install dependencies
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# Verify installation
docker --version
```

**Add user to docker group:**
```bash
sudo usermod -aG docker $USER
newgrp docker
```

Now you can run Docker without sudo.

**Test installation:**
```bash
docker run hello-world
```

## Docker Images

Images are templates for creating containers.

**List images:**
```bash
docker images
docker image ls
```

**Pull image from Docker Hub:**
```bash
docker pull nginx
docker pull nginx:1.21
docker pull ubuntu:22.04
```

**Search images:**
```bash
docker search nginx
```

**Remove image:**
```bash
docker rmi nginx
docker rmi nginx:1.21
```

**Remove unused images:**
```bash
docker image prune
docker image prune -a  # Remove all unused
```

**Image tags:**
```
nginx:latest  # Latest version
nginx:1.21    # Specific version
nginx:alpine  # Lightweight version
```

## Docker Containers

Containers are running instances of images.

**Run container:**
```bash
docker run nginx
```

**Run in background (detached):**
```bash
docker run -d nginx
```

**Run with name:**
```bash
docker run -d --name webserver nginx
```

**Run with port mapping:**
```bash
docker run -d -p 8080:80 nginx
```

This maps host port 8080 to container port 80.

**Run interactive container:**
```bash
docker run -it ubuntu bash
```

The `-it` flags:
- `-i` - Interactive (keep STDIN open)
- `-t` - Allocate pseudo-TTY (terminal)

**List running containers:**
```bash
docker ps
```

**List all containers (including stopped):**
```bash
docker ps -a
```

**Stop container:**
```bash
docker stop webserver
docker stop container_id
```

**Start stopped container:**
```bash
docker start webserver
```

**Restart container:**
```bash
docker restart webserver
```

**Remove container:**
```bash
docker rm webserver
```

**Remove running container (force):**
```bash
docker rm -f webserver
```

**Remove all stopped containers:**
```bash
docker container prune
```

## Working with Containers

**Execute command in running container:**
```bash
docker exec webserver ls /usr/share/nginx/html
```

**Get shell in running container:**
```bash
docker exec -it webserver bash
```

**View container logs:**
```bash
docker logs webserver
docker logs -f webserver  # Follow logs
docker logs --tail 100 webserver  # Last 100 lines
```

**View container details:**
```bash
docker inspect webserver
```

**View resource usage:**
```bash
docker stats
docker stats webserver
```

**Copy files to/from container:**
```bash
# Copy to container
docker cp index.html webserver:/usr/share/nginx/html/

# Copy from container
docker cp webserver:/var/log/nginx/access.log ./
```

## Environment Variables

**Pass environment variable:**
```bash
docker run -e APP_ENV=production myapp
docker run -e DB_HOST=192.168.1.100 -e DB_PORT=3306 myapp
```

**From file:**
```bash
# Create .env file
echo "APP_ENV=production" > .env
echo "DB_HOST=localhost" >> .env

# Use file
docker run --env-file .env myapp
```

## Volumes (Data Persistence)

Containers are ephemeral. Volumes persist data.

**Create volume:**
```bash
docker volume create mydata
```

**List volumes:**
```bash
docker volume ls
```

**Mount volume:**
```bash
docker run -d -v mydata:/var/lib/mysql mysql
```

**Bind mount (host directory):**
```bash
docker run -d -v /host/path:/container/path nginx
docker run -d -v $(pwd)/html:/usr/share/nginx/html nginx
```

**Read-only volume:**
```bash
docker run -d -v $(pwd)/config:/etc/app:ro myapp
```

**Remove volume:**
```bash
docker volume rm mydata
```

**Remove unused volumes:**
```bash
docker volume prune
```

## Dockerfile

Dockerfile defines how to build an image.

**Basic Dockerfile:**
```dockerfile
# Base image
FROM ubuntu:22.04

# Maintainer info
LABEL maintainer="your@email.com"

# Update and install packages
RUN apt-get update && apt-get install -y nginx

# Copy files
COPY index.html /var/share/nginx/html/

# Set working directory
WORKDIR /app

# Expose port
EXPOSE 80

# Command to run
CMD ["nginx", "-g", "daemon off;"]
```

**Dockerfile instructions:**

**FROM** - Base image
```dockerfile
FROM python:3.9
FROM node:16-alpine
```

**RUN** - Execute command during build
```dockerfile
RUN apt-get update
RUN pip install flask
```

**COPY** - Copy files from host to image
```dockerfile
COPY app.py /app/
COPY requirements.txt /app/
```

**ADD** - Like COPY but can download URLs and extract archives
```dockerfile
ADD https://example.com/file.tar.gz /app/
```

**WORKDIR** - Set working directory
```dockerfile
WORKDIR /app
```

**ENV** - Set environment variable
```dockerfile
ENV APP_ENV=production
ENV DB_HOST=localhost
```

**EXPOSE** - Document port (doesn't actually publish)
```dockerfile
EXPOSE 8080
```

**CMD** - Default command (can be overridden)
```dockerfile
CMD ["python", "app.py"]
```

**ENTRYPOINT** - Main command (not easily overridden)
```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

**USER** - Run as specific user
```dockerfile
USER nobody
```

**VOLUME** - Create mount point
```dockerfile
VOLUME /data
```

## Building Images

**Build image:**
```bash
docker build -t myapp:1.0 .
```

The `.` is the build context (current directory).

**Build with different Dockerfile:**
```bash
docker build -f Dockerfile.prod -t myapp:prod .
```

**Build with build arguments:**
```bash
docker build --build-arg VERSION=1.0 -t myapp .
```

In Dockerfile:
```dockerfile
ARG VERSION
RUN echo "Building version $VERSION"
```

**View build history:**
```bash
docker history myapp:1.0
```

## Python Application Example

**Directory structure:**
```
myapp/
  app.py
  requirements.txt
  Dockerfile
```

**app.py:**
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from Docker!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

**requirements.txt:**
```
flask==2.0.1
```

**Dockerfile:**
```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
```

**Build and run:**
```bash
docker build -t flask-app .
docker run -d -p 5000:5000 --name myflask flask-app
```

**Test:**
```bash
curl http://localhost:5000
```

## Multi-stage Builds

Reduces image size by separating build and runtime.

**Example:**
```dockerfile
# Build stage
FROM python:3.9 AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Production stage
FROM python:3.9-slim

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /root/.local /root/.local
COPY app.py .

# Update PATH
ENV PATH=/root/.local/bin:$PATH

CMD ["python", "app.py"]
```

**Benefits:**
- Smaller final image
- Build tools not in production image
- Faster deployment
- More secure

## Docker Networks

Containers communicate through networks.

**Default networks:**
- bridge: Default network
- host: Use host networking
- none: No networking

**List networks:**
```bash
docker network ls
```

**Create network:**
```bash
docker network create mynetwork
```

**Run container on network:**
```bash
docker run -d --name web --network mynetwork nginx
docker run -d --name db --network mynetwork mysql
```

**Containers on same network can communicate by name:**
```bash
# From web container
curl http://db:3306
```

**Inspect network:**
```bash
docker network inspect mynetwork
```

**Connect container to network:**
```bash
docker network connect mynetwork container_name
```

**Disconnect:**
```bash
docker network disconnect mynetwork container_name
```

## Docker Compose

Manage multi-container applications with single file.

**Install Docker Compose:**
```bash
sudo apt install docker-compose
```

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    depends_on:
      - api
  
  api:
    build: ./api
    ports:
      - "5000:5000"
    environment:
      - DB_HOST=db
      - DB_PORT=3306
    depends_on:
      - db
  
  db:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=secret
      - MYSQL_DATABASE=myapp
    volumes:
      - dbdata:/var/lib/mysql

volumes:
  dbdata:
```

**Commands:**

Start services:
```bash
docker-compose up
docker-compose up -d  # Background
```

Stop services:
```bash
docker-compose down
```

View logs:
```bash
docker-compose logs
docker-compose logs web
docker-compose logs -f  # Follow
```

Build images:
```bash
docker-compose build
```

Restart service:
```bash
docker-compose restart web
```

Execute command:
```bash
docker-compose exec web sh
```

Scale service:
```bash
docker-compose up -d --scale api=3
```

## Docker Registry

**Docker Hub (public):**
```bash
# Login
docker login

# Tag image
docker tag myapp:1.0 username/myapp:1.0

# Push image
docker push username/myapp:1.0

# Pull image
docker pull username/myapp:1.0
```

**Private registry:**
```bash
# Run local registry
docker run -d -p 5000:5000 --name registry registry:2

# Tag for private registry
docker tag myapp localhost:5000/myapp

# Push to private registry
docker push localhost:5000/myapp

# Pull from private registry
docker pull localhost:5000/myapp
```

## Best Practices

1. **Use official base images**
2. **Use specific tags, not latest**
3. **Minimize layers (combine RUN commands)**
4. **Use .dockerignore file**
5. **Don't run as root**
6. **Use multi-stage builds**
7. **Keep images small**
8. **One process per container**
9. **Use volumes for persistent data**
10. **Document with LABEL**

**.dockerignore example:**
```
node_modules
.git
.env
*.log
.DS_Store
```

**Combine RUN commands:**
```dockerfile
# Bad - creates 3 layers
RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get clean

# Good - creates 1 layer
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean
```

## Troubleshooting

**View container logs:**
```bash
docker logs container_name
```

**Check container processes:**
```bash
docker top container_name
```

**Inspect container:**
```bash
docker inspect container_name
```

**Check resource usage:**
```bash
docker stats container_name
```

**Get shell in container:**
```bash
docker exec -it container_name bash
```

**Check network connectivity:**
```bash
docker exec container_name ping other_container
```

## Practice Exercises

1. Build Docker image for Python application
2. Create multi-container app with Docker Compose
3. Set up persistent database with volumes
4. Create custom network and connect containers
5. Push image to Docker Hub
6. Create multi-stage build
7. Optimize Dockerfile for smaller image
8. Set up nginx reverse proxy with Docker

## Next Steps

Docker is foundation for Kubernetes. Master containerization before moving to orchestration.

Continue to: `02-kubernetes-basics.md`
