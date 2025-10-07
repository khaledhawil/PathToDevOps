# Networking Fundamentals

## Why Networking Matters in DevOps

Every DevOps tool communicates over networks:
- Applications connect to databases over network
- CI/CD pipelines deploy to remote servers
- Kubernetes pods communicate across nodes
- Monitoring systems collect metrics over network
- Load balancers distribute traffic
- Containers need networking to talk to each other

Without networking knowledge, you cannot troubleshoot connectivity issues, configure firewalls, or understand how distributed systems work.

## OSI Model and TCP/IP

### OSI Model - 7 Layers

The OSI (Open Systems Interconnection) model describes how network communication works.

**Layer 7 - Application:**
- User-facing applications
- HTTP, HTTPS, FTP, SSH, DNS
- Example: Web browser requesting webpage

**Layer 6 - Presentation:**
- Data formatting, encryption, compression
- SSL/TLS encryption happens here
- Example: HTTPS encrypts HTTP traffic

**Layer 5 - Session:**
- Manages connections between applications
- Session establishment and teardown
- Example: Login session to web application

**Layer 4 - Transport:**
- End-to-end communication
- TCP (reliable) and UDP (fast)
- Port numbers identify applications
- Example: TCP port 443 for HTTPS

**Layer 3 - Network:**
- Routing between networks
- IP addresses identify devices
- Routers work at this layer
- Example: Routing packet from 192.168.1.5 to 10.0.0.10

**Layer 2 - Data Link:**
- Communication between devices on same network
- MAC addresses identify network interfaces
- Switches work at this layer
- Example: Ethernet frames on local network

**Layer 1 - Physical:**
- Physical transmission of bits
- Cables, wireless, fiber optics
- Example: Electrical signals on ethernet cable

### TCP/IP Model - 4 Layers

Practical implementation used by internet:

**Application Layer:**
- Combines OSI layers 5, 6, 7
- HTTP, FTP, SSH, DNS, SMTP

**Transport Layer:**
- TCP and UDP protocols
- Port numbers

**Internet Layer:**
- IP protocol
- Routing

**Network Access Layer:**
- Combines OSI layers 1, 2
- Ethernet, WiFi

## IP Addresses

### IPv4 Addresses

Format: four numbers (0-255) separated by dots

**Examples:**
```
192.168.1.100
10.0.0.5
172.16.0.1
8.8.8.8 (Google DNS)
```

**Address Classes:**

**Class A:** 1.0.0.0 to 126.255.255.255
- Large networks
- Default mask: 255.0.0.0 (/8)

**Class B:** 128.0.0.0 to 191.255.255.255
- Medium networks
- Default mask: 255.255.0.0 (/16)

**Class C:** 192.0.0.0 to 223.255.255.255
- Small networks
- Default mask: 255.255.255.0 (/24)

**Private IP Ranges (non-routable on internet):**
```
10.0.0.0 to 10.255.255.255 (10/8)
172.16.0.0 to 172.31.255.255 (172.16/12)
192.168.0.0 to 192.168.255.255 (192.168/16)
```

**Special Addresses:**
```
127.0.0.1 - Loopback (localhost)
0.0.0.0 - All interfaces or no address
255.255.255.255 - Broadcast
```

### Subnet Masks

Divides IP address into network and host portions.

**Example:**
```
IP Address: 192.168.1.100
Subnet Mask: 255.255.255.0
Network: 192.168.1.0
Host: 100
```

**CIDR Notation:**
```
192.168.1.0/24
```

/24 means first 24 bits are network, last 8 bits are hosts.

**Common Subnet Masks:**
```
/8  = 255.0.0.0 = 16,777,214 hosts
/16 = 255.255.0.0 = 65,534 hosts
/24 = 255.255.255.0 = 254 hosts
/25 = 255.255.255.128 = 126 hosts
/26 = 255.255.255.192 = 62 hosts
/27 = 255.255.255.224 = 30 hosts
/28 = 255.255.255.240 = 14 hosts
/29 = 255.255.255.248 = 6 hosts
/30 = 255.255.255.252 = 2 hosts (point-to-point)
```

