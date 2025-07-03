# Git Workflows and Advanced Topics

## Table of Contents
1. [Git Workflows](#git-workflows)
2. [Collaborative Development](#collaborative-development)
3. [Git Hooks](#git-hooks)
4. [Advanced Configuration](#advanced-configuration)
5. [Performance and Optimization](#performance-and-optimization)
6. [Troubleshooting and Recovery](#troubleshooting-and-recovery)
7. [Git Aliases and Shortcuts](#git-aliases-and-shortcuts)
8. [Integration with IDEs and Tools](#integration-with-ides-and-tools)
9. [Security Best Practices](#security-best-practices)
10. [Git Best Practices](#git-best-practices)

## Git Workflows

### 1. Centralized Workflow
Simple workflow for small teams.

```bash
# All developers work on main branch
git clone https://github.com/team/project.git
cd project

# Make changes
echo "new feature" >> feature.txt
git add feature.txt
git commit -m "Add new feature"

# Push changes
git push origin main

# Pull updates from others
git pull origin main
```

### 2. Feature Branch Workflow
Each feature developed in separate branch.

```bash
# Create feature branch
git checkout -b feature/user-authentication

# Develop feature
git add .
git commit -m "Implement user login"
git commit -m "Add password validation"
git commit -m "Create user session management"

# Push feature branch
git push origin feature/user-authentication

# Create pull request on GitHub
# After review and approval, merge to main
git checkout main
git pull origin main
git merge feature/user-authentication
git push origin main

# Clean up
git branch -d feature/user-authentication
git push origin --delete feature/user-authentication
```

### 3. Gitflow Workflow
Structured workflow with specific branch types.

#### Branch Types:
- **main**: Production-ready code
- **develop**: Integration branch for features
- **feature/***: Individual features
- **release/***: Preparing releases
- **hotfix/***: Critical fixes for production

```bash
# Initialize gitflow
git flow init

# Start new feature
git flow feature start user-authentication

# Work on feature
git add .
git commit -m "Implement authentication"

# Finish feature (merges to develop)
git flow feature finish user-authentication

# Start release
git flow release start 1.0.0

# Prepare release
git add .
git commit -m "Bump version to 1.0.0"

# Finish release (merges to main and develop, creates tag)
git flow release finish 1.0.0

# Start hotfix
git flow hotfix start critical-bug

# Fix bug
git add .
git commit -m "Fix critical security issue"

# Finish hotfix (merges to main and develop)
git flow hotfix finish critical-bug
```

### 4. GitHub Flow
Simplified workflow focused on continuous deployment.

```bash
# Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/add-search

# Make changes
git add .
git commit -m "Add search functionality"

# Push and create pull request
git push origin feature/add-search

# After review, merge to main
# Deploy main to production
```

### 5. GitLab Flow
Combines feature-driven development with issue tracking.

```bash
# Create branch from issue
git checkout -b 123-add-user-profile

# Implement feature
git add .
git commit -m "Add user profile page

Closes #123"

# Push and create merge request
git push origin 123-add-user-profile

# After review, merge to main
```

## Collaborative Development

### Working with Forks

#### 1. Fork and Clone
```bash
# Fork repository on GitHub, then:
git clone git@github.com:yourusername/project.git
cd project

# Add upstream remote
git remote add upstream git@github.com:originalowner/project.git

# Verify remotes
git remote -v
```

#### 2. Keep Fork Updated
```bash
# Fetch upstream changes
git fetch upstream

# Merge upstream changes
git checkout main
git merge upstream/main

# Push updates to your fork
git push origin main
```

#### 3. Create Pull Request
```bash
# Create feature branch
git checkout -b feature/improvement

# Make changes
git add .
git commit -m "Implement improvement"

# Push to your fork
git push origin feature/improvement

# Create pull request on GitHub
```

### Code Review Process

#### 1. Creating Good Pull Requests
```bash
# Use descriptive branch names
git checkout -b feature/user-authentication-oauth

# Make atomic commits
git commit -m "Add OAuth provider configuration"
git commit -m "Implement OAuth login flow"
git commit -m "Add OAuth user registration"

# Write good commit messages
git commit -m "Add user authentication via OAuth

- Configure OAuth providers (Google, GitHub)
- Implement login/logout flow
- Add user registration for new OAuth users
- Update UI to show OAuth login options

Fixes #123
Closes #124"
```

#### 2. Reviewing Pull Requests
```bash
# Fetch PR branch for local testing
git fetch origin pull/123/head:pr-123
git checkout pr-123

# Test the changes
# Run tests, check functionality

# Leave review comments on GitHub
# Approve or request changes
```

### Conflict Resolution Strategies

#### 1. Merge Conflicts
```bash
# When conflicts occur during merge
git merge feature-branch

# Conflict markers in file:
<<<<<<< HEAD
current branch content
=======
merging branch content
>>>>>>> feature-branch

# Resolve manually, then:
git add conflicted-file.txt
git commit -m "Resolve merge conflict"
```

#### 2. Rebase Conflicts
```bash
# During rebase
git rebase main

# Resolve conflicts in each commit
git add .
git rebase --continue

# Or abort rebase
git rebase --abort
```

#### 3. Prevention Strategies
```bash
# Keep branches up to date
git checkout feature-branch
git rebase main

# Use smaller, focused commits
# Communicate with team about overlapping work
# Regular integration testing
```

## Git Hooks

Git hooks are scripts that run automatically on certain Git events.

### Client-Side Hooks

#### 1. Pre-commit Hook
Runs before commit is created.

```bash
# Create hook file
touch .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Example pre-commit hook
#!/bin/bash
# .git/hooks/pre-commit

# Run linting
echo "Running linter..."
if ! npx eslint src/; then
    echo "Linting failed. Please fix errors before committing."
    exit 1
fi

# Run tests
echo "Running tests..."
if ! npm test; then
    echo "Tests failed. Please fix tests before committing."
    exit 1
fi

echo "Pre-commit checks passed!"
```

#### 2. Commit-msg Hook
Validates commit messages.

```bash
#!/bin/bash
# .git/hooks/commit-msg

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format!"
    echo "Format: type(scope): description"
    echo "Example: feat(auth): add OAuth login"
    exit 1
fi
```

#### 3. Pre-push Hook
Runs before pushing to remote.

```bash
#!/bin/bash
# .git/hooks/pre-push

# Run full test suite
echo "Running full test suite..."
if ! npm run test:full; then
    echo "Tests failed. Push aborted."
    exit 1
fi

# Check for secrets
echo "Checking for secrets..."
if git diff --cached --name-only | xargs grep -l "API_KEY\|PASSWORD\|SECRET"; then
    echo "Potential secrets found! Please review."
    exit 1
fi
```

### Server-Side Hooks

#### 1. Pre-receive Hook
```bash
#!/bin/bash
# hooks/pre-receive

while read oldrev newrev refname; do
    # Prevent force pushes to main
    if [[ $refname == "refs/heads/main" ]]; then
        if [[ $oldrev != "0000000000000000000000000000000000000000" ]]; then
            if ! git merge-base --is-ancestor $oldrev $newrev; then
                echo "Force push to main branch is not allowed!"
                exit 1
            fi
        fi
    fi
done
```

#### 2. Post-receive Hook
```bash
#!/bin/bash
# hooks/post-receive

while read oldrev newrev refname; do
    if [[ $refname == "refs/heads/main" ]]; then
        echo "Deploying to production..."
        cd /var/www/production
        git pull origin main
        npm install
        npm run build
        systemctl restart app
        echo "Deployment complete!"
    fi
done
```

### Using Git Hooks Tools

#### 1. Husky (Node.js projects)
```bash
# Install Husky
npm install --save-dev husky

# Initialize
npx husky install

# Add pre-commit hook
npx husky add .husky/pre-commit "npm test"

# Add commit-msg hook
npx husky add .husky/commit-msg 'npx commitlint --edit "$1"'
```

#### 2. Pre-commit Framework
```bash
# Install pre-commit
pip install pre-commit

# Create .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

# Install hooks
pre-commit install

# Run on all files
pre-commit run --all-files
```

## Advanced Configuration

### Git Configuration Levels

#### 1. System Configuration
```bash
# Affects all users on system
sudo git config --system user.name "System Default"
sudo git config --system core.editor "vim"
```

#### 2. Global Configuration
```bash
# Affects current user
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

#### 3. Local Configuration
```bash
# Affects current repository only
git config --local user.name "Project Specific Name"
git config --local user.email "project@example.com"
```

### Advanced Git Settings

#### 1. Performance Settings
```bash
# Enable parallel index preload
git config --global core.preloadindex true

# Enable file system monitor
git config --global core.fsmonitor true

# Set pack size limit
git config --global pack.packSizeLimit 2g

# Enable commit graph
git config --global core.commitGraph true
git config --global gc.writeCommitGraph true
```

#### 2. Security Settings
```bash
# Disable automatic GC
git config --global gc.auto 0

# Set secure defaults
git config --global transfer.fsckObjects true
git config --global fetch.fsckObjects true
git config --global receive.fsckObjects true

# Enable push cert
git config --global push.gpgSign true
```

#### 3. UI/UX Settings
```bash
# Better diff algorithm
git config --global diff.algorithm histogram

# Show more context in diffs
git config --global diff.context 5

# Highlight moved code
git config --global diff.colorMoved zebra

# Better merge conflict style
git config --global merge.conflictStyle diff3

# Automatically prune on fetch
git config --global fetch.prune true

# Use rebase for pull by default
git config --global pull.rebase true
```

### Conditional Configuration
```bash
# ~/.gitconfig
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work

[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal

# ~/.gitconfig-work
[user]
    name = "Work Name"
    email = "work@company.com"

# ~/.gitconfig-personal
[user]
    name = "Personal Name"
    email = "personal@example.com"
```

## Performance and Optimization

### Repository Maintenance

#### 1. Garbage Collection
```bash
# Manual garbage collection
git gc

# Aggressive garbage collection
git gc --aggressive

# Auto garbage collection settings
git config --global gc.auto 6700
git config --global gc.autopacklimit 50

# Check repository size
git count-objects -v
```

#### 2. Pruning and Cleanup
```bash
# Prune unreachable objects
git prune

# Prune with expiry date
git prune --expire="2 weeks ago"

# Clean untracked files
git clean -fd

# Prune remote tracking branches
git remote prune origin

# Remove merged branches
git branch --merged | grep -v main | xargs git branch -d
```

#### 3. Large File Handling
```bash
# Install Git LFS
git lfs install

# Track large files
git lfs track "*.psd"
git lfs track "*.zip"
git lfs track "design/**"

# Add .gitattributes
git add .gitattributes

# Check LFS status
git lfs status

# Migrate existing large files
git lfs migrate import --include="*.zip"
```

### Performance Monitoring
```bash
# Time Git operations
time git clone https://github.com/user/repo.git

# Profile Git commands
GIT_TRACE=1 git status
GIT_TRACE_PERFORMANCE=1 git log --oneline
GIT_TRACE_SETUP=1 git config --list

# Check index performance
GIT_TRACE_INDEX=1 git add .
```

## Troubleshooting and Recovery

### Common Problems and Solutions

#### 1. Accidentally Committed Wrong Files
```bash
# Remove file from last commit but keep in working directory
git reset --soft HEAD~1
git reset HEAD filename.txt
git commit -m "Correct commit without wrong file"

# Or amend the commit
git reset HEAD~1
git add correct-files-only
git commit -m "Corrected commit"
```

#### 2. Wrong Commit Message
```bash
# Change last commit message
git commit --amend -m "Corrected commit message"

# Change older commit message
git rebase -i HEAD~3
# Change 'pick' to 'reword' for the commit to edit
```

#### 3. Committed to Wrong Branch
```bash
# Move last commit to different branch
git checkout correct-branch
git cherry-pick wrong-branch
git checkout wrong-branch
git reset --hard HEAD~1
```

#### 4. Lost Commits
```bash
# Find lost commits
git reflog

# Recover lost commit
git checkout commit-hash
git checkout -b recovery-branch

# Or reset to lost commit
git reset --hard commit-hash
```

#### 5. Corrupted Repository
```bash
# Check repository integrity
git fsck --full

# Recover from backup
git clone --mirror backup-url .git
git reset --hard

# Recovery from reflog
git reflog expire --expire-unreachable=now --all
git gc --prune=now
```

### Advanced Recovery Techniques

#### 1. Recovering Deleted Branch
```bash
# Find the commit where branch was deleted
git reflog

# Recreate branch
git checkout -b recovered-branch commit-hash
```

#### 2. Splitting Commits
```bash
# Interactive rebase
git rebase -i HEAD~3

# Mark commit for editing
# When rebase stops:
git reset HEAD~1
git add file1.txt
git commit -m "First part of original commit"
git add file2.txt
git commit -m "Second part of original commit"
git rebase --continue
```

#### 3. Combining Commits
```bash
# Interactive rebase
git rebase -i HEAD~3

# Change 'pick' to 'squash' for commits to combine
# Edit the combined commit message when prompted
```

## Git Aliases and Shortcuts

### Useful Aliases
```bash
# Basic shortcuts
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

# Advanced aliases
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'

# Log aliases
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.ll "log --oneline"
git config --global alias.lol "log --graph --decorate --pretty=oneline --abbrev-commit"
git config --global alias.lola "log --graph --decorate --pretty=oneline --abbrev-commit --all"

# Useful shortcuts
git config --global alias.s "status -s"
git config --global alias.aa "add --all"
git config --global alias.cm "commit -m"
git config --global alias.ca "commit -am"
git config --global alias.ps "push"
git config --global alias.pl "pull"
git config --global alias.rb "rebase"

# Advanced workflow aliases
git config --global alias.wip "commit -am 'WIP: work in progress'"
git config --global alias.unwip "reset HEAD~1"
git config --global alias.assume "update-index --assume-unchanged"
git config --global alias.unassume "update-index --no-assume-unchanged"
git config --global alias.assumed "!git ls-files -v | grep ^h | cut -c 3-"

# Find and cleanup
git config --global alias.find "log --pretty=\"format:%Cgreen%H %Cblue%s\" --name-status --grep"
git config --global alias.cleanup "!git branch --merged | grep -v -E '(main|master|develop)' | xargs -n 1 git branch -d"
```

### Shell Functions for Git
Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Quick git status
function gs() {
    git status -s
}

# Quick commit with message
function gcm() {
    git commit -m "$1"
}

# Git add all and commit
function gac() {
    git add --all
    git commit -m "$1"
}

# Create and checkout new branch
function gcb() {
    git checkout -b "$1"
}

# Push current branch to origin
function gp() {
    local branch=$(git symbolic-ref --short HEAD)
    git push origin "$branch"
}

# Git log with graph
function glog() {
    git log --graph --oneline --decorate --all
}

# Show git branch in prompt
function git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Add to PS1
export PS1="\u@\h \W \$(git_branch)\$ "
```

## Integration with IDEs and Tools

### VS Code Integration

#### 1. Essential Extensions
- GitLens
- Git Graph
- Git History
- GitHub Pull Requests

#### 2. VS Code Git Settings
```json
{
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "git.autofetch": true,
    "git.showInlineOpenFileAction": false,
    "gitlens.advanced.messages": {
        "suppressCommitHasNoPreviousCommitWarning": false,
        "suppressCommitNotFoundWarning": false,
        "suppressFileNotUnderSourceControlWarning": false,
        "suppressGitVersionWarning": false,
        "suppressLineUncommittedWarning": false,
        "suppressNoRepositoryWarning": false
    }
}
```

### Command Line Tools

#### 1. Git Prompt
```bash
# Install git-prompt
curl -o ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

# Add to ~/.bashrc
source ~/.git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export PS1='\u@\h \W$(__git_ps1 " (%s)")\$ '
```

#### 2. Git Completion
```bash
# Install git-completion
curl -o ~/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

# Add to ~/.bashrc
source ~/.git-completion.bash
```

#### 3. Useful Tools
```bash
# Install tig (text-mode interface for Git)
sudo apt install tig

# Install diff-so-fancy (better diff output)
npm install -g diff-so-fancy
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

# Install hub (GitHub command line tool)
# Arch Linux
sudo pacman -S hub

# Usage
hub clone user/repo
hub create
hub pull-request
```

## Security Best Practices

### 1. Protecting Sensitive Data

#### Prevent Secrets in Commits
```bash
# Use .gitignore effectively
echo ".env" >> .gitignore
echo "config/secrets.yml" >> .gitignore
echo "*.key" >> .gitignore
echo "*.pem" >> .gitignore

# Use git-secrets tool
git secrets --register-aws
git secrets --install
git secrets --scan
```

#### Remove Secrets from History
```bash
# Remove file from all history
git filter-branch --force --index-filter \
'git rm --cached --ignore-unmatch path/to/secret-file' \
--prune-empty --tag-name-filter cat -- --all

# Or use BFG Repo-Cleaner
java -jar bfg.jar --delete-files secret-file.txt
java -jar bfg.jar --replace-text passwords.txt
```

### 2. Commit Signing

#### GPG Setup
```bash
# Generate GPG key
gpg --full-generate-key

# List GPG keys
gpg --list-secret-keys --keyid-format LONG

# Export public key
gpg --armor --export KEY_ID

# Configure Git to use GPG
git config --global user.signingkey KEY_ID
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

#### SSH Commit Signing
```bash
# Configure Git to use SSH for signing
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

### 3. Repository Security

#### Branch Protection
```bash
# On GitHub, enable:
# - Require pull request reviews
# - Require status checks
# - Require signed commits
# - Restrict pushes to main branch
```

#### Access Control
```bash
# Use SSH keys instead of passwords
# Regularly rotate access tokens
# Use organization-level security policies
# Enable two-factor authentication
```

## Git Best Practices

### 1. Commit Guidelines

#### Good Commit Messages
```bash
# Format: type(scope): description
# 
# Types: feat, fix, docs, style, refactor, test, chore
# Scope: optional, component/module affected
# Description: imperative mood, present tense

# Examples:
git commit -m "feat(auth): add OAuth2 integration"
git commit -m "fix(api): handle null response in user endpoint"
git commit -m "docs(readme): update installation instructions"
git commit -m "refactor(utils): extract common validation functions"
```

#### Atomic Commits
```bash
# Each commit should represent a single logical change
# Bad: "Fix bug and add feature and update docs"
# Good: Three separate commits

# Use staging area effectively
git add file1.py
git commit -m "fix(auth): handle expired tokens"

git add file2.py
git commit -m "feat(user): add profile update endpoint"

git add README.md
git commit -m "docs(api): document profile endpoints"
```

### 2. Branching Strategy

#### Branch Naming Conventions
```bash
# Use descriptive names with prefixes
feature/user-authentication
bugfix/login-redirect-issue
hotfix/security-vulnerability
chore/update-dependencies
docs/api-documentation

# Include issue numbers
feature/123-user-authentication
bugfix/456-login-redirect
```

#### Keep Branches Small
```bash
# Create focused feature branches
# Merge frequently to avoid conflicts
# Delete branches after merging
git branch -d feature/completed-feature
git push origin --delete feature/completed-feature
```

### 3. Repository Organization

#### Directory Structure
```
project/
├── .gitignore
├── .gitattributes
├── README.md
├── CONTRIBUTING.md
├── LICENSE
├── CHANGELOG.md
├── docs/
├── src/
├── tests/
├── scripts/
└── config/
```

#### Documentation
```bash
# Always include:
# - README.md with project description
# - CONTRIBUTING.md with contribution guidelines
# - LICENSE file
# - CHANGELOG.md for version history
# - API documentation
# - Setup and deployment instructions
```

### 4. Workflow Best Practices

#### Regular Maintenance
```bash
# Regular tasks:
# - Run git gc periodically
# - Update .gitignore as needed
# - Review and clean up old branches
# - Update documentation
# - Security audit of dependencies
```

#### Team Collaboration
```bash
# Establish team conventions:
# - Consistent commit message format
# - Code review requirements
# - Testing requirements before merge
# - Deployment procedures
# - Conflict resolution process
```

#### Continuous Integration
```bash
# Set up CI/CD pipeline:
# - Automated testing on pull requests
# - Code quality checks
# - Security scanning
# - Automated deployment
# - Notification systems
```

This comprehensive guide covers all major aspects of Git, from basic usage to advanced workflows and best practices. Use it as a reference for your daily Git operations and team collaboration.
