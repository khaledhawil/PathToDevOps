# Prometheus and Grafana Complete Guide

## What is Monitoring

Monitoring is observing your systems to detect problems, measure performance, and understand behavior.

**Why monitoring matters:**
- Detect problems before users complain
- Understand system performance
- Track application health
- Alert on critical issues
- Optimize resource usage

**How monitoring connects to DevOps:**
- Monitors Docker containers
- Tracks Kubernetes pods
- Watches EC2 instances
- Alerts CI/CD pipeline
- Helps with capacity planning

## Prometheus: Metrics Collection

Prometheus collects and stores metrics (numbers) from your systems.

**What Prometheus monitors:**
- CPU usage
- Memory usage
- HTTP requests
- Response times
- Error rates
- Custom application metrics

### Prometheus Architecture

```
Your Applications (expose /metrics endpoint)
       ↓
Prometheus (scrapes metrics every 15s)
       ↓
Stores in time-series database
       ↓
Grafana (visualizes data)
AlertManager (sends alerts)
```

### Installing Prometheus

**Method 1: Binary installation (Ubuntu)**

**Step 1: Download Prometheus**

```bash
# Create prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

# Create directories
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

# Download Prometheus
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz

# Extract
tar -xvf prometheus-2.45.0.linux-amd64.tar.gz
cd prometheus-2.45.0.linux-amd64

# Copy binaries
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/

# Copy config files
sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo cp prometheus.yml /etc/prometheus/

# Set ownership
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
```

**Explanation:**
- Creates dedicated user for security
- `/etc/prometheus`: Configuration files
- `/var/lib/prometheus`: Database storage
- `prometheus`: Main server binary
- `promtool`: Tool for testing configs

**Step 2: Configure Prometheus**

Edit `/etc/prometheus/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s  # Collect metrics every 15 seconds
  evaluation_interval: 15s  # Evaluate rules every 15 seconds

# AlertManager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - localhost:9093

# Load rules once and periodically evaluate them
rule_files:
  - "rules.yml"

# A scrape configuration
scrape_configs:
  # Monitor Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  # Monitor Node Exporter (system metrics)
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
  
  # Monitor your application
  - job_name: 'my_application'
    static_configs:
      - targets: ['localhost:5000']
    metrics_path: '/metrics'
```

**Explanation line by line:**
- `scrape_interval: 15s`: How often to collect metrics
- `evaluation_interval: 15s`: How often to check alert rules
- `alertmanagers`: Where to send alerts
- `rule_files`: Alert rule definitions
- `scrape_configs`: What to monitor (targets)
- `job_name`: Logical name for group of targets
- `targets`: Addresses to scrape metrics from
- `metrics_path`: URL path for metrics (default is /metrics)

**Step 3: Create systemd service**

Create `/etc/systemd/system/prometheus.service`:

```ini
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```

**Explanation:**
- `User=prometheus`: Runs as prometheus user (security)
- `--config.file`: Path to configuration
- `--storage.tsdb.path`: Where to store metrics data
- `--web.console.*`: Web UI resources

**Step 4: Start Prometheus**

```bash
# Reload systemd
sudo systemctl daemon-reload

# Start Prometheus
sudo systemctl start prometheus

# Enable on boot
sudo systemctl enable prometheus

# Check status
sudo systemctl status prometheus

# View logs
sudo journalctl -u prometheus -f
```

**Step 5: Access Prometheus**

Open browser: `http://localhost:9090`

Try queries:
- `up`: Shows which targets are reachable
- `prometheus_http_requests_total`: Total HTTP requests to Prometheus

### Node Exporter: System Metrics

Node Exporter exposes hardware and OS metrics.

**Step 1: Install Node Exporter**

```bash
# Download
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz

# Extract
tar -xvf node_exporter-1.6.0.linux-amd64.tar.gz

# Copy binary
sudo cp node_exporter-1.6.0.linux-amd64/node_exporter /usr/local/bin/

# Create user
sudo useradd --no-create-home --shell /bin/false node_exporter

# Set ownership
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

**Step 2: Create systemd service**

Create `/etc/systemd/system/node_exporter.service`:

```ini
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

**Step 3: Start Node Exporter**

```bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
```

**Step 4: Verify metrics**

