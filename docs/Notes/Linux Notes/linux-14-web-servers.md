# Linux 14 – Web Servers (Apache & Nginx)

## 0. Goal of This Note

- Install and configure Apache HTTP Server.  
- Master Nginx configuration for web and reverse proxy.  
- Set up virtual hosts and SSL/TLS certificates.  
- Performance tuning and security hardening.  
- Load balancing basics.

---

## 1. Apache HTTP Server

### 1.1 Installation

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install apache2
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl status apache2

# Test
curl localhost
# Or open browser: http://localhost
```

**RHEL/Fedora:**
```bash
sudo dnf install httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

### 1.2 Apache Configuration Structure

**Debian/Ubuntu:**
```
/etc/apache2/
├── apache2.conf           # Main config
├── ports.conf             # Listen ports
├── mods-available/        # Available modules
├── mods-enabled/          # Enabled modules (symlinks)
├── sites-available/       # Available sites
├── sites-enabled/         # Enabled sites (symlinks)
└── conf-available/        # Additional configs
```

**RHEL/Fedora:**
```
/etc/httpd/
├── conf/
│   └── httpd.conf         # Main config
├── conf.d/                # Additional configs
└── conf.modules.d/        # Module configs
```

### 1.3 Basic Configuration

**Main config (apache2.conf or httpd.conf):**
```apache
# Server root
ServerRoot "/etc/apache2"

# Listen port
Listen 80

# Server name
ServerName www.example.com

# Document root (default site)
DocumentRoot "/var/www/html"

# Directory permissions
<Directory /var/www/html>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

# Log files
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined

# Keep-Alive
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5

# Timeout
Timeout 300
```

**Test configuration:**
```bash
sudo apache2ctl configtest
# Or
sudo apachectl configtest

# Reload config
sudo systemctl reload apache2
```

### 1.4 Virtual Hosts

**Name-based virtual hosts:**
```apache
# /etc/apache2/sites-available/example.com.conf
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    ServerAdmin admin@example.com
    DocumentRoot /var/www/example.com/public_html
    
    ErrorLog ${APACHE_LOG_DIR}/example.com-error.log
    CustomLog ${APACHE_LOG_DIR}/example.com-access.log combined
    
    <Directory /var/www/example.com/public_html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

**Enable site:**
```bash
# Create document root
sudo mkdir -p /var/www/example.com/public_html
sudo chown -R www-data:www-data /var/www/example.com

# Enable site
sudo a2ensite example.com.conf
sudo systemctl reload apache2

# Disable site
sudo a2dissite example.com.conf
```

### 1.5 Apache Modules

**Common modules:**
```bash
# Enable module
sudo a2enmod rewrite          # URL rewriting
sudo a2enmod ssl              # SSL/TLS
sudo a2enmod headers          # HTTP headers
sudo a2enmod proxy            # Proxy
sudo a2enmod proxy_http       # HTTP proxy
sudo a2enmod proxy_fcgi       # FastCGI proxy (for PHP-FPM)

# Disable module
sudo a2dismod module_name

# List enabled modules
apache2ctl -M
apachectl -M
```

**mod_rewrite example (.htaccess):**
```apache
RewriteEngine On

# Redirect www to non-www
RewriteCond %{HTTP_HOST} ^www\.example\.com [NC]
RewriteRule ^(.*)$ http://example.com/$1 [L,R=301]

# Remove .php extension
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME}.php -f
RewriteRule ^(.*)$ $1.php [L]

# Force HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

### 1.6 SSL/TLS Configuration

**Install certbot (Let's Encrypt):**
```bash
sudo apt install certbot python3-certbot-apache
sudo certbot --apache -d example.com -d www.example.com

# Auto-renewal
sudo certbot renew --dry-run
# Cron already set up by certbot
```

**Manual SSL config:**
```apache
<VirtualHost *:443>
    ServerName example.com
    DocumentRoot /var/www/example.com/public_html
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/example.com.crt
    SSLCertificateKeyFile /etc/ssl/private/example.com.key
    SSLCertificateChainFile /etc/ssl/certs/example.com-chain.crt
    
    # Security headers
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-XSS-Protection "1; mode=block"
    
    # TLS configuration
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite HIGH:!aNULL:!MD5
    SSLHonorCipherOrder on
</VirtualHost>
```

---

## 2. Nginx Web Server

### 2.1 Installation

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
```

**RHEL/Fedora:**
```bash
sudo dnf install nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 2.2 Nginx Configuration Structure

```
/etc/nginx/
├── nginx.conf             # Main config
├── sites-available/       # Available sites
├── sites-enabled/         # Enabled sites (symlinks)
├── conf.d/                # Additional configs
├── snippets/              # Reusable config snippets
└── modules-enabled/       # Enabled modules
```

### 2.3 Basic Configuration

**Main config (nginx.conf):**
```nginx
user www-data;
worker_processes auto;        # Auto-detect CPU cores
pid /run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;                # Linux-specific, efficient
}

http {
    # Basic settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;        # Hide nginx version
    
    # MIME types
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/atom+xml image/svg+xml;
    
    # Virtual hosts
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

**Test and reload:**
```bash
sudo nginx -t               # test configuration
sudo systemctl reload nginx
```

### 2.4 Server Blocks (Virtual Hosts)

**Basic server block:**
```nginx
# /etc/nginx/sites-available/example.com
server {
    listen 80;
    listen [::]:80;
    server_name example.com www.example.com;
    root /var/www/example.com;
    index index.html index.htm index.php;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # PHP processing
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
    
    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }
    
    # Logging
    access_log /var/log/nginx/example.com-access.log;
    error_log /var/log/nginx/example.com-error.log;
}
```

**Enable site:**
```bash
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 2.5 SSL/TLS with Nginx