**Calculate hosts:** 2^(32-prefix) - 2
- Subtract 2 for network address and broadcast address

### IPv6 Addresses

Format: eight groups of four hexadecimal digits

**Example:**
```
2001:0db8:85a3:0000:0000:8a2e:0370:7334
```

**Abbreviated:**
```
2001:db8:85a3::8a2e:370:7334
```

**Why IPv6:**
- IPv4 addresses exhausted
- 340 undecillion addresses available
- Better security (IPsec mandatory)
- No NAT needed

## Ports and Protocols

### TCP vs UDP

**TCP (Transmission Control Protocol):**
- Connection-oriented
- Reliable delivery
- Ordered packets
- Error checking
- Slower than UDP

**Use cases:**
- Web traffic (HTTP/HTTPS)
- File transfer (FTP)
- Email (SMTP)
- SSH connections

**UDP (User Datagram Protocol):**
- Connectionless
- No delivery guarantee
- No ordering
- Minimal overhead
- Faster than TCP

**Use cases:**
- DNS queries
- Video streaming
- VoIP
- Gaming
- Metrics collection (StatsD)

### Common Ports

**Well-Known Ports (0-1023):**

```
20/21 - FTP (File Transfer Protocol)
22 - SSH (Secure Shell)
23 - Telnet (insecure, avoid)
25 - SMTP (Email)
53 - DNS (Domain Name System)
80 - HTTP (Web)
110 - POP3 (Email)
143 - IMAP (Email)
443 - HTTPS (Secure Web)
3306 - MySQL
5432 - PostgreSQL
6379 - Redis
```

**Registered Ports (1024-49151):**

```
3000 - Development servers (React, etc)
5000 - Flask default
8000 - Django default, alternative HTTP
8080 - Alternative HTTP, proxy
8443 - Alternative HTTPS
9090 - Prometheus
3000 - Grafana
9200 - Elasticsearch
5601 - Kibana
27017 - MongoDB
```

**Dynamic/Private Ports (49152-65535):**
- Temporary ports for client connections
- Ephemeral ports

### Checking Ports

**List listening ports:**
```bash
sudo netstat -tulpn
sudo ss -tulpn
```

**Check if port is open:**
```bash
telnet hostname 80
nc -zv hostname 80
```

**Check what is using a port:**
```bash
sudo lsof -i :8080
sudo fuser 8080/tcp
```

## DNS (Domain Name System)

DNS translates domain names to IP addresses.

### DNS Hierarchy

```
. (root)
    |
   .com (TLD - Top Level Domain)
    |
  example.com (domain)
    |
  www.example.com (subdomain)
```

### DNS Record Types

**A Record:**
Maps domain to IPv4 address
```
example.com -> 93.184.216.34
```

**AAAA Record:**
Maps domain to IPv6 address
```
example.com -> 2606:2800:220:1:248:1893:25c8:1946
```

**CNAME Record:**
Alias one domain to another
```
www.example.com -> example.com
```

**MX Record:**
Mail server for domain
```
example.com -> mail.example.com (priority 10)
```

**TXT Record:**
Text information, used for verification
```
example.com -> "v=spf1 include:_spf.google.com ~all"
```

**NS Record:**
Name servers for domain
```
example.com -> ns1.example.com
```

### DNS Commands

**Query DNS:**
```bash
nslookup example.com
dig example.com
host example.com
```

**Detailed DNS query:**
```bash
dig example.com +trace
dig example.com ANY
```

**Reverse DNS lookup:**
```bash
dig -x 8.8.8.8
host 8.8.8.8
```

**Check specific record type:**
```bash
dig example.com A
dig example.com AAAA
dig example.com MX
dig example.com NS
```

### DNS Resolution Process

1. Browser checks local cache
2. OS checks /etc/hosts file
3. OS checks DNS cache
4. Query configured DNS server (e.g., 8.8.8.8)
5. DNS server queries root servers
6. Root servers point to TLD servers
7. TLD servers point to authoritative servers
8. Authoritative server returns IP address