```bash
curl http://localhost:9100/metrics
```

You'll see hundreds of metrics like:
- `node_cpu_seconds_total`: CPU usage
- `node_memory_MemAvailable_bytes`: Available memory
- `node_disk_io_time_seconds_total`: Disk I/O time

### Exposing Metrics from Python Application

Add metrics to your Python app:

**Step 1: Install prometheus_client**

```bash
pip install prometheus-client
```

**Step 2: Add metrics to application**

**app.py:**
```python
from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY
import time

app = Flask(__name__)

# Define metrics
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint']
)

ACTIVE_USERS = Gauge(
    'active_users',
    'Number of active users'
)

# Simulate active users
ACTIVE_USERS.set(42)

@app.before_request
def before_request():
    # Start timing
    flask.g.start_time = time.time()

@app.after_request
def after_request(response):
    # Record request
    REQUEST_COUNT.labels(
        method=flask.request.method,
        endpoint=flask.request.path,
        status=response.status_code
    ).inc()
    
    # Record duration
    if hasattr(flask.g, 'start_time'):
        duration = time.time() - flask.g.start_time
        REQUEST_DURATION.labels(
            method=flask.request.method,
            endpoint=flask.request.path
        ).observe(duration)
    
    return response

@app.route('/')
def home():
    return jsonify({'message': 'Welcome to E-commerce API'})

@app.route('/metrics')
def metrics():
    # Prometheus scrapes this endpoint
    return generate_latest(REGISTRY), 200, {'Content-Type': 'text/plain; charset=utf-8'}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

**Explanation of metrics:**

**Counter:** Number that only goes up.
```python
REQUEST_COUNT.labels(method='GET', endpoint='/', status=200).inc()
```
Use for: Total requests, errors, events

**Histogram:** Measures distribution of values.
```python
REQUEST_DURATION.labels(method='GET', endpoint='/').observe(0.025)
```
Use for: Response times, request sizes

**Gauge:** Number that can go up or down.
```python
ACTIVE_USERS.set(42)
```
Use for: Current users, queue size, temperature

**Step 3: Test metrics endpoint**

```bash
# Start application
python app.py

# Make some requests
curl http://localhost:5000/
curl http://localhost:5000/

