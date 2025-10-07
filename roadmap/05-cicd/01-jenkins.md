# Jenkins - CI/CD Automation Server

## What is Jenkins and Why Do We Need It?

Imagine you're a developer working on a web application:
- You write code and push to Git
- Someone needs to test it
- Someone needs to build it
- Someone needs to deploy it
- This happens 10-20 times per day!

**Without Jenkins:**
- Manual testing (time-consuming, error-prone)
- Manual building (inconsistent)
- Manual deployment (risky)
- Developers wait hours for deployment
- Mistakes happen frequently

**With Jenkins:**
- Push code to Git
- Jenkins automatically tests it
- Jenkins automatically builds it
- Jenkins automatically deploys it
- All in 5-10 minutes
- Same process every time
- No human errors

**Jenkins is:**
- Open-source automation server
- Runs on any OS (Linux, Windows, macOS)
- Supports 1000+ plugins
- Used by millions of developers
- Free forever

## How Jenkins Works

**The Jenkins workflow (CI/CD Pipeline):**
```
Developer -> Git Push -> Jenkins Detects Change
                            |
                            v
                    Run Automated Tests
                            |
                            v
                    Tests Pass? 
                    |          |
                   Yes        No
                    |          |
                    v          v
                Build App   Notify Developer
                    |
                    v
                Deploy to Server
                    |
                    v
                Send Success Notification
```

**Key concepts:**
- **Job/Project:** A task Jenkins performs
- **Build:** Single execution of a job
- **Pipeline:** Series of automated steps
- **Trigger:** What starts a build (Git push, schedule, manual)
- **Workspace:** Directory where Jenkins works
- **Agent/Node:** Machine where Jenkins runs jobs
- **Plugin:** Add-on functionality

## Installing Jenkins

### On Ubuntu/Debian

**Step 1: Install Java (Jenkins requirement)**
```bash
# Update packages
sudo apt update

# Install Java 11
sudo apt install openjdk-11-jdk -y

# Verify Java installation
java -version
```

Output should show:
```
openjdk version "11.0.x"
```

**Step 2: Add Jenkins repository**
```bash
# Add Jenkins GPG key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
```

**Step 3: Install Jenkins**
```bash
# Update package list
sudo apt update

# Install Jenkins
sudo apt install jenkins -y

# Start Jenkins
sudo systemctl start jenkins

# Enable Jenkins to start on boot
sudo systemctl enable jenkins

# Check status
sudo systemctl status jenkins
```

You should see "active (running)"

**Step 4: Configure firewall**
```bash
# Allow port 8080 (Jenkins default port)
sudo ufw allow 8080
sudo ufw enable
```

**Step 5: Access Jenkins**

Open browser and go to:
```
http://your-server-ip:8080
```

Or if running locally:
```
http://localhost:8080
```

**Step 6: Get initial admin password**
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Copy the password (long string like: a1b2c3d4e5f6...)

**Step 7: Complete setup wizard**
1. Paste the initial admin password
2. Click "Install suggested plugins" (recommended)
3. Wait 5-10 minutes for plugins to install
4. Create first admin user
5. Set Jenkins URL (use default or custom)
6. Click "Start using Jenkins"

Congratulations! Jenkins is now installed.

## Installing Jenkins with Docker (Alternative Method)

**Quick installation using Docker:**
```bash
# Pull Jenkins image
docker pull jenkins/jenkins:lts

# Run Jenkins container
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

# Get initial password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Access at: http://localhost:8080

## Jenkins Dashboard Overview

After login, you see the Jenkins dashboard:

**Left sidebar:**
- **New Item:** Create new job
- **People:** User management
- **Build History:** Recent builds
- **Manage Jenkins:** Configuration
- **My Views:** Custom views

**Main area:**
- List of jobs
- Build queue
- Build executor status

## Your First Jenkins Job (Freestyle Project)

Let's create a simple "Hello World" job.

**Step 1: Create job**
1. Click "New Item"
2. Enter name: "hello-world"
3. Select "Freestyle project"
4. Click OK

**Step 2: Configure job**

**General section:**
- Description: "My first Jenkins job"
- Leave other options default

**Build section:**
1. Click "Add build step"
2. Select "Execute shell"
3. Enter command:
```bash
echo "Hello from Jenkins!"
echo "Current date: $(date)"
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
```

**Step 3: Save and build**
1. Click "Save"
2. Click "Build Now" (left sidebar)
3. Watch build appear in "Build History"
4. Click build number (e.g., #1)
5. Click "Console Output"

You'll see:
```
Hello from Jenkins!
Current date: Mon Oct 7 10:30:00 UTC 2025
Current user: jenkins
Current directory: /var/lib/jenkins/workspace/hello-world
```

Green checkmark = Success!

## Building a Real Project - Python Application

Let's build a real Python application with tests.

**Step 1: Create GitHub repository**

Create a simple Python project:
```
my-python-app/
  ├── app.py
  ├── test_app.py
  └── requirements.txt
