
# Dockerized Flask App 

## Description
This project is a simple **Flask** web application integrated with **Redis** for counting page visits.
The application demonstrates the use of **Docker** 
for containerizing the app and **Docker Compose** for orchestrating multi-container environments.  

## Features
- Flask-based web application.
- Redis for storing and managing the visit count.
- Demonstrates containerization with Docker.
- Supports live code updates with a bind mount volume.

## Prerequisites
Ensure the following are installed on your system:
- Docker
- Docker Compose

### Project Setup

1. **Create the Project Directory**:
```bash
   $ mkdir project
   $ cd project/
```
2. **Create the Flask Application Code**:
```bash
$ vim app.py
```

```py
import time
import redis
from flask import Flask

app = Flask(__name__)
cache = redis.Redis(host='redis', port=6379)

def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)

@app.route('/')
def hello():
    count = get_hit_count()
    return 'Hello From 7awil Web, I have been seen {} times.\n'.format(count)

```
3. **Define Dependencies**:
```bash
$ vim requirements.txt
flask
redis
```
4. **Write the Dockerfile:**
```bash
$ vim Dockerfile
```
```Dockerfile
FROM python:3.7-alpine
WORKDIR /app
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
RUN apk add --no-cache gcc musl-dev linux-headers
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
EXPOSE 5000
COPY . .
CMD ["flask", "run"]
```
5. **Create the Docker Compose Configuration:**
```bash
$ vim docker-compose.yml
version: '3'
services:
  web:
    build: .
    ports:
      - "9000:5000"
  redis:
    image: "redis:alpine"
```
# Running the Application
```bash
$ docker-compose up -d

```
- Access the Application: Open your browser and go to:
http://localhost:9000



* Modify the Code: Update app.py to change the message:
return 'Hello From DevOps Area, I have been seen {} times.\n'.format(count)

- Notice the Change Doesn't Reflect: Reload the browser. The app message remains unchanged.
* To apply changes, choose one of the following options:

## Updating the Application
* Option 1: Rebuild the Docker Image
Stop and Rebuild:
```bash
$ docker-compose down
$ docker-compose up -d --build
```

- Check the App Again: Visit http://localhost:9000. The changes will now be reflected.

* Option 2: Use Bind Mount Volume (Recommended)
Update the docker-compose.yml File:
```yaml

version: '3'
services:
  web:
    build: .
    ports:
      - "9000:5000"
    volumes:
      - .:/app
    environment:
      FLASK_DEBUG: "true"
  redis:
    image: "redis:alpine"
```
## Restart the Containers:
```bash
$ docker-compose down
$ docker-compose up -d
```
* Modify app.py Again: Change the message to:

return 'Hello From Docker Compose, I have been seen {} times.\n'.format(count)

- Refresh the Browser: The app will now reflect the updated message without rebuilding the image.



# Explanation of Bind Mount Volume

- When using a bind mount volume in docker-compose.yml:

- The host machine's current directory (.) is mounted to the container's /app directory.
- Changes to the code on the host machine are immediately reflected inside the container.
- No need to rebuild the Docker image.


## Clean UP

* Stop and Remove Containers:
```bash
$ docker-compose down

* Remove Unused Docker Images:

$ docker system prune -f
```


# Summary

* This project demonstrates:

Building a Flask app with Docker.
Using Redis for caching.
Updating the application with and without rebuilding images.
Efficient development using bind mount volumes.

