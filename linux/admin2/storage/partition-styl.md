- In Linux, the term "partition style" typically refers to how disk partitions are organized and managed on a storage device. 
- The two most common partitioning schemes used in Linux are:

## MBR (Master Boot Record):
- `MBR` is an older partitioning scheme that has been around since the early 1980s.
- It supports disks up to 2 TB in size and allows for a maximum of four primary partitions. 
- Alternatively, you can create three primary partitions and one extended partition, which can contain multiple logical partitions.
- MBR stores partition information in the first sector of the disk.

## GPT (GUID Partition Table):
- GPT is a newer partitioning scheme that is part of the UEFI (Unified Extensible Firmware Interface) specification.
- It supports much larger disks (over 2 TB) and allows for a virtually unlimited number of partitions (though most operating systems impose a limit, typically 128).
- GPT stores partition information in multiple locations on the disk for redundancy and includes a protective MBR to prevent older systems from misreading the disk.

### Choosing a Partition Style
- 1. Use MBR if you are working with older hardware or operating systems that do not support GPT.
- 2. Use GPT for modern systems, especially if you need to manage large disks or require more than four partitions.
### Managing Partitions
- You can manage disk partitions in Linux using various tools, including:

- fdisk: A command-line utility for managing MBR partitions.
- gdisk: A command-line utility for managing GPT partitions.
- parted: A more flexible command-line tool that supports both MBR and GPT.
- gparted: A graphical partition editor that provides a user-friendly interface for managing partitions.


# adding hard disk to linux in vmware without reboot the system

- if you want to detect a newly added hard disk in a VMware Linux virtual machine without rebooting, you can follow these steps:

## Steps to Detect the New Hard Disk
- 1. Rescan the SCSI Bus:
If the new hard disk is a SCSI disk, you can rescan the SCSI bus to detect the new disk. You can do this using the following command:
```bash
echo "- - -" | sudo tee /sys/class/scsi_host/host*/scan
```
This command tells all SCSI hosts to rescan their buses for new devices.

- 2. Using lsblk or fdisk:
After rescanning, you can check if the new disk has been detected using commands like:
```bash
lsblk
fdisk -l
```
These commands will list all block devices and partitions, allowing you to see if the new disk appears.

### Check /dev Directory:
You can also check the /dev directory for new disk entries. Typically, new disks will appear as /dev/sdX (where X is a letter representing the disk).
```bash
ls /dev/sd*
```
If the new disk is detected, you should see a new entry in the list.

- 4 Using dmesg:
You can view kernel messages to see if the new disk was detected. Use the following command
```bash
dmesg | grep -i "scsi"
dmesg | grep -i "sd"
```
This will show you messages related to SCSI disks, including any new disks that were detected.

# Example Scenario
- 1. Add a New Disk: Assume you have added a new virtual disk to your VM through the VMware interface.

- 2. Rescan the SCSI Bus: Run the rescan command:
```bash
echo "- - -" | sudo tee /sys/class/scsi_host/host*/scan
```
- 3. Check for New Disk:
```bash
   lsblk
```
You should see the new disk listed, for example, as /dev/sdb.

# How managing disk partitions.
`fdisk` is a command-line utility in Linux used for managing disk partitions. It allows users to create, delete, modify, and view disk partitions on hard drives and other storage devices. `fdisk` primarily works with MBR (Master Boot Record) partition tables, but there are other tools like `gdisk` for GPT (GUID Partition Table) disks. 
 
### Basic Usage of `fdisk` 
 
1. **Open `fdisk`**: 
   To use `fdisk`, you need to specify the disk you want to work with. For example, to work with `/dev/sda`, you would use:
sudo fdisk /dev/sda
Replace `/dev/sda` with the appropriate device name for your disk. 
 
2. **View Current Partitions**: 
   Once you are in the `fdisk` prompt, you can view the current partitions by typing:
p
This will print the partition table of the specified disk. 
 
3. **Creating a New Partition**: 
   To create a new partition, follow these steps: 
   - Type `n` to create a new partition. 
   - Choose whether it will be a primary (p) or extended (e) partition. 
   - Specify the partition number (if prompted). 
   - Specify the starting and ending sectors (or sizes). 
 
4. **Deleting a Partition**: 
   To delete an existing partition: 
   - Type `d`. 
   - Specify the partition number you want to delete. 
 
5. **Changing a Partition Type**: 
   You can change the type of a partition by: 
   - Typing `t`. 
   - Specifying the partition number. 
   - Entering the hex code for the new partition type. 
 
6. **Writing Changes**: 
   After making changes, you must write them to the disk: 
   - Type `w` to write the changes and exit. 
   - If you want to exit without saving changes, type `q`. 
 
7. **Exiting `fdisk`**: 
   If you want to exit without making any changes, you can simply type `q`. 

8. **check if is the partition is created**
```bash
lsblk
partprobe  /dev/sdb
```


# How to create a new partition

```bash


