# write here bash commands to create swapfile  and make it and put it in fstab 
# to make it persistent across reboots
#
```bash
# Create swapfile
sudo fallocate -l 4G /swapfile
# or U can Use Uuse
sudo dd if=/dev/zero of=/swapfile   bs=4G count=1
#
# Make swapfile
sudo chmod 600 /swapfile
#
# Make swapfile
sudo mkswap /swapfile
#
# Activate swapfile
sudo swapon /swapfile
#
# Add swapfile to fstab
sudo echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
#
# Check swap
sudo swapon --show
#
# Check swap status
sudo cat /proc/
#
# Check swap status
sudo cat /proc/swaps
```
# Create Partition and make it a swap
```bash
sudo swapon --show
sudo fdisk -l
sudo fdisk /dev/sdX
sudo mkswap /dev/sdXn
sudo swapon /dev/sdXn
sudo swapon --show
sudo swapoff /dev/sdXn
sudo swapon --show
sudo nano /etc/fstab
/dev/sdXn none swap sw 0 0
```

