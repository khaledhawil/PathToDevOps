# to add user and give him sudo permissions:
```bash
sudo useradd ansible # this to add user 
echo pass | sudo passwd --stdin ansible  # this to give him password "pass" 
sudo vim /etc/sudoers.d/ansible  # this to make the ansible user  uses sudo command  --> create file for the ansible user in /etc/sudoers.d 
sudo su ansible
sudo cat /etc/sudoers
ansible ALL=(ALL)  NOPASSWD: ALL

```

khaledhawil91@gmail.com
30104161600339

## Note For ssh:

```bash
vim .ssh/config
Host control
     HostName 54.81.6.223
     IdentityFile /home/spider/Desktop/devOpsPath/k8s.pem
     User ec2-user
     StrictHostKeyChecking no
Host node1
     HostName 18.207.201.181
     IdentityFile /home/spider/Desktop/devOpsPath/k8s.pem
     User ec2-user
     StrictHostKeyChecking no
Host node2
     HostName 54.145.93.118
     IdentityFile /home/spider/Desktop/devOpsPath/k8s.pem
     User ubuntu
     StrictHostKeyChecking no
```


# What is `stdin` in Linux?

In Linux, stdin (standard input) is a way for a program to receive input. Think of it as the program’s "keyboard" where it listens for user input or data from another command.

### Simple Explanation:
- When you type something in the terminal and press Enter, it goes to stdin.
- Programs like cat, grep, and wc read from stdin unless you give them a file to read from.
- You can redirect the output of a command to stdin using the pipe (`|`) symbol.
## Ex
```bash
echo pass | sudo passwd --stdin ansible 
```
### Explanation (Step by Step):
1. `echo pass` will output the word "pass" to the terminal.
2. The `|` symbol is used to redirect the output of the command on the left side of the pipe 

# Configure vim to be nice with yaml file 
```bash
vim /etc/vim/vimrc
set cursorcolumn
autocmd  FileType yaml  setlocal ai ts=2 sw=2 et
```
