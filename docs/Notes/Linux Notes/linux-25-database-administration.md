# Linux 25 – Database Administration (MySQL/PostgreSQL)

## 0. Goal of This Note

- Install and configure MySQL/MariaDB and PostgreSQL
- Manage database users and permissions
- Perform backups and recovery
- Optimize database performance
- Implement security best practices
- Set up replication and high availability

---

## 1. MySQL/MariaDB Administration

### 1.1 Installation

**Ubuntu/Debian:**
```bash
# MySQL
sudo apt update
sudo apt install mysql-server mysql-client

# MariaDB (MySQL fork, recommended)
sudo apt install mariadb-server mariadb-client

# Secure installation
sudo mysql_secure_installation
# - Set root password
# - Remove anonymous users
# - Disallow root remote login
# - Remove test database
```

**RHEL/CentOS/Rocky:**
```bash
# MariaDB
sudo dnf install mariadb-server mariadb

# MySQL 8.0
sudo dnf install mysql-server mysql

sudo systemctl start mariadb
sudo systemctl enable mariadb

sudo mysql_secure_installation
```

**Check version:**
```bash
mysql --version
mysqladmin --version

# Connect
sudo mysql -u root -p
```

### 1.2 MySQL Service Management

```bash
# systemd
sudo systemctl start mysql         # or mariadb
sudo systemctl stop mysql
sudo systemctl restart mysql
sudo systemctl status mysql
sudo systemctl enable mysql         # start on boot

# Check if running
sudo systemctl is-active mysql
sudo netstat -tlnp | grep 3306      # MySQL default port
```

### 1.3 MySQL Configuration

**Main config file:**
```bash
/etc/mysql/mysql.conf.d/mysqld.cnf    # Ubuntu/Debian
/etc/my.cnf                            # RHEL/CentOS
/etc/my.cnf.d/server.cnf              # MariaDB RHEL

# Edit config
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

**Important settings:**
```ini
[mysqld]
# Network
bind-address = 127.0.0.1              # localhost only (secure)
# bind-address = 0.0.0.0              # all interfaces (for remote)
port = 3306

# Performance
max_connections = 200
innodb_buffer_pool_size = 2G          # 70-80% of RAM for InnoDB
innodb_log_file_size = 512M
query_cache_size = 64M
tmp_table_size = 64M
max_heap_table_size = 64M

# Logging
log_error = /var/log/mysql/error.log
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2                   # queries > 2 seconds

# Binary logging (for replication)
log_bin = /var/log/mysql/mysql-bin.log
server_id = 1
binlog_expire_logs_days = 7

# Character set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Security
local_infile = 0                      # disable LOAD DATA LOCAL
skip_name_resolve                     # use IPs, not DNS
```

**Apply changes:**
```bash
sudo systemctl restart mysql

# Verify settings
mysql -u root -p -e "SHOW VARIABLES LIKE 'max_connections';"
mysql -u root -p -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size';"
```

### 1.4 User Management

**Connect to MySQL:**
```bash
sudo mysql -u root -p
# Or on fresh install (Ubuntu):
sudo mysql
```

**Create users:**
```sql
-- Create user (local only)
CREATE USER 'dbuser'@'localhost' IDENTIFIED BY 'StrongPassword123!';

-- Create user (remote access)
CREATE USER 'dbuser'@'%' IDENTIFIED BY 'StrongPassword123!';
CREATE USER 'dbuser'@'192.168.1.100' IDENTIFIED BY 'StrongPassword123!';

-- View users
SELECT User, Host FROM mysql.user;

-- Change password
ALTER USER 'dbuser'@'localhost' IDENTIFIED BY 'NewPassword456!';
SET PASSWORD FOR 'dbuser'@'localhost' = PASSWORD('NewPassword456!');

-- Delete user
DROP USER 'dbuser'@'localhost';

-- Rename user
RENAME USER 'olduser'@'localhost' TO 'newuser'@'localhost';
```

**Grant permissions:**
```sql
-- Grant all privileges on database
GRANT ALL PRIVILEGES ON mydb.* TO 'dbuser'@'localhost';