```

**app.py:**
```python
def add(a, b):
    """Add two numbers"""
    return a + b

def subtract(a, b):
    """Subtract two numbers"""
    return a - b

if __name__ == "__main__":
    print("Calculator App")
    print("5 + 3 =", add(5, 3))
    print("10 - 4 =", subtract(10, 4))
```

**test_app.py:**
```python
import unittest
from app import add, subtract

class TestCalculator(unittest.TestCase):
    def test_add(self):
        self.assertEqual(add(2, 3), 5)
        self.assertEqual(add(-1, 1), 0)
    
    def test_subtract(self):
        self.assertEqual(subtract(10, 5), 5)
        self.assertEqual(subtract(0, 5), -5)

if __name__ == '__main__':
    unittest.main()
```

**requirements.txt:**
```
pytest==7.4.0
```

Push to GitHub.

**Step 2: Create Jenkins job for Python app**

1. Click "New Item"
2. Name: "python-calculator"
3. Select "Freestyle project"
4. Click OK

**Step 3: Configure Source Code Management**

**In "Source Code Management" section:**
1. Select "Git"
2. Repository URL: `https://github.com/yourusername/my-python-app.git`
3. Credentials: Add GitHub credentials if private repo
4. Branch: `*/main`

**Step 4: Configure Build Triggers**

**In "Build Triggers" section:**
- Check "Poll SCM"
- Schedule: `H/5 * * * *`

This means: Check for changes every 5 minutes

**Step 5: Configure Build Environment**

**In "Build Environment" section:**
- Check "Delete workspace before build starts" (clean build)

**Step 6: Configure Build Steps**

**Click "Add build step" -> "Execute shell":**
```bash
# Print Python version
python3 --version

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run tests
python -m pytest test_app.py -v

# Run application
python app.py
```

**Explanation:**
- Line 2: Check Python is available
- Line 5: Create isolated Python environment
- Line 8: Activate environment
- Line 11: Install required packages
- Line 14: Run automated tests
- Line 17: Run the application

**Step 7: Configure Post-build Actions**

**Click "Add post-build action" -> "Email Notification"**
- Recipients: your-email@example.com
- Check "Send e-mail for every unstable build"

**Step 8: Save and build**
1. Click "Save"
2. Click "Build Now"
3. Watch console output

**Success looks like:**
```
+ python3 --version
Python 3.10.6
+ python3 -m venv venv
+ source venv/bin/activate
+ pip install -r requirements.txt
Successfully installed pytest-7.4.0
+ python -m pytest test_app.py -v
test_app.py::TestCalculator::test_add PASSED
test_app.py::TestCalculator::test_subtract PASSED
===== 2 passed in 0.05s =====
+ python app.py
Calculator App
5 + 3 = 8
10 - 4 = 6
Finished: SUCCESS
```

## Jenkins Pipeline (Declarative)

Pipelines are defined in code (Jenkinsfile) stored in your Git repository.

**Benefits of Pipeline:**
- Version controlled with your code
- Reviewable in pull requests
- Complex workflows possible
- Reusable across projects

