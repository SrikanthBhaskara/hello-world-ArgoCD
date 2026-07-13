# Linux 27 – Ansible Automation & Configuration Management

## 0. Goal of This Note

- Understand Ansible architecture and use cases
- Master Ansible inventory and playbooks
- Work with variables, templates, and handlers
- Create and use Ansible roles
- Implement infrastructure automation patterns
- Manage configurations at scale

---

## 1. Ansible Overview

### 1.1 What is Ansible?

**Ansible** is an open-source automation tool for:
- **Configuration management** (manage system configs)
- **Application deployment** (deploy apps consistently)
- **Orchestration** (coordinate multi-tier deployments)
- **Provisioning** (set up infrastructure)

**Key features:**
- **Agentless** (uses SSH, no agents required)
- **Declarative** (describe desired state, not steps)
- **Idempotent** (safe to run multiple times)
- **Simple** (YAML-based, human-readable)
- **Powerful** (thousands of modules)

**Use cases:**
- Configure hundreds of servers identically
- Deploy applications across environments
- Patch systems at scale
- Enforce security policies
- Automate repetitive tasks

### 1.2 Ansible Architecture

```
┌──────────────────┐
│ CONTROL NODE     │
│  (your machine)  │
│                  │
│  - ansible       │
│  - ansible-      │
│    playbook      │
│  - inventory     │
│  - playbooks/    │
└────────┬─────────┘
         │ SSH (agentless)
         │
    ┌────┼────┬────┬────┐
    │    │    │    │    │
┌───▼┐ ┌─▼──┐ ┌─▼──┐ ┌─▼──┐
│ Web│ │ DB │ │ App│ │ LB │  MANAGED NODES
└────┘ └────┘ └────┘ └────┘  (target servers)
```

**Components:**
- **Control Node**: Where Ansible runs (your laptop, CI/CD server)
- **Managed Nodes**: Servers you're managing
- **Inventory**: List of managed nodes
- **Modules**: Units of code (e.g., `apt`, `file`, `service`)
- **Tasks**: Single action (run a module)
- **Playbooks**: YAML files defining tasks
- **Roles**: Reusable, organized playbooks

---

## 2. Ansible Installation

### 2.1 Install Ansible

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install ansible

# Or latest version via PPA
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

**RHEL/CentOS/Rocky:**
```bash
sudo dnf install epel-release
sudo dnf install ansible
```

**pip (any OS):**
```bash
pip3 install ansible

# Or with virtual environment
python3 -m venv ansible-venv
source ansible-venv/bin/activate
pip install ansible
```

**Verify installation:**
```bash
ansible --version
```

### 2.2 SSH Setup

**Ansible requires passwordless SSH access to managed nodes.**

```bash
# Generate SSH key (if not exists)
ssh-keygen -t rsa -b 4096

# Copy key to managed nodes
ssh-copy-id user@server1
ssh-copy-id user@server2
ssh-copy-id user@server3

# Test connection
ssh user@server1
```

**For sudo without password (on managed nodes):**
```bash
# Add user to sudoers
sudo visudo

# Add line:
username ALL=(ALL) NOPASSWD: ALL
```

---

## 3. Ansible Inventory

### 3.1 Simple Inventory

**Default inventory file:** `/etc/ansible/hosts`

**Create custom inventory:**
```ini
# inventory.ini

# Single host
webserver1.example.com

# Host with alias
web1 ansible_host=192.168.1.10

# Multiple hosts
192.168.1.11
192.168.1.12

# Group
[webservers]
web1.example.com
web2.example.com
web3.example.com

[databases]
db1.example.com
db2.example.com

# Group with variables
[webservers:vars]
ansible_user=ubuntu
ansible_port=22

# Group of groups
[production:children]
webservers
databases

# Host variables
[webservers]
web1 ansible_host=192.168.1.10 http_port=8080
web2 ansible_host=192.168.1.11 http_port=8081
```

### 3.2 Inventory Variables