-- Grant specific privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON mydb.* TO 'dbuser'@'localhost';

-- Grant on all databases (superuser)
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;

-- Read-only user
GRANT SELECT ON mydb.* TO 'readonly'@'localhost';

-- Specific table
GRANT SELECT, UPDATE ON mydb.users TO 'appuser'@'localhost';

-- Reload privileges
FLUSH PRIVILEGES;

-- View privileges
SHOW GRANTS FOR 'dbuser'@'localhost';

-- Revoke privileges
REVOKE DELETE ON mydb.* FROM 'dbuser'@'localhost';
```

**Common privilege levels:**
```sql
-- Database administration
GRANT CREATE, DROP, INDEX, ALTER ON mydb.* TO 'dbadmin'@'localhost';

-- Application user
GRANT SELECT, INSERT, UPDATE, DELETE ON appdb.* TO 'appuser'@'localhost';

-- Backup user
GRANT SELECT, LOCK TABLES, SHOW VIEW, RELOAD ON *.* TO 'backup'@'localhost';

-- Replication user
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY 'ReplPassword!';
```

### 1.5 Database Operations

**Create and manage databases:**
```sql
-- List databases
SHOW DATABASES;

-- Create database
CREATE DATABASE mydb;
CREATE DATABASE mydb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Use database
USE mydb;

-- Show current database
SELECT DATABASE();

-- Drop database
DROP DATABASE mydb;

-- List tables
SHOW TABLES;

-- Show table structure
DESCRIBE tablename;
SHOW CREATE TABLE tablename;
```

**Example database setup:**
```sql
-- Create database
CREATE DATABASE ecommerce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user
CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'SecurePass123!';

-- Grant privileges
GRANT ALL PRIVILEGES ON ecommerce.* TO 'ecomuser'@'localhost';
FLUSH PRIVILEGES;

-- Verify
SHOW GRANTS FOR 'ecomuser'@'localhost';
```

### 1.6 Backup and Restore

**Logical backup (mysqldump):**
```bash
# Single database
mysqldump -u root -p mydb > mydb-backup.sql

# All databases
mysqldump -u root -p --all-databases > all-databases.sql

# With routines, triggers, events
mysqldump -u root -p --all-databases --routines --triggers --events > full-backup.sql

# Specific tables
mysqldump -u root -p mydb table1 table2 > tables-backup.sql

# Compressed backup
mysqldump -u root -p mydb | gzip > mydb-backup.sql.gz

# With timestamp
mysqldump -u root -p mydb > mydb-backup-$(date +%Y%m%d_%H%M%S).sql

# Lock tables for consistency
mysqldump -u root -p --single-transaction mydb > mydb-backup.sql
```

**Restore:**
```bash
# Restore database
mysql -u root -p mydb < mydb-backup.sql

# Restore compressed backup
gunzip < mydb-backup.sql.gz | mysql -u root -p mydb

# Create database first, then restore
mysql -u root -p -e "CREATE DATABASE mydb;"
mysql -u root -p mydb < mydb-backup.sql

# Restore all databases
mysql -u root -p < all-databases.sql
```

**Automated backup script:**
```bash
#!/bin/bash
# /usr/local/bin/mysql-backup.sh

# Configuration
USER="root"
PASS="YourPassword"            # Better: use .my.cnf
BACKUP_DIR="/backup/mysql"
RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup all databases
mysqldump -u $USER -p$PASS --all-databases --routines --triggers --events | \
    gzip > "$BACKUP_DIR/all-databases-$DATE.sql.gz"

# Backup individual databases
for DB in $(mysql -u $USER -p$PASS -e "SHOW DATABASES;" | grep -v -E "Database|information_schema|performance_schema|mysql|sys")
do
    mysqldump -u $USER -p$PASS --databases $DB | \
        gzip > "$BACKUP_DIR/$DB-$DATE.sql.gz"
done

# Delete old backups
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

# Log
echo "$(date): MySQL backup completed" >> "$BACKUP_DIR/backup.log"
```

**Schedule with cron:**
```bash
# Edit crontab
crontab -e