**Let's Encrypt:**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d example.com -d www.example.com
```

**Manual SSL config:**
```nginx
server {
    listen 80;
    server_name example.com www.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name example.com www.example.com;
    root /var/www/example.com;
    
    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_prefer_server_ciphers off;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

### 2.6 Reverse Proxy

**Proxy to backend application:**
```nginx
server {
    listen 80;
    server_name app.example.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

**Load balancing:**
```nginx
upstream backend {
    least_conn;               # or: ip_hash, round_robin (default)
    server 192.168.1.10:3000 weight=3;
    server 192.168.1.11:3000;
    server 192.168.1.12:3000 backup;
}

server {
    listen 80;
    server_name app.example.com;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 2.7 Caching

**FastCGI cache (for PHP):**
```nginx
fastcgi_cache_path /var/cache/nginx levels=1:2 keys_zone=phpcache:100m inactive=60m;
fastcgi_cache_key "$scheme$request_method$host$request_uri";

server {
    # ...
    
    location ~ \.php$ {
        fastcgi_cache phpcache;
        fastcgi_cache_valid 200 60m;
        fastcgi_cache_bypass $http_cache_control;
        add_header X-FastCGI-Cache $upstream_cache_status;
        
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
}
```

**Proxy cache:**
```nginx
proxy_cache_path /var/cache/nginx/proxy levels=1:2 keys_zone=proxycache:100m max_size=1g inactive=60m;

server {
    location / {
        proxy_cache proxycache;
        proxy_cache_valid 200 1h;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        add_header X-Proxy-Cache $upstream_cache_status;
        
        proxy_pass http://backend;
    }
}
```

---

## 3. Performance Tuning

### 3.1 Apache Performance

**Enable MPM Event (better than prefork):**
```bash
sudo a2dismod mpm_prefork
sudo a2enmod mpm_event
```

**Configure MPM:**
```apache
# /etc/apache2/mods-available/mpm_event.conf
<IfModule mpm_event_module>
    StartServers             2
    MinSpareThreads          25
    MaxSpareThreads          75
    ThreadLimit              64
    ThreadsPerChild          25
    MaxRequestWorkers        150
    MaxConnectionsPerChild   0
</IfModule>
```

**Enable compression:**
```bash
sudo a2enmod deflate
```

### 3.2 Nginx Performance

**Worker optimization:**
```nginx
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}
```

**Buffer tuning:**
```nginx
http {
    client_body_buffer_size 128k;
    client_max_body_size 50m;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    output_buffers 1 32k;
    postpone_output 1460;
}
```

---

## 4. Security Hardening

### 4.1 Apache Security

```apache
# Hide version
ServerTokens Prod
ServerSignature Off

# Disable directory listing
Options -Indexes

# Disable .htaccess (if not needed)
AllowOverride None

# Restrict by IP
<Directory /admin>
    Require ip 192.168.1.0/24
</Directory>

# Rate limiting
<IfModule mod_ratelimit.c>
    <Location /download>
        SetOutputFilter RATE_LIMIT
        SetEnv rate-limit 400
    </Location>
</IfModule>
```

### 4.2 Nginx Security

```nginx
# Hide version
server_tokens off;

# Rate limiting
limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
limit_conn_zone $binary_remote_addr zone=addr:10m;

server {
    location /api/ {
        limit_req zone=one burst=5;
        limit_conn addr 10;
    }
}

# Block user agents
if ($http_user_agent ~* (bot|crawler|spider)) {
    return 403;
}

# Restrict methods
if ($request_method !~ ^(GET|HEAD|POST)$ ) {
    return 444;
}
```

---

## 5. Practice Exercises

1. **Apache:**
   - Install Apache
   - Create 2 virtual hosts
   - Set up SSL with Let's Encrypt
   - Enable mod_rewrite

2. **Nginx:**
   - Install Nginx
   - Configure server block
   - Set up reverse proxy to Node.js app
   - Enable caching

3. **Performance:**
   - Benchmark with `ab -n 1000 -c 10 http://localhost/`
   - Tune Apache/Nginx
   - Compare results

4. **Security:**
   - Implement rate limiting
   - Add security headers
   - Configure fail2ban for web server

Next: **Linux 15 – Git & Version Control** for source code management.
