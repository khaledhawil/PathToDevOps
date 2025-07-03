##### ACL stands for Access Control List in Linux. It’s a way to manage permissions for files and directories more flexibly than the standard owner/group/other model.

## Here's a simple breakdown:

- 1. Permissions: Normally, Linux uses three types of permissions: read, write, and execute. These permissions can be set for three categories: the file owner, the group, and everyone else (others).


- 2. ACLs: With ACLs, you can specify permissions for multiple users or groups beyond just the owner and the group. This means you can give different permissions to different users for the same file or directory.


- 3. Usage: For example, if you have a file and you want to allow User A to read and write it, User B to only read it, and keep the default permissions for everyone else, you can do that easily with ACLs.


- 4. Commands: You typically use commands like `setfacl` to set ACLs and `getfacl` to view them.


## How to use `setfacl` in Linux:


The `setfacl` command in Linux is used to set Access Control Lists (ACLs) on files and directories, which allows for more granular permission management than the traditional owner/group/other model. Here’s a guide on how to use `setfacl` effectively. 
 
### Basic Syntax 
 
The basic syntax for the `setfacl` command is:
setfacl [options] [acl] file
### Common Options 
 
- `-m`: Modify the ACL. 
- `-x`: Remove an ACL entry. 
- `-b`: Remove all ACL entries (reset to default permissions). 
- `-d`: Set default ACLs (for new files created in a directory). 
- `-R`: Apply changes recursively to directories and their contents. 
 
### Examples 
 
1. **Set ACL for a User** 
 
   To give a specific user (e.g., `john`) read and write permissions on a file (e.g., `example.txt`):
```bash
setfacl -m u:john:rw example.txt
```
2. **Set ACL for a Group** 
 
   To give a specific group (e.g., `developers`) read and execute permissions on a directory (e.g., `project_dir`):
```bash
setfacl -m g:developers:rx project_dir
```
3. **Set Default ACL for a Directory** 
 
   To set default permissions for new files created in a directory (e.g., `shared_dir`), so that a user (e.g., `john`) has read and write permissions:
```bash
setfacl -d -m u:john:rw shared_dir
```
4. **Remove an ACL Entry** 
 
   To remove the ACL for a user (e.g., `john`) on a file (e.g., `example.txt`):
```bash
setfacl -x u:john example.txt
```
5. **Remove All ACL Entries** 
 
   To remove all ACL entries from a file (e.g., `example.txt`):
```bash
setfacl -b example.txt
```
6. **Set ACL Recursively** 
 
   To apply ACL changes recursively to a directory and all its contents:
```bash
setfacl -R -m u:john:rw project_dir
```
### Viewing ACLs 
 
To view the current ACLs set on a file or directory, use the
￼ Stop Generating
```bash
getfacl filename    
```
### Note 
 
- ACLs are not supported on all file systems. They are commonly supported on ext2, ext3, ext4, and XFS file systems.
- ACLs can be complex and may require careful management to avoid unintended permission issues.
 
By using `setfacl` and `getfacl`, you can manage and view ACLs on your Linux system, providing additional flexibility in controlling access to your files and directories. 



----------------------------
# ACL Settings
## User ACL Settings
user: rwx

## Group ACL Settings
group: rw

## Other ACL Settings
other: no access

# IMPORTANT
## Changing Group Permissions
Changing group permissions on a file with an ACL by using chmod does not change the group owner permissions, but does change the ACL mask. Use `setfacl -m g::perms file`  if the intent is to update the file's group owner permissions.

## ACL Mask
The ACL mask defines the maximum permissions that you can grant to named users, the group owner, and named groups. It does not restrict the permissions of the file owner or other users. All files and directories that implement ACLs will have an ACL mask.

## Avoiding Mask Recalculation
To avoid the mask recalculation, use the -n option or include a mask setting (-m). For example:
setfacl -n -m "u:omar1:rw" /tmp/f90

# ACL Permission Precedence
When determining whether a process (a running program) can access a file, file permissions and ACLs are applied as follows:

1. If the process is running as the user that owns the file, then the file's user ACL permissions apply.
2. If the process is running as a user that is listed in a named user ACL entry, then the named user ACL permissions apply (as long as it is permitted by the mask).
3. If the process is running as a group that matches the group owner of the file, or as a group with an explicitly named group ACL entry, then the matching ACL permissions apply (as long as it is permitted by the mask).
4. Otherwise, the file's other ACL permissions apply.

# Copying ACLs
## Copying ACL from One File to Another
getfacl file1 | setfacl --set-file=- file2

## Copying Access ACL into Default ACL
getfacl --access dir | setfacl -d -M- dir

# Recursive ACL Modifications
When setting an ACL on a directory, use the -R option to apply the ACL recursively. Remember to use the "X" (capital X) permission with recursion so that files with the execute permission set retain the setting and directories get the execute permission set to allow directory search.

# Deleting Default ACL Entries
Delete a default ACL the same way that you delete a standard ACL, prefacing with d:, or use the -d option. For example:
setfacl -x d:u:name directory
To delete all default ACL entries on a directory, use setfacl -k directory