# Daily at 2 AM
0 2 * * * /usr/local/bin/mysql-backup.sh

# Make script executable
chmod +x /usr/local/bin/mysql-backup.sh
```

**Password-less backup (secure method):**
```bash
# Create .my.cnf
nano ~/.my.cnf

[client]
user=root
password=YourPassword

# Secure the file
chmod 600 ~/.my.cnf

# Now mysqldump works without -p
mysqldump mydb > backup.sql
```

### 1.7 Performance Tuning

**Monitor queries:**
```sql
-- Show processes
SHOW PROCESSLIST;
SHOW FULL PROCESSLIST;

-- Kill slow query
KILL 12345;  -- process ID

-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;

-- Query cache stats (MySQL 5.7, removed in 8.0)
SHOW STATUS LIKE 'Qcache%';

-- InnoDB status
SHOW ENGINE INNODB STATUS\G

-- Table status
SHOW TABLE STATUS FROM mydb;

-- Index usage
SHOW INDEX FROM tablename;
```

**Analyze queries:**
```sql
-- Explain query execution plan
EXPLAIN SELECT * FROM users WHERE email = 'user@example.com';

-- Analyze table
ANALYZE TABLE tablename;

-- Optimize table (defragment)
OPTIMIZE TABLE tablename;

-- Check table for errors
CHECK TABLE tablename;

-- Repair table
REPAIR TABLE tablename;
```

**Indexes:**
```sql
-- Create index
CREATE INDEX idx_email ON users(email);

-- Composite index
CREATE INDEX idx_name_email ON users(last_name, first_name, email);

-- Unique index
CREATE UNIQUE INDEX idx_unique_email ON users(email);

-- Full-text index
CREATE FULLTEXT INDEX idx_fulltext ON articles(title, content);

-- Show indexes
SHOW INDEX FROM users;

-- Drop index
DROP INDEX idx_email ON users;

-- Add index to existing table
ALTER TABLE users ADD INDEX idx_created (created_at);
```

**Performance monitoring commands:**
```bash
# Check MySQL status
mysqladmin -u root -p status
mysqladmin -u root -p extended-status
mysqladmin -u root -p variables

# Monitor in real-time
mysqladmin -u root -p -i 1 extended-status | grep -E "Threads_connected|Questions"

# Connection count
mysql -u root -p -e "SHOW STATUS LIKE 'Threads_connected';"

# Uptime
mysql -u root -p -e "SHOW STATUS LIKE 'Uptime';"
```

### 1.8 Replication Setup

**Master server configuration:**
```bash
# Edit /etc/mysql/mysql.conf.d/mysqld.cnf
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

```ini
[mysqld]
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = mydb                   # database to replicate
# binlog_ignore_db = testdb           # databases to exclude
bind-address = 0.0.0.0                # allow remote connections
```

```bash
sudo systemctl restart mysql
```

**Create replication user on master:**
```sql
-- On master
CREATE USER 'replicator'@'%' IDENTIFIED BY 'ReplPassword123!';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
FLUSH PRIVILEGES;

-- Lock tables and get binary log position
FLUSH TABLES WITH READ LOCK;
SHOW MASTER STATUS;
-- Note File and Position values (e.g., mysql-bin.000001, 12345)

-- In another session, backup database
-- mysqldump -u root -p mydb > mydb-backup.sql

-- Unlock tables
UNLOCK TABLES;
```

**Slave server configuration:**
```bash
# Edit /etc/mysql/mysql.conf.d/mysqld.cnf
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

```ini
[mysqld]
server-id = 2                         # unique ID
relay_log = /var/log/mysql/relay-bin
log_bin = /var/log/mysql/mysql-bin.log
read_only = 1                         # slave is read-only
```

```bash
sudo systemctl restart mysql
```

**Configure replication on slave:**
```sql
-- On slave
-- Restore backup first
-- mysql -u root -p mydb < mydb-backup.sql