**Linux DNS configuration:**
```bash
cat /etc/resolv.conf
```

Output:
```
nameserver 8.8.8.8
nameserver 8.8.4.4
```

## Network Commands

### ip - Network Configuration

**Show network interfaces:**
```bash
ip addr show
ip a
```

**Show specific interface:**
```bash
ip addr show eth0
```

**Add IP address:**
```bash
sudo ip addr add 192.168.1.100/24 dev eth0
```

**Remove IP address:**
```bash
sudo ip addr del 192.168.1.100/24 dev eth0
```

**Show routing table:**
```bash
ip route show
ip r
```

**Add route:**
```bash
sudo ip route add 10.0.0.0/24 via 192.168.1.1
```

**Show network statistics:**
```bash
ip -s link
```

### ping - Test Connectivity

```bash
ping example.com
ping -c 4 example.com        # Send 4 packets
ping -i 2 example.com        # 2 second interval
```

**What ping shows:**
- Packet loss
- Round-trip time (latency)
- Reachability

### traceroute - Trace Route to Host

```bash
traceroute example.com
```

Shows each hop (router) packets travel through.

**Use case:** Identify where network slowness occurs.

### netstat - Network Statistics

```bash
netstat -tulpn              # Listening ports
netstat -an                 # All connections
netstat -r                  # Routing table
netstat -i                  # Interface statistics
```

### ss - Socket Statistics

Modern replacement for netstat.

```bash
ss -tulpn                   # Listening ports
ss -tan                     # TCP connections
ss -uan                     # UDP connections
ss -o                       # Show timers
```

**Filter by port:**
```bash
ss -tulpn | grep :80
```

### curl - Transfer Data

```bash
curl http://example.com
curl -I http://example.com           # Headers only
curl -X POST http://api.example.com  # POST request
curl -d '{"key":"value"}' http://api.example.com
curl -H "Authorization: Bearer token" http://api.example.com
```

**Test API endpoint:**
```bash
curl -v http://localhost:8080/health
```

### wget - Download Files

```bash
wget http://example.com/file.tar.gz
wget -c http://example.com/file.tar.gz  # Resume download
wget -r http://example.com/             # Recursive download
```

### tcpdump - Packet Analyzer

Capture and analyze network traffic.

```bash
sudo tcpdump -i eth0
sudo tcpdump -i eth0 port 80
sudo tcpdump -i eth0 host 192.168.1.100
sudo tcpdump -i eth0 -w capture.pcap    # Save to file
```

**Read capture file:**
```bash
tcpdump -r capture.pcap
```

## Firewalls

### iptables - Packet Filtering

**List rules:**
```bash
sudo iptables -L -n -v
```

**Allow SSH:**
```bash
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

**Allow HTTP and HTTPS:**
```bash
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

**Block IP address:**
```bash
sudo iptables -A INPUT -s 192.168.1.100 -j DROP
```

**Save rules:**
```bash
sudo iptables-save > /etc/iptables/rules.v4
```

### UFW - Uncomplicated Firewall

Easier frontend for iptables.

**Enable firewall:**
```bash
sudo ufw enable
```

**Allow service:**
```bash
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

**Allow from specific IP:**
```bash
sudo ufw allow from 192.168.1.100
```

**Deny traffic:**
```bash
sudo ufw deny 23/tcp
```

**Show status:**
```bash
sudo ufw status
sudo ufw status numbered
```

**Delete rule:**
```bash
sudo ufw delete 3
```

## Network Configuration Files

### /etc/hosts

Static hostname to IP mapping.

```bash
cat /etc/hosts
```

Example:
```
127.0.0.1   localhost
127.0.1.1   myhostname
192.168.1.100   server1.example.com server1
192.168.1.101   server2.example.com server2
```

**Use case:** Testing before DNS is configured.

### /etc/resolv.conf

DNS server configuration.

```bash
cat /etc/resolv.conf
```

Example:
```
nameserver 8.8.8.8
nameserver 8.8.4.4
search example.com
```

### /etc/network/interfaces

Network interface configuration (Debian/Ubuntu).

Example:
```
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

