# Phase 2: Version Control Systems

## Overview

Version control is the foundation of modern software development and DevOps. It tracks every change to your code, enables collaboration, and provides a complete history of your project. Git is the industry-standard version control system, and GitHub is the most popular platform for hosting Git repositories.

## Learning Objectives

By the end of this phase, you will:

- Understand what version control is and why it matters
- Master Git fundamentals and workflows
- Use GitHub for collaboration
- Understand branching strategies
- Handle merge conflicts confidently
- Integrate Git into your DevOps workflow
- Use Git in CI/CD pipelines

## Time Required

Estimated: 2 weeks with 3-4 hours daily practice

## Why Version Control in DevOps?

**Code History:** Every change is recorded with who, what, when, why
**Collaboration:** Multiple team members work on same codebase simultaneously
**Rollback:** Revert to previous working version instantly
**Branching:** Experiment without affecting production code
**CI/CD Integration:** Automated pipelines trigger on code changes
**Infrastructure as Code:** Terraform, Kubernetes manifests versioned like code
**Audit Trail:** Compliance and security requirements
**Backup:** Distributed copies on every developer machine and remote servers

### How Git Connects to Other DevOps Tools

**Git triggers CI/CD:**
```
Developer commits code → Git push → Webhook triggers Jenkins/GitHub Actions
→ Build → Test → Deploy
```

**Git stores Infrastructure as Code:**
```
Terraform files in Git → Changes reviewed → Merged → Terraform applies changes
→ Infrastructure updated
```

**Git manages configurations:**
```
Ansible playbooks → Kubernetes YAML → Docker Compose files
All versioned, reviewed, tested via Git
```

## Module Structure

1. `01-git-basics.md` - Git fundamentals
2. `02-github-collaboration.md` - GitHub workflows
3. `03-branching-strategies.md` - Branch management
4. `04-advanced-git.md` - Advanced operations
5. `05-git-in-devops.md` - DevOps integration
6. `06-labs.md` - Hands-on exercises

## Prerequisites

- Completed Phase 1 (Fundamentals)
- Linux command line proficiency
- GitHub account created
- Git installed on your system

## Installation

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install git -y
git --version
```

### Initial Configuration
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
git config --global core.editor "nano"
git config --list
```

## Key Concepts Preview

### Repository
A project folder tracked by Git containing all files and complete history.

### Commit
A snapshot of your project at a specific point in time.

### Branch
An independent line of development allowing parallel work.

### Remote
A Git repository hosted on a server (GitHub, GitLab, Bitbucket).

### Pull Request
A request to merge your changes into another branch with code review.

### Merge
Combining changes from different branches.

### Conflict
When same lines are modified in different branches requiring manual resolution.

## Real-World DevOps Scenario

Imagine deploying a web application:

1. Developer creates feature branch from main
2. Writes code, commits locally
3. Pushes to GitHub
4. Creates pull request
5. Team reviews code
6. Automated tests run (CI/CD)
7. Code approved and merged to main
8. Main branch triggers deployment pipeline
9. Application deployed to production
10. If issues arise, revert commit instantly

All of this is powered by Git.

## Learning Path

Start with `01-git-basics.md` and progress sequentially. Each module builds on previous knowledge.

Practice extensively. Git is learned by doing, not just reading.

## Common Mistakes to Avoid

1. **Not committing frequently:** Commit small, logical changes
2. **Poor commit messages:** Write clear, descriptive messages
3. **Working only on main branch:** Use feature branches
4. **Not pulling before pushing:** Always sync with remote first
5. **Committing sensitive data:** Never commit passwords, keys, secrets
6. **Large binary files:** Git is for source code, not large files
7. **Not using .gitignore:** Exclude unnecessary files

## Success Criteria

You are ready for Phase 3 when you can:

- [ ] Initialize repositories and make commits
- [ ] Create and merge branches
- [ ] Resolve merge conflicts
- [ ] Use GitHub for collaboration
- [ ] Write good commit messages
- [ ] Understand and use Git workflows
- [ ] Integrate Git with automation tools
- [ ] Review and approve pull requests

## Next Steps

Begin with `01-git-basics.md` to learn fundamental Git operations.

Remember: Git seems complex initially but becomes second nature with practice. It is an essential skill for every DevOps engineer.