**Create Jenkinsfile in your project:**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                git branch: 'main', url: 'https://github.com/yourusername/my-python-app.git'
            }
        }
        
        stage('Setup') {
            steps {
                echo 'Setting up environment...'
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt
                '''
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh '''
                    . venv/bin/activate
                    python -m pytest test_app.py -v --junitxml=test-results.xml
                '''
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building application...'
                sh '''
                    . venv/bin/activate
                    python app.py
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh '''
                    echo "Deployment would happen here"
                    # scp app.py user@server:/opt/app/
                    # ssh user@server "systemctl restart myapp"
                '''
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up...'
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

**Explanation:**
- `pipeline { }` - Main pipeline block
- `agent any` - Run on any available agent
- `stages { }` - Contains all stages
- `stage('Name') { }` - Individual stage
- `steps { }` - Commands to execute
- `sh 'command'` - Execute shell command
- `sh ''' '''` - Multi-line shell script
- `post { }` - Actions after build (success/failure/always)

**Create Pipeline job in Jenkins:**
1. New Item -> "pipeline-demo" -> Pipeline
2. In "Pipeline" section:
   - Definition: "Pipeline script from SCM"
   - SCM: Git
   - Repository URL: your-repo-url
   - Script Path: Jenkinsfile
3. Save and build

Jenkins will:
1. Clone your repo
2. Find Jenkinsfile
3. Execute pipeline
4. Show results for each stage

## Jenkins Pipeline - Advanced Example

**Complete CI/CD pipeline with Docker:**

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'myapp'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        DOCKER_REGISTRY = 'docker.io/myusername'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running tests in container...'
                sh """
                    docker run --rm ${DOCKER_IMAGE}:${DOCKER_TAG} python -m pytest
                """
            }
        }
        
        stage('Security Scan') {
            steps {
                echo 'Scanning for vulnerabilities...'
                sh """
                    docker run --rm aquasec/trivy image ${DOCKER_IMAGE}:${DOCKER_TAG}
                """
            }
        }
        
        stage('Push to Registry') {
            when {
                branch 'main'
            }
            steps {
                echo 'Pushing to Docker registry...'
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-credentials') {
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push('latest')
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                echo 'Deploying to staging...'
                sh """
                    ssh user@staging-server '
                        docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker stop myapp || true
                        docker rm myapp || true
                        docker run -d --name myapp -p 80:5000 ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                    '
                """
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            input {
                message "Deploy to production?"
                ok "Deploy"
            }
            steps {
                echo 'Deploying to production...'
                sh """
                    ssh user@prod-server '
                        docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker stop myapp || true
                        docker rm myapp || true
                        docker run -d --name myapp -p 80:5000 ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                    '
                """
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            emailext (
                subject: "Jenkins Build SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Good news! Build succeeded.",
                to: 'team@example.com'
            )
        }
        failure {
            echo 'Pipeline failed!'
            emailext (
                subject: "Jenkins Build FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Build failed. Check console output.",
                to: 'team@example.com'
            )
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
```

**Explanation of advanced features:**
- `environment { }` - Define environment variables
- `when { }` - Conditional execution
- `input { }` - Manual approval required
- `script { }` - Groovy script block
- `docker.build()` - Build Docker image
- `docker.withRegistry()` - Push to registry
- `emailext` - Send detailed emails

## Jenkins Credentials Management

Store secrets securely in Jenkins.

**Add credentials:**
1. Manage Jenkins -> Credentials
2. System -> Global credentials
3. Add Credentials

**Types:**
- **Username with password:** Git, Docker Hub
- **SSH Username with private key:** SSH connections
- **Secret text:** API keys, tokens
- **Secret file:** Certificate files

**Example: GitHub credentials**
1. Kind: Username with password
2. Username: your-github-username
3. Password: your-github-personal-access-token
4. ID: github-credentials
5. Description: GitHub access

**Use in Jenkinsfile:**
```groovy
stage('Clone') {
    steps {
        git credentialsId: 'github-credentials',
            url: 'https://github.com/user/repo.git',
            branch: 'main'
    }
}
```

**Example: Docker Hub credentials**
```groovy
stage('Push Image') {
    steps {
        script {
            docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                docker.image("myapp:${BUILD_NUMBER}").push()
            }
        }
    }
}
```

**Example: SSH credentials**
```groovy
stage('Deploy') {
    steps {
        sshagent(['ssh-credentials']) {
            sh '''
                ssh user@server 'docker pull myapp:latest'
                ssh user@server 'docker restart myapp'
            '''
        }
    }
}
```

## Jenkins Plugins

Jenkins has 1000+ plugins. Here are essential ones:

**Install plugins:**
1. Manage Jenkins -> Plugins
2. Available plugins tab
3. Search and select plugins
4. Install without restart

**Essential plugins:**

**Git Plugin** (pre-installed)
- Clone Git repositories
- Trigger builds on push

**Docker Pipeline Plugin**
```groovy
docker.build('myapp:latest')
docker.image('myapp:latest').push()
```

**Pipeline Plugin** (pre-installed)
- Create pipelines as code

**Blue Ocean Plugin**
- Modern UI for pipelines
- Visual pipeline editor
- Better visualization

**Slack Notification Plugin**
```groovy
slackSend (
    color: 'good',
    message: "Build ${env.BUILD_NUMBER} succeeded"
)
```

**Email Extension Plugin**
```groovy
emailext (
    subject: "Build ${BUILD_NUMBER}",
    body: "Check console output",
    to: 'team@example.com'
)
```

**JUnit Plugin**
- Publish test results
```groovy
junit 'test-results.xml'
```

**SonarQube Scanner Plugin**
- Code quality analysis
```groovy
withSonarQubeEnv('SonarQube') {
    sh 'mvn sonar:sonar'
}
```

## Jenkins Master-Agent Architecture

For scaling, use master-agent setup.

**Master (Controller):**
- Manages jobs
- Stores configuration
- Serves web UI
- Schedules builds

**Agent (Node):**
- Executes builds
- Reports to master
- Can be Docker, SSH, or cloud

**Add SSH agent:**
1. Manage Jenkins -> Nodes
2. New Node
3. Node name: "agent-1"
4. Permanent Agent
5. Configure:
   - Remote root: /home/jenkins
   - Labels: linux docker
   - Launch method: SSH
   - Host: agent-ip
   - Credentials: SSH key

**Use agent in pipeline:**
```groovy
pipeline {
    agent {
        label 'linux docker'
    }
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t myapp .'
            }
        }
    }
}
```

**Multiple agents:**
```groovy
pipeline {
    agent none
    stages {
        stage('Build on Linux') {
            agent {
                label 'linux'
            }
            steps {
                sh 'make build'
            }
        }
        stage('Test on Windows') {
            agent {
                label 'windows'
            }
            steps {
                bat 'run-tests.bat'
            }
        }
    }
}
```

## Jenkins Backup and Restore

**Important directories:**
```
/var/lib/jenkins/
  ├── jobs/           # All jobs
  ├── users/          # User accounts
  ├── secrets/        # Credentials
  ├── plugins/        # Installed plugins
  └── config.xml      # Jenkins config
