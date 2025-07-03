```dockerfile
 FROM ubuntu:latest

# Install required packages
RUN apt-get update -qy && \
    apt-get install -qy --no-install-recommends \
        openjdk-11-jdk \
        openssh-server \
        maven \
        git

# Configure SSH
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd

# Create Jenkins user
RUN useradd -ms /bin/bash jenkins --home /home/jenkins && \
    echo "jenkins:jenkins" | chpasswd

# Expose port and set default command
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]