# View metrics
curl http://localhost:5000/metrics
```

Output includes:
```
http_requests_total{endpoint="/",method="GET",status="200"} 2.0
http_request_duration_seconds_bucket{endpoint="/",method="GET",le="0.005"} 2.0
active_users 42.0
```

### Prometheus Query Language (PromQL)

Query metrics in Prometheus UI:

**Basic queries:**

**1. Current value:**
```
up
```
Shows if targets are up (1) or down (0).

**2. Rate of increase:**
```
rate(http_requests_total[5m])
```
Requests per second over last 5 minutes.

**3. Filter by label:**
```
http_requests_total{status="200"}
```
Only successful requests.

**4. Aggregate:**
```
sum(http_requests_total) by (endpoint)
```
Total requests per endpoint.

**5. Multiple conditions:**
```
http_requests_total{method="GET", status="200"}
```
Only GET requests with 200 status.

**Advanced queries:**

**Average response time:**
```
rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m])
```

**Error rate:**
```
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))
```

**Memory usage percentage:**
```
100 - ((node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100)
```

**CPU usage:**
```
100 - (avg by(instance)(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

### Alert Rules

Create alerts when metrics exceed thresholds.

**Create `/etc/prometheus/rules.yml`:**

```yaml
groups:
  - name: example_alerts
    interval: 30s
    rules:
      # Alert if instance is down
      - alert: InstanceDown
        expr: up == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} is down"
          description: "{{ $labels.instance }} has been down for more than 5 minutes."
      
      # Alert if high memory usage
      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 80
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is {{ $value }}%"
      
      # Alert if high CPU usage
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance)(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is {{ $value }}%"
      
      # Alert if high error rate
      - alert: HighErrorRate
        expr: (sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))) * 100 > 5
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }}%"
      
      # Alert if slow responses
      - alert: SlowResponses
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Slow response times detected"
          description: "95th percentile response time is {{ $value }}s"
```

**Explanation:**
- `alert`: Alert name
- `expr`: PromQL query that triggers alert
- `for`: How long condition must be true
- `severity`: critical/warning/info
- `annotations`: Human-readable description

**Reload Prometheus:**
```bash
sudo systemctl reload prometheus
```

**View alerts:** `http://localhost:9090/alerts`

## Grafana: Visualization

Grafana creates beautiful dashboards from Prometheus data.

### Installing Grafana

**Step 1: Install Grafana**

```bash
# Add Grafana repository
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# Install
sudo apt-get update
sudo apt-get install grafana

# Start Grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server
```

**Step 2: Access Grafana**

Open browser: `http://localhost:3000`

**Default credentials:**
- Username: `admin`
- Password: `admin`

Change password when prompted.

### Connecting Prometheus to Grafana

**Step 1: Add Data Source**

1. Click "Configuration" (gear icon) → "Data Sources"
2. Click "Add data source"
3. Select "Prometheus"
4. Set URL: `http://localhost:9090`
5. Click "Save & Test"

You should see "Data source is working".

### Creating Your First Dashboard

**Step 1: Create new dashboard**

1. Click "+" icon → "Dashboard"
2. Click "Add new panel"

**Step 2: Add CPU usage panel**

**Query:** 
```
100 - (avg by(instance)(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

**Panel settings:**
- Title: "CPU Usage"
- Unit: Percent (0-100)
- Graph type: Time series

**Step 3: Add memory usage panel**

**Query:**
```
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

**Panel settings:**
- Title: "Memory Usage"
- Unit: Percent (0-100)
- Thresholds: 80 (yellow), 90 (red)

**Step 4: Add disk usage panel**

**Query:**
```
100 - ((node_filesystem_avail_bytes{mountpoint="/",fstype!="rootfs"} / node_filesystem_size_bytes{mountpoint="/",fstype!="rootfs"}) * 100)
```

**Panel settings:**
- Title: "Disk Usage"
- Unit: Percent (0-100)

**Step 5: Add HTTP requests panel**

**Query:**
```
sum(rate(http_requests_total[5m])) by (endpoint)
```

**Panel settings:**
- Title: "HTTP Requests per Second"
- Legend: {{endpoint}}
- Graph type: Time series

**Step 6: Add response time panel**

**Query:**
```
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

**Panel settings:**
- Title: "95th Percentile Response Time"
- Unit: Seconds
- Thresholds: 0.5 (yellow), 1 (red)

**Step 7: Save dashboard**

Click "Save dashboard" icon, give it a name.

### Importing Pre-built Dashboards

Grafana has thousands of ready-made dashboards.

**Step 1: Find dashboard ID**

Visit https://grafana.com/grafana/dashboards/

Popular dashboards:
- **Node Exporter Full:** ID 1860
- **Docker Monitoring:** ID 893
- **Kubernetes Cluster:** ID 7249
- **Nginx:** ID 12708

**Step 2: Import dashboard**

1. Click "+" icon → "Import"
2. Enter dashboard ID: `1860`
3. Click "Load"
4. Select Prometheus data source
5. Click "Import"

You now have a professional dashboard instantly!

### Dashboard Variables

Variables make dashboards dynamic.

**Example: Select server**

1. Dashboard settings → "Variables" → "Add variable"
2. Name: `instance`
3. Type: Query
4. Data source: Prometheus
5. Query: `label_values(up, instance)`
6. Click "Update"

Now use in queries:
```
up{instance="$instance"}
```

Dropdown appears at top of dashboard to select instance.

### Alerting in Grafana

Grafana can send alerts via email, Slack, PagerDuty, etc.

**Step 1: Configure notification channel**

1. "Alerting" → "Notification channels" → "Add channel"
2. Name: "Email Alerts"
3. Type: Email
4. Addresses: your-email@example.com
5. Click "Save"

**Step 2: Add alert to panel**

1. Edit panel
2. Click "Alert" tab
3. Click "Create Alert"
4. Conditions:
   - WHEN `avg()` OF `query(A, 5m, now)` IS ABOVE `80`
5. Notifications:
   - Send to: Email Alerts
6. Message: "CPU usage is high!"
7. Click "Save"

Now you receive email when CPU exceeds 80%.

## Monitoring Kubernetes with Prometheus

Prometheus can monitor entire Kubernetes cluster.

### Deploy Prometheus on Kubernetes

**prometheus-deployment.yaml:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    
    scrape_configs:
      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
          - role: node
      
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:latest
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config
          mountPath: /etc/prometheus
      volumes:
      - name: config
        configMap:
          name: prometheus-config
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
spec:
  type: NodePort
  selector:
    app: prometheus
  ports:
  - port: 9090
    targetPort: 9090
    nodePort: 30090
```

**Deploy:**
```bash
kubectl apply -f prometheus-deployment.yaml

# Get service URL
kubectl get service prometheus
```

Access: `http://NODE_IP:30090`

### Deploy Grafana on Kubernetes

**grafana-deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin"
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
spec:
  type: NodePort
  selector:
    app: grafana
  ports:
  - port: 3000
    targetPort: 3000
    nodePort: 30300
```

**Deploy:**
```bash
kubectl apply -f grafana-deployment.yaml
```

Access: `http://NODE_IP:30300`

## Complete Monitoring Stack

Here's how everything connects:

```
Your Application (Python/Node.js/etc.)
  ↓ exposes /metrics endpoint
Node Exporter (system metrics)
  ↓ exposes /metrics endpoint
Kubernetes (pod/node metrics)
  ↓ exposes metrics
Prometheus (collects all metrics)
  ↓ stores in database
  ↓ evaluates alert rules
AlertManager (receives alerts)
  ↓ sends notifications
Email / Slack / PagerDuty

Grafana (reads from Prometheus)
  ↓ creates dashboards
  ↓ visualizes metrics
User views dashboards
```

## Best Practices

**1. Use meaningful metric names:**
```
# Good
http_requests_total
http_request_duration_seconds
active_users_count

# Bad
requests
time
users
```

**2. Add labels for filtering:**
```python
REQUEST_COUNT.labels(
    method='GET',
    endpoint='/',
    status='200'
).inc()
```

**3. Set appropriate scrape intervals:**
- Fast-changing metrics: 10-15s
- Slow-changing metrics: 1m
- Very slow: 5m

**4. Use histograms for latency:**
```python
REQUEST_DURATION.observe(response_time)
```

**5. Set up retention:**
```
--storage.tsdb.retention.time=30d
```

**6. Monitor the monitors:**
```
up{job="prometheus"}
```

**7. Use service discovery:**
Instead of hardcoding targets, use Kubernetes/EC2 service discovery.

**8. Create meaningful alerts:**
- Not too sensitive (avoid alert fatigue)
- Not too insensitive (catch real problems)
- Include runbook links

## Practice Exercises

**Exercise 1: Basic Setup**
1. Install Prometheus
2. Install Node Exporter
3. Configure Prometheus to scrape Node Exporter
4. Query CPU metrics

**Exercise 2: Application Metrics**
1. Add metrics to Python/Node.js app
2. Expose /metrics endpoint
3. Configure Prometheus to scrape app
4. Query request counts

**Exercise 3: Grafana Dashboard**
1. Install Grafana
2. Connect to Prometheus
3. Import Node Exporter dashboard
4. Create custom panel

**Exercise 4: Alerting**
1. Create alert rule (high CPU)
2. Configure AlertManager
3. Set up email notifications
4. Test alert by causing high CPU

**Exercise 5: Kubernetes Monitoring**
1. Deploy Prometheus on Kubernetes
2. Deploy Grafana on Kubernetes
3. Monitor pod metrics
4. Create cluster overview dashboard

## Troubleshooting

**Problem: Metrics not appearing**

Check target status:
```bash
curl http://localhost:9090/api/v1/targets
```

**Problem: Grafana can't connect to Prometheus**

Test connection:
```bash
curl http://localhost:9090/api/v1/query?query=up
```

**Problem: Alerts not firing**

Check rules:
```bash
promtool check rules /etc/prometheus/rules.yml
```

**Problem: High memory usage**

Reduce retention:
```
--storage.tsdb.retention.time=15d
```

## Next Steps

You now understand monitoring with Prometheus and Grafana! Practice by:

1. Monitoring your applications
2. Creating custom dashboards
3. Setting up meaningful alerts
4. Monitoring Docker containers
5. Monitoring Kubernetes clusters
6. Integrating with CI/CD pipelines

Monitoring is essential for reliable DevOps operations!