**Common inventory variables:**
```ini
ansible_host=192.168.1.10              # IP or hostname
ansible_port=22                        # SSH port
ansible_user=ubuntu                    # SSH user
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_become=yes                     # use sudo
ansible_become_user=root               # sudo to user
ansible_python_interpreter=/usr/bin/python3
```

**Example inventory:**
```ini
# inventory.ini
[webservers]
web1 ansible_host=192.168.1.10 ansible_user=ubuntu
web2 ansible_host=192.168.1.11 ansible_user=ubuntu

[dbservers]
db1 ansible_host=192.168.1.20 ansible_user=centos ansible_become=yes

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

### 3.3 Testing Inventory

```bash
# List all hosts
ansible all -i inventory.ini --list-hosts

# List specific group
ansible webservers -i inventory.ini --list-hosts

# Ping all hosts
ansible all -i inventory.ini -m ping

# Ping specific group
ansible webservers -i inventory.ini -m ping

# Run command
ansible all -i inventory.ini -a "uptime"
ansible webservers -i inventory.ini -a "df -h"

# Use sudo
ansible all -i inventory.ini -b -a "systemctl status nginx"
```

---

## 4. Ad-Hoc Commands

**Ad-hoc commands** run single tasks without playbooks.

```bash
# Syntax: ansible <hosts> -m <module> -a "<arguments>"

# Ping all hosts
ansible all -m ping

# Command module (default)
ansible all -a "hostname"
ansible all -a "uptime"
ansible all -a "free -m"

# Shell module (supports pipes, redirects)
ansible all -m shell -a "cat /etc/os-release | grep PRETTY_NAME"

# Copy file
ansible webservers -m copy -a "src=/local/file dest=/remote/path"

# Install package (Ubuntu)
ansible all -m apt -a "name=nginx state=present" -b

# Install package (RHEL)
ansible all -m yum -a "name=httpd state=present" -b

# Start service
ansible all -m service -a "name=nginx state=started" -b

# Restart service
ansible all -m service -a "name=nginx state=restarted" -b

# Create user
ansible all -m user -a "name=john state=present" -b

# Create directory
ansible all -m file -a "path=/opt/app state=directory mode=0755" -b

# Gather facts
ansible all -m setup

# Specific fact
ansible all -m setup -a "filter=ansible_os_family"
```

---

## 5. Ansible Playbooks

### 5.1 Playbook Basics

**Playbook structure:**
```yaml
---
- name: Playbook description
  hosts: target_hosts
  become: yes                        # use sudo
  vars:
    variable_name: value
  tasks:
    - name: Task description
      module_name:
        parameter: value
```

**Simple playbook example:**
```yaml
# playbook-nginx.yml
---
- name: Install and start Nginx
  hosts: webservers
  become: yes
  
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
        update_cache: yes
    
    - name: Start Nginx service
      service:
        name: nginx
        state: started
        enabled: yes
    
    - name: Copy index.html
      copy:
        src: files/index.html
        dest: /var/www/html/index.html
        mode: '0644'
```

**Run playbook:**
```bash
ansible-playbook -i inventory.ini playbook-nginx.yml

# Check mode (dry run)
ansible-playbook -i inventory.ini playbook-nginx.yml --check

# Verbose output
ansible-playbook -i inventory.ini playbook-nginx.yml -v
ansible-playbook -i inventory.ini playbook-nginx.yml -vv
ansible-playbook -i inventory.ini playbook-nginx.yml -vvv

# Limit to specific hosts
ansible-playbook -i inventory.ini playbook-nginx.yml --limit web1

# Start at specific task
ansible-playbook -i inventory.ini playbook-nginx.yml --start-at-task="Start Nginx service"
```

### 5.2 Variables

**Define variables:**
```yaml
---
- name: Variables example
  hosts: webservers
  vars:
    http_port: 80
    max_clients: 200
    app_version: "1.2.3"
  
  tasks:
    - name: Display variable
      debug:
        msg: "HTTP port is {{ http_port }}"