### Netplan (Modern Ubuntu)

```bash
cat /etc/netplan/01-netcfg.yaml
```

Example:
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

Apply configuration:
```bash
sudo netplan apply
```

## Network Troubleshooting

### Problem: Cannot Connect to Server

**Step 1: Check local connectivity**
```bash
ip addr show
```
Verify IP address assigned.

**Step 2: Check gateway reachable**
```bash
ip route show
ping 192.168.1.1
```

**Step 3: Check DNS**
```bash
cat /etc/resolv.conf
dig example.com
```

**Step 4: Check if port open**
```bash
telnet server.example.com 80
nc -zv server.example.com 80
```

**Step 5: Check firewall**
```bash
sudo iptables -L
sudo ufw status
```

**Step 6: Check service running**
```bash
sudo systemctl status nginx
sudo netstat -tulpn | grep 80
```

### Problem: Slow Network

**Check bandwidth:**
```bash
iftop
speedtest-cli
```

**Check packet loss:**
```bash
ping -c 100 8.8.8.8
```

**Trace route latency:**
```bash
mtr example.com
```

**Check network errors:**
```bash
ip -s link
netstat -i
```

### Problem: DNS Not Resolving

**Check DNS servers:**
```bash
cat /etc/resolv.conf
```

**Test DNS directly:**
```bash
dig @8.8.8.8 example.com
```

**Flush DNS cache:**
```bash
sudo systemd-resolve --flush-caches
```

**Check if DNS service running:**
```bash
sudo systemctl status systemd-resolved
```

## DevOps Networking Scenarios

### Scenario 1: Web Application Architecture

```
Internet
    |
Load Balancer (Public IP)
    |
    +-- Web Server 1 (10.0.1.10:80)
    +-- Web Server 2 (10.0.1.11:80)
    |
Application Servers (10.0.2.0/24)
    |
Database Server (10.0.3.10:5432)
```

**Network requirements:**
- Load balancer has public IP
- Web servers in private subnet, accessible via load balancer
- Application servers only accessible from web servers
- Database only accessible from application servers
- All servers can access internet via NAT gateway

### Scenario 2: Kubernetes Networking

**Pod-to-Pod communication:**
- Each pod gets unique IP
- Pods communicate directly without NAT
- Network plugin (CNI) handles routing

**Service networking:**
- ClusterIP: Internal service (10.96.0.0/12)
- NodePort: Accessible on each node (30000-32767)
- LoadBalancer: Cloud load balancer with external IP

**Example:**
```
Pod: 10.244.1.5
Service: 10.96.0.10:80 -> Pod:8080
External: LoadBalancer -> Service -> Pod
```

### Scenario 3: Docker Networking

**Bridge network (default):**
```bash
docker network create myapp-network
docker run --network myapp-network --name web nginx
docker run --network myapp-network --name db mysql
```

Containers can communicate using names:
```bash
# From web container
ping db
curl http://db:3306
```

**Port mapping:**
```bash
docker run -p 8080:80 nginx
```

Host port 8080 maps to container port 80.

## Best Practices

1. **Use private IPs for internal communication**
2. **Implement firewall rules (least privilege)**
3. **Use DNS names instead of IP addresses**
4. **Monitor network traffic and performance**
5. **Document network architecture**
6. **Use VPN for remote access**
7. **Implement security groups in cloud**
8. **Regular security audits**

## Practice Exercises

1. Configure static IP on network interface
2. Set up local DNS with /etc/hosts
3. Create firewall rules allowing only SSH and HTTP
4. Diagnose connectivity issue between two servers
5. Capture HTTP traffic with tcpdump
6. Test API endpoint with curl
7. Trace route to popular website
8. Configure routing between two networks

## Next Steps

Networking knowledge is essential for troubleshooting distributed systems. Practice these commands regularly.

Continue to: `05-package-management.md`
