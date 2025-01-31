# i'll add all about playbook here

### Create user with playbook 
- 1. go to ansible-doc to see how to create user with playbook  ane search "EXAMPLES:" 
```bash
ansible-doc user |  grep -A 20 EXAMPLES
```

- 2. create play.yaml file
```yaml
---
- name: this play to create user 
  hosts: node2
  tasks:
    - name: Creating user Khaled
      user:  khaled
      uid: 2001
      state: present
```
- 3. check for syntax errors 
```bash
ansible-playbook first-play.yaml --syntax-check
```
- 4. after checking for syntax errors , run the playbook 
```bash
ansible-playbook first-play.yaml
```
### Ex2
- 1. go to ansible-doc to see how to create user with playbook  ane search
```bash
ansible-doc user |  grep -A 20 EXAMPLES
```
- 2. create play.yaml file
```yaml
- name: Add the user 'Mesho' with a bash shell, appending the group 'admins' and 'developers' to the user's groups
  hosts: node1
  tasks:
  - name: james
    user:
      name: mesho
      uid: 2003
      state: present
      shell: /bin/bash
      groups: sudo,spider
      append: yes
```
- 3. check for syntax errors
```bash
ansible-playbook second-play.yaml --syntax-check
```
- 4. after checking for syntax errors , run the playbook
```bash
ansible-playbook second-play.yaml
```

## Example with give password to the user:
- 1. go to ansible-doc to see how to create user with playbook  ane search
```bash
ansible-doc user |  grep -A 20 EXAMPLES
```
- 02. before creating play.yaml encrypt the password nad put it into the password field
```bash
 mkpasswd -m sha-512 "pass"
```
- 2. create play.yaml file
```yaml
---
- name: Creating users by using array syntax
  hosts: node2
  vars:
    user: 
      name: hamed
      group: sudo 
      uid: 2004
      shell: /bin/bash
      home: /home/hamed
      password: "$6$Hap75oC3eB2CEa9W$.eqionELCnjEyckOMOVJp8qYaTJ8..Sv.RS8iifl2duTNAnY5.CzGuhUafpeXx0AqtCnWmowezNSJEmTafwpI1"
  tasks:
    - name: Create user with array syntax
      user: 
        name: "{{user['name']}}" 
        group: "{{user['group']}}"
        state: present
        shell: "{{user['shell']}}"
        uid: "{{user['uid']}}"
        password: "{{user['password']}}"
```
- 3. check for syntax errors
```bash
ansible-playbook play.yaml --syntax-check
```
- 4. after checking for syntax errors , run the playbook
```bash
ansible-playbook play.yaml
```
- 5. check if user created
```bash
ansible node2 -m user -a "name=hamed"
```