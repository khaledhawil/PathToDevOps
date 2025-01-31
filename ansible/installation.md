# Install ansible on ubuntu and install  one vm by multipass with config file  to use ssh when connect 

### Install Ansible on the Host Machine
For Ubuntu/Debian:
You can install Ansible using apt:
```bash
sudo apt update
sudo apt install ansible
```

#### Connect Ansible to the Multipass Instance
Get the IP Address of the Instance:
You need to find the IP address of the Multipass instance you created. Run the following command:
```bash
multipass info
multipass list
```
### Configure SSH Access:
```bash
ssh-keygen
```
- and copy the public key

#### Create Yaml file fot the multipass vm:
```yaml
users:
  - default 
  - name: ansibleadmin
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys: 
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1h5gL8tU/weqcWwxU2wLQp7Ub28tJZDNUC2bPSD86mpyf6b563ZGJHU+oNBhKp0MYTobtPfOq342aaUxJV/OwtmplbXDx6My3MnSgApk3OiVmHDBWxpMtDJZ0MUDF5EEkZmv3Cr2H+ptO7xleAW578UQGB90AMkjc/BCpK+kd+36/pYuRxoweg2u7ucOtU+822MO7qtaZ2c8pzxiaqVhxAS9lAkW83RgAq5ZGx/vdJUl62bGsa9znX51PM8LNGD19fv27aT4WWcRCcx0IzrUG36JPc8jVhs667Mw/ddO9X4LCHfKYcyiclr2DPmSf74Q0qITEVqwB7aus7D0EDXzd9dabvG1YwqaBQFKL9jY63OX3y04p1BPaccdjAh+yWFJkqtkuoatbxvTlq54UKZa8ZwWuKEi/HTfFv1GTEPHY2noCWvChoTVTCIwtWyM3oonGW0c4rrYYJvxPXtoQWWvzMKLMVlRESjjGRKnYcwgy+rSbsDIN05yaEBm9dHm86BR9iynVnvsYb9je3VqzHXWU+DqA29rEXyuz3R4btyZ9zmuhMCOcuOiL4C0rajNO0wHlAneZGeM7hDKuA/5OkXrgWrc4TczfGV37OUhw1ueOtdlvH2VQ3Kgm02ZUuZ5zZuVCaruIov94ciFiOYG4IWiCNqPw3oFsERCldAmNqdzONw== khaledhawil91@gmail.com"
```

- Apply this file by this command:
```bash
multipass launch  -n ansiblemain  --cloud-init   ansible_multipass.yaml
```
 