-- Configure master connection
CHANGE MASTER TO
    MASTER_HOST='192.168.1.10',
    MASTER_USER='replicator',
    MASTER_PASSWORD='ReplPassword123!',
    MASTER_LOG_FILE='mysql-bin.000001',    # from SHOW MASTER STATUS
    MASTER_LOG_POS=12345;                  # from SHOW MASTER STATUS

-- Start replication
START SLAVE;

-- Check status
SHOW SLAVE STATUS\G
-- Look for:
-- Slave_IO_Running: Yes
-- Slave_SQL_Running: Yes
-- Seconds_Behind_Master: 0
```

**Test replication:**
```sql
-- On master
USE mydb;
CREATE TABLE repl_test (id INT, name VARCHAR(50));
INSERT INTO repl_test VALUES (1, 'Test');

-- On slave
USE mydb;
SELECT * FROM repl_test;
-- Should see the data
```

**Troubleshooting replication:**
```sql
-- Check slave status
SHOW SLAVE STATUS\G

-- Common issues:
-- 1. Slave_IO_Running: No -> connection issue
--    Check firewall, credentials, master IP

-- 2. Slave_SQL_Running: No -> SQL error on slave
--    Check Last_Error in slave status

-- Stop replication
STOP SLAVE;

-- Reset replication
RESET SLAVE;

-- Skip one error (use carefully!)
SET GLOBAL sql_slave_skip_counter = 1;
START SLAVE;
```

### 1.9 Security Best Practices

**Hardening checklist:**
```bash
# 1. Secure installation
sudo mysql_secure_installation

# 2. Disable root remote login
# In config: bind-address = 127.0.0.1

# 3. Use strong passwords
# 4. Principle of least privilege (minimal grants)
# 5. Remove anonymous users
# 6. Remove test databases
# 7. Use SSL/TLS for connections
# 8. Regular backups
# 9. Keep MySQL updated
# 10. Monitor logs
```

**SSL/TLS encryption:**
```bash
# Check if SSL is available
mysql -u root -p -e "SHOW VARIABLES LIKE '%ssl%';"

# Generate SSL certificates (if needed)
sudo mysql_ssl_rsa_setup

# Enable SSL in config
[mysqld]
require_secure_transport=ON
```

**Firewall rules:**
```bash
# Allow MySQL from specific IP
sudo ufw allow from 192.168.1.0/24 to any port 3306

# Or with iptables
sudo iptables -A INPUT -p tcp -s 192.168.1.0/24 --dport 3306 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 3306 -j DROP
```

**Audit logging:**
```sql
-- Enable general log (verbose, use temporarily)
SET GLOBAL general_log = 'ON';
SET GLOBAL general_log_file = '/var/log/mysql/general.log';

-- View log
tail -f /var/log/mysql/general.log

-- Disable when done
SET GLOBAL general_log = 'OFF';
```

---

## 2. PostgreSQL Administration

### 2.1 Installation

**Ubuntu/Debian:**
```bash
# Install PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib

# Check status
sudo systemctl status postgresql

# PostgreSQL version
psql --version
```

**RHEL/CentOS/Rocky:**
```bash
# Install PostgreSQL
sudo dnf install postgresql-server postgresql-contrib

# Initialize database
sudo postgresql-setup --initdb

# Start service
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 2.2 PostgreSQL Service Management

```bash
# Service control
sudo systemctl start postgresql
sudo systemctl stop postgresql
sudo systemctl restart postgresql
sudo systemctl status postgresql

# Check if running
sudo systemctl is-active postgresql
sudo netstat -tlnp | grep 5432       # PostgreSQL default port
```

### 2.3 PostgreSQL Configuration

**Main config files:**
```bash
/etc/postgresql/14/main/postgresql.conf    # Ubuntu (version 14)
/var/lib/pgsql/data/postgresql.conf        # RHEL

/etc/postgresql/14/main/pg_hba.conf        # Client authentication
/var/lib/pgsql/data/pg_hba.conf            # RHEL
```

**postgresql.conf settings:**
```bash
sudo nano /etc/postgresql/14/main/postgresql.conf
```

