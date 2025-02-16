#  installation of prometheus and grafana
- 1. Binary Download 
- 2. Running Prometheus in a container using Docker 
- 3. Running Grafana in K8s and Helm 


## 1. Binary Download 
- 1. open the Your Terminal and follow the steps below or put the following commands in bash script file and run it:
```bash
sudo useradd --no-create-home   -s /bin/bash            prometheus
sudo mkdir /etc/prometheus 
sudo  mkdir /var/lib/prometheus
sudo chown  prometheus:prometheus   /var/lib/prometheus 
cd /tmp 
wget https://github.com/prometheus/prometheus/releases/download/v2.35.0/prometheus-2.35.0.linux-amd64.tar.gz
tar  -xvf  prometheus-2.35.0.linux-amd64.tar.gz
cd prometheus-2.35.0.linux-amd64
sudo  mv console*   /etc/prometheus/
sudo mv  prometheus.yml /etc/prometheus/
sudo  chown -R   prometheus:prometheus    /etc/prometheus/
sudo mv   prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/
 sudo  chown -R   prometheus:prometheus    /usr/local/bin/prometheus 
 sudo tee /etc/systemd/system/prometheus.service <<EOF
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
  --storage.tsdb.path=/var/lib/prometheus/  \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl  daemon-reload
sudo systemctl start  prometheus.service
sudo systemctl enable  prometheus.service 
sudo apt-get   install -y apt-transport-https 
sudo apt-get   install -y software-properties-common wget 
sudo systemctl  daemon-reload
sudo systemctl start  prometheus.service
sudo systemctl enable  prometheus.service 

```
- 2. open the browser and navigate to http://localhost:9090/ to see the prometheus dashboard 


