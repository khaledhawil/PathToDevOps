# Here will generate a key to connect local repo with github.com repo 

- 1. first step Create a key to connect local repo with github repo : 
   - An SSH key is a secure way to connect to GitHub without needing to enter your username and password every time.
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```
##### Explanation of this command 
- `ssh-keygen` : This command generates a new SSH key.
- `-t rsa` : Specifies the type of key to create (RSA is a common type).
- `-b 4096`: This specifies the number of bits in the key (4096 is more secure).
- `-C &quot;your_email@example.com"`: This adds a label (your email) to the key for identification.

- What to do: 
     - After you run the command, you’ll be prompted to choose a location to save the key. 
     - Press Enter to accept the default location (~/.ssh/id_rsa).
     - You may also be asked to enter a passphrase for extra security. 
     - You can either enter a passphrase or just press Enter twice to skip it.

## 2. Add the SSH Key to the SSH Agent
### 1. Start the SSH Agent
Command:
```bash
eval "$(ssh-agent -s)"
```
What it does: This command starts the SSH agent, which will manage your SSH keys.
### 2. Add Your SSH Key to the SSH Agent
Command:
```bash
ssh-add ~/.ssh/id_rsa
```
What it does: This command adds your newly created SSH key to the SSH agent, allowing it to be used for authentication.
### 3. Add the SSH Key to GitHub 
1. Copy Your SSH Key
Command:
```bash
cat ~/.ssh/id_rsa.pub
```
What it does: This command displays the contents of your public SSH key file.
2. Go to GitHub and navigate to your account settings
3. Click on SSH and GPG keys
4. Click on New SSH key
5. Paste your public SSH key into the key field
6. Add a title for the key (optional)
7. Click on Add SSH key
### 4. Verify Your SSH Key
Command:
```bash
ssh -T git@github.com
```
What it does: This command tests your SSH connection to GitHub and verifies that your SSH key is working
### 5. Add the Remote Repository
command:
```bash
git remote add origin git@github.com:your_username/your_repository.git
```
What it does: This command adds a new remote repository to your local repository, allowing you to push and pull changes from the remote repository.

### 6. Check if It’s Added
Command:
```bash
git remote -v
```
What it does: This command displays the list of remote repositories associated with your local repository.
### 7. Push Your Changes
Command:
```bash
git push -u origin master
```
What it does: This command pushes your local changes to the remote repository, and sets the upstream tracking


### Displaying Git User Configuration 
 
1. **Check Global User Configuration**: 
   This command shows the username and email that Git uses for all repositories on your system (unless overridden by local settings).

```bash
git config --global user.name
git config --global user.email
```
2. ***Display All Configurations:***
     If you want to see all the Git configuration settings (both global and local), you can use:
```bash
git config --list
```
