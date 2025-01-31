# Commands that help U with Ansible

```bash

ansible all --list-host -v  # List all hosts and show witch cfg file is using with ansible 
ansible node1 -m file -a 'path=/home/spider/admon state=touch'
ansible node1 -m file -a 'path=/home/spider/admon state=absent'
ansible node1 -m file -a 'path=/home/spider/admon state=directory'
ansible all -m command -a 'free -h '
ansible all -m timezone -a "name=Africa/Cairo"
ansible all -a 'date'
ansible all -a 'echo "Hello Feom ANsible Ad-hoc" > myfile' # it gives you an error the correct answer below 
ansible all -m shell -a 'echo "Hello From Ansible Ad-Hc" > myfile'
ansible all -m copy -a 'content="Hello From Ansible Ad-Hc" dest=/home/spider/myfile'
ansible all -m file -a 'path=/home/spider/admin  state=absent'
 ansible all -m file -a 'path=/home/spider/admin1  state=directory'
ansible-doc -l # show documentation of modules
ansible-doc -s shell # show documentation of shell module











```