```

**Backup Jenkins:**
```bash
# Stop Jenkins
sudo systemctl stop jenkins

# Create backup
sudo tar -czf jenkins-backup-$(date +%Y%m%d).tar.gz /var/lib/jenkins/

# Start Jenkins
sudo systemctl start jenkins
```

**Restore Jenkins:**
```bash
# Stop Jenkins
sudo systemctl stop jenkins

# Restore backup
sudo tar -xzf jenkins-backup-20250107.tar.gz -C /

# Fix permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins

# Start Jenkins
sudo systemctl start jenkins
```

**Automated backup script:**
```bash
#!/bin/bash
# jenkins-backup.sh

BACKUP_DIR="/backup/jenkins"
JENKINS_HOME="/var/lib/jenkins"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup Jenkins
tar -czf $BACKUP_DIR/jenkins-$DATE.tar.gz $JENKINS_HOME

# Keep only last 7 days
find $BACKUP_DIR -name "jenkins-*.tar.gz" -mtime +7 -delete

echo "Backup completed: jenkins-$DATE.tar.gz"
```

**Schedule with cron:**
```bash
# Run daily at 2 AM
0 2 * * * /opt/scripts/jenkins-backup.sh
```

## Jenkins Best Practices

1. **Use Pipeline as Code** (Jenkinsfile in repo)
2. **Version control everything** (Jenkinsfile, scripts)
3. **Use shared libraries** for common code
4. **Implement proper security** (credentials, RBAC)
5. **Monitor Jenkins performance**
6. **Regular backups** (automated)
7. **Use agents** for scaling
8. **Clean workspaces** after builds
9. **Use Docker** for consistent environments
10. **Implement proper logging**

## Troubleshooting Common Issues

**Issue 1: Build stuck in queue**
**Cause:** No available executors
**Solution:**
```bash
# Increase executors
Manage Jenkins -> Configure System -> # of executors -> 4
```

**Issue 2: Permission denied**
**Cause:** Jenkins user lacks permissions
**Solution:**
```bash
# Add jenkins to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

**Issue 3: Out of disk space**
**Cause:** Old builds and workspaces
**Solution:**
```bash
# Clean old builds
Manage Jenkins -> Manage Old Data

# Configure build retention
Job -> Configure -> Discard old builds -> Keep last 10 builds
```

**Issue 4: Plugin conflicts**
**Cause:** Incompatible plugin versions
**Solution:**
```bash
# Check plugin manager
Manage Jenkins -> Plugins -> Updates
# Update all plugins
```

## Practice Exercises

1. Create freestyle job that runs shell script
2. Build Python application with automated tests
3. Create pipeline with multiple stages
4. Implement Docker build and push
5. Set up master-agent architecture
6. Configure automated backups
7. Implement email notifications
8. Create multi-branch pipeline

## How Jenkins Connects to Other Tools

**Jenkins + Git:**
- Jenkins pulls code from Git
- Triggers builds on push

**Jenkins + Docker:**
- Builds Docker images
- Runs tests in containers
- Pushes to Docker Hub

**Jenkins + Kubernetes:**
- Deploys to Kubernetes cluster
- Runs Jenkins agents as pods

**Jenkins + Ansible:**
- Calls Ansible playbooks
- Automates configuration

**Jenkins + Terraform:**
- Provisions infrastructure
- Applies Terraform configs

**Jenkins + AWS:**
- Deploys to EC2
- Updates S3 buckets
- Manages cloud resources

## Next Steps

Jenkins is the automation engine of your DevOps pipeline. Practice building simple pipelines before complex workflows.

Continue to: `02-github-actions.md`