```ini
# Network
listen_addresses = 'localhost'        # or '*' for all interfaces
port = 5432

# Performance
max_connections = 200
shared_buffers = 256MB                # 25% of RAM
effective_cache_size = 1GB            # 50-75% of RAM
work_mem = 4MB
maintenance_work_mem = 64MB

# Logging
logging_collector = on
log_directory = '/var/log/postgresql'
log_filename = 'postgresql-%Y-%m-%d.log'
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_min_duration_statement = 1000     # log queries > 1 second

# Write-Ahead Log (WAL)
wal_level = replica                   # for replication
max_wal_senders = 3
wal_keep_size = 1GB
```

**pg_hba.conf (authentication):**
```bash
sudo nano /etc/postgresql/14/main/pg_hba.conf
```

```conf
# TYPE  DATABASE    USER        ADDRESS         METHOD

# Local connections
local   all         postgres                    peer
local   all         all                         md5

# IPv4 local
host    all         all         127.0.0.1/32    md5

# Allow from specific network
host    all         all         192.168.1.0/24  md5

# Replication
host    replication replicator  192.168.1.0/24  md5
```

**Apply changes:**
```bash
sudo systemctl reload postgresql

# Or restart for major changes
sudo systemctl restart postgresql
```

### 2.4 User and Database Management

**Connect as postgres user:**
```bash
# Switch to postgres user
sudo -i -u postgres

# Open psql
psql

# Or in one command
sudo -u postgres psql
```

**User management:**
```sql
-- Create user
CREATE USER dbuser WITH PASSWORD 'StrongPassword123!';

-- Create user with specific privileges
CREATE USER appuser WITH PASSWORD 'AppPass456!' 
    CREATEDB 
    NOCREATEROLE 
    LOGIN;

-- List users
\du

-- Grant superuser
ALTER USER dbuser WITH SUPERUSER;

-- Change password
ALTER USER dbuser WITH PASSWORD 'NewPassword789!';

-- Rename user
ALTER USER olduser RENAME TO newuser;

-- Delete user
DROP USER dbuser;

-- Create role (similar to user but without LOGIN)
CREATE ROLE readonly;
```

**Database management:**
```sql
-- List databases
\l

-- Create database
CREATE DATABASE mydb;

-- Create with owner
CREATE DATABASE mydb OWNER dbuser;

-- Create with template and encoding
CREATE DATABASE mydb 
    OWNER dbuser 
    ENCODING 'UTF8' 
    LC_COLLATE = 'en_US.UTF-8' 
    LC_CTYPE = 'en_US.UTF-8' 
    TEMPLATE template0;

-- Connect to database
\c mydb

-- Current database
SELECT current_database();

-- Drop database
DROP DATABASE mydb;

-- Rename database
ALTER DATABASE olddb RENAME TO newdb;
```

**Grant permissions:**
```sql
-- Grant all privileges on database
GRANT ALL PRIVILEGES ON DATABASE mydb TO dbuser;

-- Grant connect
GRANT CONNECT ON DATABASE mydb TO appuser;

-- Grant schema usage
GRANT USAGE ON SCHEMA public TO appuser;

-- Grant table privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO appuser;

-- Grant on specific table
GRANT SELECT ON users TO readonly_user;

-- Grant on all future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO appuser;

-- Revoke privileges
REVOKE DELETE ON users FROM appuser;

-- View privileges
\dp
\z tablename
```

**Example setup:**
```sql
-- Create database and user
CREATE USER webuser WITH PASSWORD 'WebPass123!';
CREATE DATABASE webdb OWNER webuser;

-- Grant privileges
\c webdb
GRANT ALL PRIVILEGES ON DATABASE webdb TO webuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO webuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO webuser;
```

### 2.5 Backup and Restore

**pg_dump (logical backup):**
```bash
# Single database
pg_dump mydb > mydb-backup.sql
pg_dump -U postgres mydb > mydb-backup.sql

# Compressed
pg_dump mydb | gzip > mydb-backup.sql.gz

# Custom format (faster restore, compressed)
pg_dump -Fc mydb > mydb-backup.dump

# Specific tables
pg_dump -t users -t orders mydb > tables-backup.sql

# Schema only
pg_dump -s mydb > schema-only.sql

# Data only
pg_dump -a mydb > data-only.sql

# With timestamp
pg_dump mydb > mydb-backup-$(date +%Y%m%d_%H%M%S).sql
```