```

**Variable files:**
```yaml
# vars/main.yml
http_port: 80
app_name: myapp
db_host: db.example.com
```

```yaml
# playbook.yml
---
- name: Use variable file
  hosts: webservers
  vars_files:
    - vars/main.yml
  
  tasks:
    - name: Show app name
      debug:
        msg: "Application: {{ app_name }}"
```

**Facts (auto-gathered variables):**
```yaml
---
- name: Use facts
  hosts: all
  
  tasks:
    - name: Display OS family
      debug:
        msg: "OS is {{ ansible_os_family }}"
    
    - name: Display IP address
      debug:
        msg: "IP: {{ ansible_default_ipv4.address }}"
    
    - name: Display hostname
      debug:
        msg: "Hostname: {{ ansible_hostname }}"
```

**Register variables:**
```yaml
---
- name: Register example
  hosts: webservers
  
  tasks:
    - name: Check if file exists
      stat:
        path: /etc/nginx/nginx.conf
      register: nginx_conf
    
    - name: Display result
      debug:
        msg: "Nginx config exists: {{ nginx_conf.stat.exists }}"
    
    - name: Create file if not exists
      file:
        path: /etc/nginx/nginx.conf
        state: touch
      when: not nginx_conf.stat.exists
```

### 5.3 Conditionals

```yaml
---
- name: Conditionals example
  hosts: all
  become: yes
  
  tasks:
    - name: Install Apache (Ubuntu)
      apt:
        name: apache2
        state: present
      when: ansible_os_family == "Debian"
    
    - name: Install Apache (RHEL)
      yum:
        name: httpd
        state: present
      when: ansible_os_family == "RedHat"
    
    - name: Restart service if changed
      service:
        name: nginx
        state: restarted
      when: nginx_config.changed
```

**Multiple conditions:**
```yaml
when: ansible_os_family == "Debian" and ansible_distribution_version == "20.04"
when: ansible_memtotal_mb > 4096
when: inventory_hostname in groups['webservers']
```

### 5.4 Loops

```yaml
---
- name: Loops example
  hosts: webservers
  become: yes
  
  tasks:
    - name: Install multiple packages
      apt:
        name: "{{ item }}"
        state: present
      loop:
        - nginx
        - git
        - curl
        - vim
    
    - name: Create multiple users
      user:
        name: "{{ item.name }}"
        state: present
        groups: "{{ item.groups }}"
      loop:
        - { name: 'alice', groups: 'sudo' }
        - { name: 'bob', groups: 'developers' }
        - { name: 'charlie', groups: 'users' }
    
    - name: Create directories
      file:
        path: "/opt/{{ item }}"
        state: directory
        mode: '0755'
      loop:
        - app
        - logs
        - config
```

### 5.5 Handlers

**Handlers** run only when notified and only once at the end.

```yaml
---
- name: Handlers example
  hosts: webservers
  become: yes
  
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
    
    - name: Copy Nginx config
      copy:
        src: files/nginx.conf
        dest: /etc/nginx/nginx.conf
      notify: Restart Nginx
    
    - name: Copy site config
      template:
        src: templates/site.conf.j2
        dest: /etc/nginx/sites-available/mysite
      notify:
        - Restart Nginx
        - Reload Firewall
  
  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
    
    - name: Reload Firewall
      command: ufw reload
```

### 5.6 Templates

**Jinja2 templates** (`.j2` files) allow dynamic content.

**Template file (templates/nginx-site.conf.j2):**
```jinja2
server {
    listen {{ http_port }};
    server_name {{ server_name }};
    root {{ document_root }};
    
    location / {
        proxy_pass http://{{ backend_host }}:{{ backend_port }};
    }
}
```

**Playbook:**
```yaml
---
- name: Template example
  hosts: webservers
  become: yes
  vars:
    http_port: 80
    server_name: example.com
    document_root: /var/www/html
    backend_host: 192.168.1.100
    backend_port: 8080
  
  tasks:
    - name: Deploy Nginx config from template
      template:
        src: templates/nginx-site.conf.j2
        dest: /etc/nginx/sites-available/mysite
      notify: Restart Nginx
  
  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

