# Git and GitHub Connection Guide - Complete Setup

## Table of Contents
1. [Overview](#overview)
2. [SSH Key Setup (Recommended)](#ssh-key-setup-recommended)
3. [HTTPS with Personal Access Token](#https-with-personal-access-token)
4. [Repository Connection Methods](#repository-connection-methods)
5. [Verification and Testing](#verification-and-testing)
6. [Troubleshooting Common Issues](#troubleshooting-common-issues)
7. [Multiple GitHub Accounts Setup](#multiple-github-accounts-setup)
8. [Security Best Practices](#security-best-practices)

## Overview

This guide shows you how to securely connect your local Git repository to GitHub using two main methods:
1. **SSH Keys** (Recommended for security and convenience)
2. **HTTPS with Personal Access Token** (Alternative method)

### Why Use SSH Keys?
- **Security**: No password needed for each operation
- **Convenience**: Automatic authentication
- **Speed**: Faster than HTTPS authentication
- **Safety**: Keys can be easily revoked if compromised

## SSH Key Setup (Recommended)

### Step 1: Check for Existing SSH Keys

```bash
# Check if SSH keys already exist
ls -la ~/.ssh

# Look for files like:
# id_rsa and id_rsa.pub (RSA keys)
# id_ed25519 and id_ed25519.pub (Ed25519 keys)
```

If you see existing keys, you can either:
- Use the existing key (skip to Step 3)
- Generate a new key (continue with Step 2)

### Step 2: Generate New SSH Key

#### Option A: Ed25519 Key (Recommended - More Secure)
```bash
# Generate Ed25519 SSH key (recommended)
ssh-keygen -t ed25519 -C "your.email@example.com"

# When prompted:
# 1. Press Enter to accept default file location (~/.ssh/id_ed25519)
# 2. Enter a secure passphrase (recommended) or press Enter twice to skip
```

#### Option B: RSA Key (For Older Systems)
```bash
# Generate RSA SSH key (for systems that don't support Ed25519)
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"

# When prompted:
# 1. Press Enter to accept default file location (~/.ssh/id_rsa)
# 2. Enter a secure passphrase (recommended) or press Enter twice to skip
```

#### Understanding the Command
- `ssh-keygen`: Command to generate SSH keys
- `-t ed25519`: Type of key (Ed25519 is more secure than RSA)
- `-t rsa -b 4096`: RSA type with 4096-bit key size
- `-C "email"`: Comment to identify the key (usually your email)

### Step 3: Add SSH Key to SSH Agent

The SSH agent manages your keys and handles authentication automatically.

```bash
# Start SSH agent (if not already running)
eval "$(ssh-agent -s)"

# Add your SSH private key to the agent
ssh-add ~/.ssh/id_ed25519

# For RSA key:
ssh-add ~/.ssh/id_rsa

# For macOS, add to keychain (prevents re-entering passphrase)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

#### Make SSH Agent Start Automatically (Linux)
Add to your `~/.bashrc` or `~/.zshrc`:
```bash
# Auto-start SSH agent
if [ -z "$SSH_AUTH_SOCK" ]; then
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
fi
```

### Step 4: Copy Public Key to Clipboard

```bash
# Display and copy public key (Ed25519)
cat ~/.ssh/id_ed25519.pub

# For RSA key:
cat ~/.ssh/id_rsa.pub

# Copy to clipboard (Linux with xclip)
xclip -selection clipboard < ~/.ssh/id_ed25519.pub

# Copy to clipboard (macOS)
pbcopy < ~/.ssh/id_ed25519.pub

# Copy to clipboard (Windows Git Bash)
clip < ~/.ssh/id_ed25519.pub
```

The output will look like:
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGx... your.email@example.com
```

### Step 5: Add SSH Key to GitHub

1. **Go to GitHub**: Open https://github.com in your browser
2. **Navigate to SSH Settings**: 
   - Click your profile picture (top right)
   - Select "Settings"
   - Click "SSH and GPG keys" in the left sidebar
3. **Add New Key**:
   - Click "New SSH key" button
   - **Title**: Give it a descriptive name (e.g., "My Laptop", "Work Computer")
   - **Key type**: Choose "Authentication Key"
   - **Key**: Paste your public key from Step 4
   - Click "Add SSH key"
4. **Confirm**: Enter your GitHub password if prompted

### Step 6: Test SSH Connection

```bash
# Test connection to GitHub
ssh -T git@github.com

# Expected output:
# Hi username! You've successfully authenticated, but GitHub does not provide shell access.

# If you see this message, SSH is working correctly!
```

#### Troubleshooting SSH Connection
If the test fails, try:

```bash
# Test with verbose output to see what's happening
ssh -vT git@github.com

# Check if SSH agent is running and has your key
ssh-add -l

# Force SSH to use specific key
ssh -i ~/.ssh/id_ed25519 -T git@github.com
```

### Step 7: Configure Git to Use SSH

```bash
# Set up Git user information (if not already done)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify configuration
git config --global --list
```

## HTTPS with Personal Access Token

If you prefer HTTPS over SSH, you'll need a Personal Access Token since GitHub no longer accepts passwords.

### Step 1: Create Personal Access Token

1. **Go to GitHub**: https://github.com
2. **Navigate to Token Settings**:
   - Click your profile picture → Settings
   - Click "Developer settings" (bottom of left sidebar)
   - Click "Personal access tokens" → "Tokens (classic)"
3. **Generate New Token**:
   - Click "Generate new token (classic)"
   - **Note**: Give it a descriptive name
   - **Expiration**: Set appropriate expiration (90 days, 1 year, etc.)
   - **Scopes**: Select permissions:
     - `repo` (full repository access)
     - `workflow` (if using GitHub Actions)
     - `write:packages` (if using GitHub Packages)
4. **Copy Token**: Save it securely (you won't see it again!)

### Step 2: Use Token for Authentication

```bash
# Clone repository with HTTPS
git clone https://github.com/username/repository.git

# When prompted for credentials:
# Username: your-github-username
# Password: your-personal-access-token (NOT your GitHub password!)
```

### Step 3: Store Credentials (Optional)

```bash
# Store credentials permanently (less secure)
git config --global credential.helper store

# Store credentials temporarily (15 minutes default)
git config --global credential.helper cache

# Store credentials for specific time (1 hour)
git config --global credential.helper 'cache --timeout=3600'
```

#### Using Credential Manager (Windows)
```bash
# Use Windows Credential Manager
git config --global credential.helper manager-core
```

#### Using Keychain (macOS)
```bash
# Use macOS Keychain
git config --global credential.helper osxkeychain
```

## Repository Connection Methods

### Method 1: Clone Existing Repository

#### With SSH:
```bash
# Clone with SSH (recommended)
git clone git@github.com:username/repository.git
cd repository

# Verify remote URL
git remote -v
# Output should show: git@github.com:username/repository.git
```

#### With HTTPS:
```bash
# Clone with HTTPS
git clone https://github.com/username/repository.git
cd repository

# Verify remote URL
git remote -v
# Output should show: https://github.com/username/repository.git
```

### Method 2: Connect Existing Local Repository

#### Add Remote Repository:
```bash
# Navigate to your local repository
cd /path/to/your/project

# Initialize Git (if not already done)
git init

# Add remote with SSH
git remote add origin git@github.com:username/repository.git

# Or add remote with HTTPS
git remote add origin https://github.com/username/repository.git

# Verify remote was added
git remote -v
```

#### Change Existing Remote URL:
```bash
# Change from HTTPS to SSH
git remote set-url origin git@github.com:username/repository.git

# Change from SSH to HTTPS
git remote set-url origin https://github.com/username/repository.git

# Verify change
git remote -v
```

### Method 3: First Push to New Repository

```bash
# Create initial commit (if repository is empty)
echo "# My Project" >> README.md
git add README.md
git commit -m "Initial commit"

# Set main branch (if using older Git version)
git branch -M main

# Add remote origin
git remote add origin git@github.com:username/repository.git

# Push and set upstream tracking
git push -u origin main

# Future pushes can use just:
git push
```

## Verification and Testing

### Test Repository Connection

```bash
# Check remote repositories
git remote -v

# Test fetch (download latest changes without merging)
git fetch origin

# Test push (upload your changes)
git push origin main

# Test pull (download and merge changes)
git pull origin main
```

### Complete Workflow Test

```bash
# 1. Make a test change
echo "Test connection" >> test.txt
git add test.txt
git commit -m "Test GitHub connection"

# 2. Push changes
git push origin main

# 3. Verify on GitHub website
# Go to your repository on GitHub and confirm the file appears

# 4. Clean up test file
git rm test.txt
git commit -m "Remove test file"
git push origin main
```

## Troubleshooting Common Issues

### Issue 1: Permission Denied (SSH)

```bash
# Error: Permission denied (publickey)

# Solutions:
# 1. Check SSH agent
ssh-add -l

# 2. Add key to agent
ssh-add ~/.ssh/id_ed25519

# 3. Test with verbose output
ssh -vT git@github.com

# 4. Check file permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### Issue 2: Authentication Failed (HTTPS)

```bash
# Error: Authentication failed

# Solutions:
# 1. Use Personal Access Token (not password)
# 2. Update stored credentials
git config --global --unset credential.helper
git config --global credential.helper store

# 3. Clear cached credentials
git credential-manager-core erase
```

### Issue 3: Remote Already Exists

```bash
# Error: remote origin already exists

# Solutions:
# 1. Remove existing remote
git remote remove origin

# 2. Add new remote
git remote add origin git@github.com:username/repository.git

# Or change existing remote URL
git remote set-url origin git@github.com:username/repository.git
```

### Issue 4: SSH Host Key Verification Failed

```bash
# Add GitHub's SSH keys to known hosts
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts

# Or remove old host key and reconnect
ssh-keygen -R github.com
ssh -T git@github.com
```

## Multiple GitHub Accounts Setup

If you need to work with multiple GitHub accounts, you can set up different SSH keys and configurations.

### Step 1: Generate Keys for Each Account

```bash
# Generate key for personal account
ssh-keygen -t ed25519 -C "personal@email.com" -f ~/.ssh/id_ed25519_personal

# Generate key for work account
ssh-keygen -t ed25519 -C "work@company.com" -f ~/.ssh/id_ed25519_work
```

### Step 2: Create SSH Config File

```bash
# Create or edit SSH config
vim ~/.ssh/config

# Add configuration for each account:
# Personal GitHub account
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# Work GitHub account
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
```

### Step 3: Add Keys to SSH Agent

```bash
ssh-add ~/.ssh/id_ed25519_personal
ssh-add ~/.ssh/id_ed25519_work
```

### Step 4: Add Public Keys to Respective GitHub Accounts

Follow Step 5 from the main SSH setup, adding each public key to its respective GitHub account.

### Step 5: Clone Repositories with Correct Host

```bash
# Personal repository
git clone git@github.com:personal-username/repository.git

# Work repository
git clone git@github-work:work-username/repository.git
```

### Step 6: Configure Git User per Repository

```bash
# In personal repository
git config user.name "Personal Name"
git config user.email "personal@email.com"

# In work repository
git config user.name "Work Name"
git config user.email "work@company.com"
```

## Security Best Practices

### SSH Key Security

```bash
# 1. Use Ed25519 keys (more secure than RSA)
ssh-keygen -t ed25519 -C "your.email@example.com"

# 2. Use strong passphrases
# 3. Set appropriate file permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# 4. Regularly rotate keys (every 1-2 years)
# 5. Use different keys for different purposes
```

### Token Security

```bash
# 1. Use minimal required permissions
# 2. Set reasonable expiration dates
# 3. Regularly rotate tokens
# 4. Never commit tokens to repositories
# 5. Use environment variables for tokens

# Example: Using token from environment variable
export GITHUB_TOKEN="your-token-here"
git clone https://$GITHUB_TOKEN@github.com/username/repository.git
```

### General Security

```bash
# 1. Enable two-factor authentication on GitHub
# 2. Regularly review SSH keys and tokens in GitHub settings
# 3. Use signed commits
git config --global commit.gpgsign true

# 4. Keep Git and SSH client updated
# 5. Monitor repository access logs
```

### Additional Security Commands

```bash
# List all SSH keys added to agent
ssh-add -l

# Remove all SSH keys from agent
ssh-add -D

# Remove specific SSH key from agent
ssh-add -d ~/.ssh/id_ed25519

# Check SSH key fingerprint
ssh-keygen -lf ~/.ssh/id_ed25519.pub

# View SSH key details
ssh-keygen -lv -f ~/.ssh/id_ed25519.pub
```

This comprehensive guide covers everything you need to securely connect your local Git repositories to GitHub. Choose the method that best fits your security requirements and workflow preferences.