**pg_dumpall (all databases):**
```bash
# All databases
sudo -u postgres pg_dumpall > all-databases.sql

# Only globals (roles and tablespaces)
pg_dumpall --globals-only > globals.sql
```

**Restore:**
```bash
# Restore SQL dump
psql mydb < mydb-backup.sql
sudo -u postgres psql mydb < mydb-backup.sql

# Restore compressed
gunzip < mydb-backup.sql.gz | psql mydb

# Restore custom format
pg_restore -d mydb mydb-backup.dump

# Restore with options
pg_restore -d mydb -v -c mydb-backup.dump
# -v: verbose
# -c: clean (drop objects before recreating)

# Create database and restore
sudo -u postgres psql -c "CREATE DATABASE mydb;"
sudo -u postgres psql mydb < mydb-backup.sql
```

**Automated backup script:**
```bash
#!/bin/bash
# /usr/local/bin/postgres-backup.sh

BACKUP_DIR="/backup/postgresql"
RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup all databases
sudo -u postgres pg_dumpall | gzip > "$BACKUP_DIR/all-databases-$DATE.sql.gz"

# Backup individual databases
for DB in $(sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'postgres';")
do
    DB=$(echo $DB | xargs)  # trim whitespace
    sudo -u postgres pg_dump -Fc "$DB" > "$BACKUP_DIR/$DB-$DATE.dump"
done

# Delete old backups
find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -delete

echo "$(date): PostgreSQL backup completed" >> "$BACKUP_DIR/backup.log"
```

### 2.6 Performance Tuning

**psql commands:**
```sql
-- Show all settings
SHOW ALL;

-- Specific setting
SHOW max_connections;
SHOW shared_buffers;

-- Current database size
SELECT pg_size_pretty(pg_database_size('mydb'));

-- Table sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;

-- Active connections
SELECT * FROM pg_stat_activity;

-- Kill connection
SELECT pg_terminate_backend(12345);  -- PID

-- Database statistics
SELECT * FROM pg_stat_database;
```

**Query analysis:**
```sql
-- Explain query plan
EXPLAIN SELECT * FROM users WHERE email = 'user@example.com';

-- Explain with execution
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';

-- Vacuum (clean up dead rows)
VACUUM users;
VACUUM FULL users;  -- more aggressive, locks table
VACUUM ANALYZE users;  -- also update statistics

-- Analyze (update statistics)
ANALYZE users;

-- Reindex
REINDEX TABLE users;
REINDEX DATABASE mydb;
```

**Indexes:**
```sql
-- Create index
CREATE INDEX idx_email ON users(email);

-- Unique index
CREATE UNIQUE INDEX idx_unique_email ON users(email);

-- Partial index
CREATE INDEX idx_active_users ON users(email) WHERE active = true;

-- Composite index
CREATE INDEX idx_name ON users(last_name, first_name);

-- B-tree index (default)
CREATE INDEX idx_created ON orders(created_at);

-- GIN index (full-text search)
CREATE INDEX idx_fulltext ON articles USING GIN(to_tsvector('english', content));

-- List indexes
\di

-- Show table indexes
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'users';

-- Drop index
DROP INDEX idx_email;
```

### 2.7 Replication Setup (Streaming Replication)

**Primary server configuration:**
```bash
# Edit postgresql.conf
sudo nano /var/lib/pgsql/data/postgresql.conf
```

```ini
wal_level = replica
max_wal_senders = 3
wal_keep_size = 1GB              # PostgreSQL 13+
# wal_keep_segments = 64         # PostgreSQL 12 and earlier
```

**Create replication user:**
```sql
-- On primary
CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD 'ReplPass123!';
```

**Configure pg_hba.conf:**
```bash
sudo nano /var/lib/pgsql/data/pg_hba.conf
```