---

## 6. Ansible Roles

**Roles** organize playbooks into reusable components.

### 6.1 Role Structure

```
roles/
└── nginx/
    ├── tasks/
    │   └── main.yml          # tasks to execute
    ├── handlers/
    │   └── main.yml          # handlers
    ├── templates/
    │   └── nginx.conf.j2     # templates
    ├── files/
    │   └── index.html        # static files
    ├── vars/
    │   └── main.yml          # variables
    ├── defaults/
    │   └── main.yml          # default variables
    ├── meta/
    │   └── main.yml          # role metadata
    └── README.md
```

### 6.2 Create a Role

```bash
# Create role structure
ansible-galaxy init nginx

# Or manually
mkdir -p roles/nginx/{tasks,handlers,templates,files,vars,defaults,meta}
```

**roles/nginx/tasks/main.yml:**
```yaml
---
- name: Install Nginx
  apt:
    name: nginx
    state: present
    update_cache: yes

- name: Copy Nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: Restart Nginx

- name: Ensure Nginx is running
  service:
    name: nginx
    state: started
    enabled: yes
```

**roles/nginx/handlers/main.yml:**
```yaml
---
- name: Restart Nginx
  service:
    name: nginx
    state: restarted
```

**roles/nginx/defaults/main.yml:**
```yaml
---
nginx_port: 80
nginx_user: www-data
worker_processes: auto
```

**roles/nginx/templates/nginx.conf.j2:**
```jinja2
user {{ nginx_user }};
worker_processes {{ worker_processes }};

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    server {
        listen {{ nginx_port }};
        server_name _;
        root /var/www/html;
    }
}
```

### 6.3 Use Roles in Playbook

```yaml
# playbook-web.yml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  
  roles:
    - nginx
    - common
    - firewall
```

**With role variables:**
```yaml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  
  roles:
    - role: nginx
      vars:
        nginx_port: 8080
        worker_processes: 4
```

---

## 7. Real-World Examples

### 7.1 Full LAMP Stack Deployment

```yaml
# playbook-lamp.yml
---
- name: Deploy LAMP stack
  hosts: webservers
  become: yes
  vars:
    mysql_root_password: "SecurePass123!"
    db_name: myapp
    db_user: appuser
    db_password: "AppPass456!"
  
  tasks:
    # Apache
    - name: Install Apache
      apt:
        name: apache2
        state: present
        update_cache: yes
    
    - name: Start Apache
      service:
        name: apache2
        state: started
        enabled: yes
    
    # MySQL
    - name: Install MySQL
      apt:
        name:
          - mysql-server
          - python3-pymysql
        state: present
    
    - name: Start MySQL
      service:
        name: mysql
        state: started
        enabled: yes
    
    - name: Create database
      mysql_db:
        name: "{{ db_name }}"
        state: present
        login_unix_socket: /var/run/mysqld/mysqld.sock
    
    - name: Create database user
      mysql_user:
        name: "{{ db_user }}"
        password: "{{ db_password }}"
        priv: "{{ db_name }}.*:ALL"
        state: present
        login_unix_socket: /var/run/mysqld/mysqld.sock
    
    # PHP
    - name: Install PHP
      apt:
        name:
          - php
          - php-mysql
          - libapache2-mod-php
        state: present
      notify: Restart Apache
    
    - name: Deploy application
      copy:
        src: files/index.php
        dest: /var/www/html/index.php
      notify: Restart Apache
  
  handlers:
    - name: Restart Apache
      service:
        name: apache2
        state: restarted
```

### 7.2 Security Hardening

