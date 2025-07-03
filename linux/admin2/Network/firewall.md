### What is a Firewall? 
 
- A firewall is a security tool that monitors and controls incoming and outgoing network traffic based on predetermined security rules. 
- Think of it as a gatekeeper for your computer's network connections, allowing only the traffic you trust while blocking everything else. 
 
### Types of Firewalls in Linux 
 
1. **iptables**: The traditional firewall tool in Linux, allowing you to set complex rules for network traffic. 
2. **firewalld**: A more user-friendly firewall management tool that uses zones and services to simplify firewall management. 
3. **nftables**: The modern replacement for iptables, designed to simplify and unify the firewall ruleset. 
 
### Basic Concepts 
 
- **Rules**: Conditions that determine whether to allow or block traffic. 
- **Chains**: Groups of rules that packets pass through. Common chains include: 
  - **INPUT**: Incoming traffic to your machine. 
  - **OUTPUT**: Outgoing traffic from your machine. 
  - **FORWARD**: Traffic being routed through your machine. 
   
- **Zones**: In firewalld, zones define the level of trust for network connections. 
 
### Common Commands 
 
#### Using iptables 
 
1. **View Current Rules**:
sudo iptables -L
This command lists all current rules in the default filter table. 
 
2. **Allow Incoming Traffic on a Specific Port (e.g., HTTP on port 80)**:
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
- `-A INPUT`: Append a rule to the INPUT chain. 
   - `-p tcp`: Specify the protocol (TCP). 
   - `--dport 80`: Target port (80 for HTTP). 
   - `-j ACCEPT`: Action to take (accept the traffic). 
 
3. **Block Incoming Traffic on a Specific Port (e.g., Telnet on port 23)**:
sudo iptables -A INPUT -p tcp --dport 23 -j DROP
4. **Delete a Rule**:
sudo iptables -D INPUT -p tcp --dport 23 -j DROP
5. **Save Rules** (so they persist after a reboot):
sudo iptables-save > /etc/iptables/rules.v4
#### Using firewalld 
 
1. **Start and Enable firewalld**:
```bash
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

```
2. **Check the Status**:
```bash
sudo firewall-cmd --state
```
3. **View Active Zones**:
```bash
sudo firewall-cmd --get-active-zones
```
4. **Allow a Service (e.g., HTTP)**:
```bash
sudo firewall-cmd --zone=public --add-service=http --permanent
```
- `--permanent`: Makes the change persistent across reboots.
 
5. **Reload firewalld to Apply Changes**:
```bash
sudo firewall-cmd --reload
```
6. **Block a Port (e.g., Telnet on port 23)**

3. **View Active Zones**:
```bash
sudo firewall-cmd --get-active-zones
```
4. **Allow a Service (e.g., HTTP)**:
```bash
sudo firewall-cmd --zone=public --add-service=http --permanent
```
- `--permanent`: Makes the change persistent across reboots. 
 
5. **Reload firewalld to Apply Changes**:
```bash
sudo firewall-cmd --reload
```
6. **Block a Port (e.g., Telnet on port 23)**:
```bash
sudo firewall-cmd --zone=public --add-port=23/tcp --permanent
sudo firewall-cmd --reload
```
#### Using nftables 
```bash 
1. #View Current Rules#:
sudo nft list ruleset
2. #Add a Rule to Allow HTTP#:
sudo nft add rule ip filter input tcp dport 80 accept
3. #Add a Rule to Drop Telnet#:
sudo nft add rule ip filter input tcp dport 23 drop
4. #Delete a Rule#:
sudo nft delete rule ip filter input handle <handle_number>
```
### Summary 
 
- **iptables** is powerful but can be complex for beginners. 
- **firewalld** is easier to use, especially for those new to firewalls. 
- **nftables** is the modern approach to firewall management. 
 
### Best Practices 
 
1. **Start with a Default Deny Policy**: Block everything by default and only allow what is necessary.
2. **Use Zones**: Organize your firewall rules into zones for better management.
3. **Regularly Review and Update Rules**: Ensure your firewall rules are up-to-date and reflect your current security needs.
4. **Use Services Instead of Ports**: Where possible, use service names instead of port numbers to make your rules more readable.
5. **Test Changes**: Before applying changes, test them in a non-production environment to ensure they work as expected.
 
### The defference between `block` and `drop`
 
- **Block**: The packet is dropped and an ICMP message is sent back to the sender indicating that the packet was blocked.
- **Drop**: The packet is silently dropped without any notification to the sender.
 
