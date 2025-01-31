# What is Ansible Modules:
Ansible modules are the building blocks of Ansible, a popular open-source automation tool used for configuration management, application deployment, and task automation. Modules are reusable, standalone scripts that Ansible executes to perform specific tasks on the managed nodes (servers, devices, etc.).  
 
Here are some key points about Ansible modules: 
 
1. **Functionality**: Each module is designed to perform a particular function, such as managing packages, files, users, services, or cloud resources. For example, there are modules for installing software packages, managing system services, or interacting with APIs. 
 
2. **Idempotence**: Ansible modules are idempotent, meaning that running the same module multiple times will not produce different results. If the desired state is already achieved, the module will not make any changes. 
 
3. **Language**: Most Ansible modules are written in Python, but they can be written in any language as long as they conform to the expected input and output formats. 
 
4. **Built-in and Custom Modules**: Ansible comes with a large collection of built-in modules covering many common tasks. Users can also create custom modules to meet specific needs. 
 
5. **Execution**: Modules are executed on the managed nodes, and Ansible communicates with these nodes over SSH (for Linux/Unix systems) or WinRM (for Windows systems). 
 
6. **Examples**: Some commonly used modules include: 
   - `apt`: For managing packages on Debian-based systems. 
   - `yum`: For managing packages on Red Hat-based systems. 
   - `copy`: For copying files to remote machines. 
   - `service`: For managing services (start, stop, restart). 
   - `user`: For managing user accounts. 
 
7. **Playbooks**: Ansible modules are often used within playbooks, which are YAML files that define a series of tasks to

### To  list modules:
```bash
ansible-doc -l
ansible-doc -s shell # show  information about shell module 
ansible-doc -s apt # show  information about apt module
ansible-doc yum # show information about yum module 
:EXAMPLES # search for examples of modules
ansible all -m apt -a autoclean=yes
```
## Examples
### ex1
- file ex:
- search for file "ansible-doc file"
```bash
ansible-doc file
:EXAMPLES # search for file module examples
ansible all -m file -a 'path=myfile owner=spider group=spider mode=644 state=file'
```

### ex2
- copy ex
- search for copy "ansible-doc copy"
```bash
ansible-doc copy
:EXAMPLES # search for copy module examples
ansible all -m copy -a 'content="Hello World" dest=myfile
ansible node1 -a 'cat myfile' # To check the content
```