```yaml
# playbook-security.yml
---
- name: Security hardening
  hosts: all
  become: yes
  
  tasks:
    - name: Update all packages
      apt:
        upgrade: dist
        update_cache: yes
    
    - name: Install security tools
      apt:
        name:
          - ufw
          - fail2ban
          - unattended-upgrades
        state: present
    
    - name: Configure UFW
      ufw:
        rule: allow
        port: "{{ item }}"
      loop:
        - "22"
        - "80"
        - "443"
    
    - name: Enable UFW
      ufw:
        state: enabled
    
    - name: Start fail2ban
      service:
        name: fail2ban
        state: started
        enabled: yes
    
    - name: Disable root SSH login
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PermitRootLogin'
        line: 'PermitRootLogin no'
      notify: Restart SSH
    
    - name: Disable password authentication
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PasswordAuthentication'
        line: 'PasswordAuthentication no'
      notify: Restart SSH
  
  handlers:
    - name: Restart SSH
      service:
        name: sshd
        state: restarted
```

### 7.3 Docker Container Deployment

```yaml
# playbook-docker.yml
---
- name: Deploy Docker containers
  hosts: docker_hosts
  become: yes
  
  tasks:
    - name: Install Docker
      apt:
        name:
          - docker.io
          - python3-docker
        state: present
        update_cache: yes
    
    - name: Start Docker service
      service:
        name: docker
        state: started
        enabled: yes
    
    - name: Pull nginx image
      docker_image:
        name: nginx
        tag: latest
        source: pull
    
    - name: Run nginx container
      docker_container:
        name: web
        image: nginx:latest
        state: started
        restart_policy: always
        ports:
          - "80:80"
        volumes:
          - /opt/website:/usr/share/nginx/html:ro
```

---

## 8. Best Practices

### 8.1 Playbook Organization

```bash
project/
├── ansible.cfg                 # Ansible configuration
├── inventory/
│   ├── production              # Production inventory
│   ├── staging                 # Staging inventory
│   └── group_vars/
│       ├── all.yml             # Variables for all hosts
│       ├── webservers.yml      # Variables for webservers
│       └── databases.yml
├── roles/
│   ├── common/
│   ├── nginx/
│   ├── mysql/
│   └── app/
├── playbooks/
│   ├── site.yml                # Main playbook
│   ├── webservers.yml
│   └── databases.yml
├── files/
├── templates/
└── README.md
```

### 8.2 Security Best Practices

```yaml
✓ Use Ansible Vault for sensitive data
✓ Use variables for passwords (don't hardcode)
✓ Use SSH keys (not passwords)
✓ Limit become (sudo) usage
✓ Use role-based access control
✓ Version control playbooks (Git)
✓ Test in staging before production
✓ Use --check mode before applying
✓ Keep Ansible updated
✓ Use specific module versions
```

**Ansible Vault example:**
```bash
# Encrypt file
ansible-vault encrypt vars/secrets.yml

# Decrypt
ansible-vault decrypt vars/secrets.yml

# Edit encrypted file
ansible-vault edit vars/secrets.yml

# Run playbook with vault
ansible-playbook playbook.yml --ask-vault-pass

# Or with password file
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass
```

---

## 9. Practice Exercises

1. **Basic Playbook:**
   - Create inventory with 3 servers
   - Write playbook to install nginx
   - Configure and start nginx service
   - Deploy custom index.html

2. **Multi-tier Application:**
   - Deploy web servers (nginx)
   - Deploy app servers (nodejs)
   - Deploy database (MySQL)
   - Use variables and templates

3. **Role Creation:**
   - Create role for common tasks
   - Create role for web server
   - Use roles in playbook
   - Share role on Ansible Galaxy

4. **Security Automation:**
   - Harden SSH configuration
   - Configure firewall rules
   - Install and configure fail2ban
   - Enable automatic security updates

5. **Infrastructure as Code:**
   - Manage complete environment with Ansible
   - Use inventory groups (dev/staging/prod)
   - Implement continuous deployment
   - Version control all configs

---

Next: **Linux 28 – Samba & File Sharing** for Windows integration and network file services.