```conf
# Allow replication from standby server
host    replication    replicator    192.168.1.20/32    md5
```

```bash
sudo systemctl restart postgresql
```

**Standby server setup:**
```bash
# Stop PostgreSQL on standby
sudo systemctl stop postgresql

# Backup and remove data directory
sudo mv /var/lib/pgsql/data /var/lib/pgsql/data.old

# Copy data from primary using pg_basebackup
sudo -u postgres pg_basebackup -h 192.168.1.10 -D /var/lib/pgsql/data -U replicator -P -v -R
# -h: primary host
# -D: data directory
# -U: replication user
# -P: show progress
# -v: verbose
# -R: write recovery configuration

# Start standby
sudo systemctl start postgresql
```

**Check replication status:**
```sql
-- On primary
SELECT * FROM pg_stat_replication;

-- On standby
SELECT * FROM pg_stat_wal_receiver;

-- Check if standby is in recovery mode
SELECT pg_is_in_recovery();
-- Should return 't' (true) on standby
```

---

## 3. Database Security Best Practices

### 3.1 MySQL Security Checklist

```bash
✓ Run mysql_secure_installation
✓ Use strong passwords (minimum 12 characters)
✓ Principle of least privilege (minimal grants)
✓ Bind to localhost or specific IP (not 0.0.0.0 if not needed)
✓ Disable root remote login
✓ Remove anonymous users
✓ Remove test databases
✓ Use SSL/TLS for connections
✓ Keep MySQL updated
✓ Regular backups
✓ Monitor logs for suspicious activity
✓ Use firewall to restrict access
✓ Encrypt sensitive data
✓ Audit user privileges regularly
```

### 3.2 PostgreSQL Security Checklist

```bash
✓ Use strong passwords
✓ Configure pg_hba.conf properly (md5 or scram-sha-256)
✓ Bind to localhost if no remote access needed
✓ Use SSL/TLS for connections
✓ Principle of least privilege
✓ Revoke public schema privileges
✓ Use separate roles for different applications
✓ Keep PostgreSQL updated
✓ Regular backups
✓ Monitor logs
✓ Use firewall
✓ Encrypt sensitive columns
✓ Audit user privileges
```

**Revoke public schema privileges:**
```sql
-- PostgreSQL: prevent all users from creating tables
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
```

---

## 4. Monitoring and Troubleshooting

### 4.1 MySQL Monitoring

```bash
# Real-time monitoring
mytop                            # requires mytop package
mysqladmin -u root -p -i 1 extended-status

# Check slow queries
sudo tail -f /var/log/mysql/slow.log

# Connection count
mysql -u root -p -e "SHOW STATUS LIKE 'Threads_connected';"

# Table locks
mysql -u root -p -e "SHOW OPEN TABLES WHERE In_use > 0;"
```

### 4.2 PostgreSQL Monitoring

```bash
# Active connections
sudo -u postgres psql -c "SELECT count(*) FROM pg_stat_activity;"

# Long-running queries
sudo -u postgres psql -c "
SELECT pid, now() - query_start AS duration, query 
FROM pg_stat_activity 
WHERE state = 'active' AND now() - query_start > interval '5 minutes';"

# Check logs
sudo tail -f /var/log/postgresql/postgresql-*.log
```

---

## 5. Practice Exercises

1. **MySQL Setup:**
   - Install MySQL/MariaDB
   - Run secure installation
   - Create database and user
   - Grant appropriate permissions

2. **PostgreSQL Setup:**
   - Install PostgreSQL
   - Configure remote access
   - Create database with owner
   - Configure pg_hba.conf

3. **Backups:**
   - Create backup script for MySQL
   - Create backup script for PostgreSQL
   - Schedule with cron
   - Test restore procedure

4. **Replication:**
   - Set up MySQL master-slave replication
   - Set up PostgreSQL streaming replication
   - Test failover
   - Monitor replication lag

5. **Performance:**
   - Analyze slow queries
   - Create appropriate indexes
   - Optimize configuration settings
   - Monitor resource usage

---

Next: **Linux 26 – Kubernetes Fundamentals** for container orchestration.
