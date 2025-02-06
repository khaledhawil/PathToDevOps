
Creating a partition, formatting it with a filesystem, mounting it, and adding it to `/etc/fstab` for automatic mounting at boot are common tasks in Linux. Below are the step-by-step instructions to accomplish this. 
 
### Step 1: Create a Partition 
 
1. **Open a Terminal**. 
2. **Identify the Disk**: First, identify the disk where you want to create the partition. You can list your disks using:
sudo fdisk -l
Look for your target disk (e.g., `/dev/sdb`). 
 
3. **Use `fdisk` to Create a New Partition**:
sudo fdisk /dev/sdb
Replace `/dev/sdb` with your actual disk. 
 
   - Type `n` to create a new partition. 
   - Choose `p` for a primary partition or `e` for an extended partition. 
   - Specify the partition number (if prompted). 
   - Specify the starting and ending sectors (you can press Enter to accept the defaults). 
   - Type `w` to write the changes and exit. 
 
### Step 2: Format the Partition with a Filesystem 
 
1. **Format the New Partition**: After creating the partition (e.g., `/dev/sdb1`), format it with a filesystem. For example, to format it as `ext4`:
```bash
sudo mkfs.ext4 /dev/sdb1
```
Replace `/dev/sdb1` with your actual new partition. 
 
### Step 3: Mount the Partition 
 
1. **Create a Mount Point**: Decide where you want to mount the new partition, for example, `/mnt/mydata`:
sudo mkdir /mnt/mydata
2. **Mount the Partition**:
sudo mount /dev/sdb1 /mnt/mydata
Replace `/dev/sdb1` with your partition and `/mnt/mydata` with your desired mount point. 
 
3. **Verify the Mount**: You can check if the partition is mounted successfully:
df -h
### Step 4: Update `/etc/fstab` for Automatic Mounting 
Get the UUID of the Partition: It is recommended to use the UUID for mounting in /etc/fstab. Get the UUID with:
```bash
sudo blkid /dev/sdb1
```
Note the UUID value returned.
Edit /etc/fstab: Open the /etc/fstab file in a text editor (e.g., nano):
```bash
sudo nano /etc/fstab
UUID=your-uuid-here  /mnt/mydata  ext4  defaults  0  2
```

### Step 5. Test the /etc/fstab Entry: 
To test if the /etc/fstab entry is correct without rebooting, you can use:
```bash
sudo mount -a
```
/media/$USER/mydisk

## Summary of Commands

```bash
sudo fdisk /dev/sdb
# Follow prompts to create a new partition
man -s5 fstab
sudo mkfs.ext4 /dev/sdb1  # Format the new partition

sudo mkdir /mnt/mydata    # Create a mount point
sudo mount /dev/sdb1 /mnt/mydata  # Mount the partition

sudo blkid /dev/sdb1      # Get UUID
sudo nano /etc/fstab      # Edit fstab
# Add the line: UUID=your-uuid-here  /mnt/mydata  ext4  defaults  0  2
sudo mount -a             # Test fstab entry
```


/dev/sdb2: UUID="049b1b65-0b19-43d3-804a-c0e7c4766642" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="efdbd85f-02"