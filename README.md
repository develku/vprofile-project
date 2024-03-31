# vprofile-project

![workflow](img/workflow_diagram.png)

## Table of Contents

- [vprofile-project](#vprofile-project)
  - [Table of Contents](#table-of-contents)
  - [Flow of Execution](#flow-of-execution)
  - [Prerequisites](#prerequisites)
  - [Profile Project Setup](#profile-project-setup)
    - [1 - Install hostmanager plugin](#1---install-hostmanager-plugin)
    - [1.1 - Check the hosts file on db0](#11---check-the-hosts-file-on-db0)
    - [1.2 - Check the ping for web01 from db01](#12---check-the-ping-for-web01-from-db01)
    - [1.3 - Check the all the ping for all the machines](#13---check-the-all-the-ping-for-all-the-machines)
  - [Setup Process](#setup-process)
    - [2.1 - MySQL Setup](#21---mysql-setup)
    - [2.2 - Memcache Setup](#22---memcache-setup)
    - [2.3 - RabbitMQ Setup](#23---rabbitmq-setup)
    - [2.4 - Tomcat Setup](#24---tomcat-setup)

---

## Flow of Execution

1. Clone Source Code (https://github.com/hkhcoder/vprofile-project)
2. cd into the vagrant dir
3. Bring up Vm’s
4. Validate
5. Setup All the services
   - Nginx: Web Service
   - Tomcat: Application Server
   - RabbitMQ: Broker/ Queuing Agent
   - Memcache: DB caching
   - ElasticSearch: Indexing/ Search service
   - MySQL: SQL Database
6. Verify from browser

## Prerequisites

- JDK 11
- Maven 3
- MySQL 8

---

## Profile Project Setup

### 1 - Install hostmanager plugin

**vagrant-hostmanager** is a Vagrant plugin that manages the /etc/hosts file on guest machines (and optionally the host). Its goal is to enable resolution of multi-machine environments deployed with a cloud provider where IP addresses are not known in advance.

**vagrant-vbguest** is a Vagrant plugin to keep your VirtualBox Guest Additions up to date.

```bash
vagrant plugin install vagrant-hostmanager
vagrant plugin install vagrant-vbguest
vagrant up # to bring up the VMs
vagrant status # to check the status of the VMso
```

![vagrant_status](img/vagrant_status.png)

### 1.1 - Check the hosts file on db0

In a multi-machine environment, the hosts file on each machine should have the IP address and hostname of all the machines in the environment.

```bash
ssh db01
cat /etc/hosts # to check the hosts file
```

![hosts](img/hosts.png)

### 1.2 - Check the ping for web01 from db01

To check the connectivity between the machines, we can use the ping command.

```bash
ping web01 -c 4 # to check the ping 4 times
```

![ping](img/ping_web01.png)

### 1.3 - Check the all the ping for all the machines

As we can check with the workflow, the connectivity between the machines is as follows:

1. db01 -> web01
2. web01 -> app01
3. app01 -> db01

```bash
vagrant ssh db01
ping web01 -c 4
exit

vagrant ssh web01
ping app01 -c 4
exit

vagrant ssh app01
ping db01 -c 4
exit
```

---

## Setup Process

1. MySQL (Database SVC)
2. Memcache (DB Caching SVC)
3. RabbitMQ (Broker/ Queue SVC)
4. Tomcat (Application SVC)
5. Nginx (Web SVC)

### 2.1 - MySQL Setup

**Login** to the db vm

```bash
vagrant ssh db01
sudo -i
cat /etc/hosts # to Verify Hosts entry.
yum update -y
```

**Install** Maria DB Package, git & Start the Service

```bash
yum install git mariadb-server -y # install git, mariadb-server
systemctl start mariadb
systemctl status mariadb # to check the status of the service
systemctl enable mariadb
```

**Run** mysql secure **installation** script.

```bash
mysql_secure_installation
```

1. Enter current password for root (enter for none):
   - Just press Enter, we do not have any password set for root user for MySQL.
2. Switch to unix_socket authentication [Y/n] Y
3. Change the root password? [Y/n] Y
   - setting the password for root user.
4. Remove anonymous users? [Y/n] Y
   - it means we are removing the anonymous users.
5. Disallow root login remotely? [Y/n] Y
   - it means we are disallowing the root login remotely.
   - it should be N ideally, but for the sake of this project, we are setting it to Y.
6. Remove test database and access to it? [Y/n] Y
   - it means we are removing the test database and access to it.
7. Reload privilege tables now? [Y/n] Y
   - it means we are reloading the privilege tables now. which means the changes we made will be reflected now.

<p align="center">
  <img src="img/maria_installation.png" width="50%">
</p>

**Set DB** name and users.

```bash
mysql -u root -p

or

mysql -u root -p'admin123'
```

- 'admin'@'%' grant all privilege on accounts database to the user admin at percent, percent means from remotely.
- FLUSH PRIVILEGES; to reflect the changes.

```sql
CREATE DATABASE accounts;
show databases;
grant all privileges on accounts.* To 'admin'@'%' identified by 'admin123';
FLUSH PRIVILEGES;
exit;
```

**Download** Source code & Initialize Database.

```bash
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
mysql -u root -padmin123 accounts < src/main/resources/db_backup.sql
mysql -u root -padmin123 accounts
```

**check** the table created in the accounts database.

```sql
show tables;
exit;
```

<img src="img/sql_table.png" width="40%">

**Done** with the MySQL setup. Restart mariadb-server.

```bash
sudo systemctl restart mariadb
systemctl status mariadb
```

Starting the **firewall** and **allowing** the mariadb to access from port 3306.

- 3306: MySQL Database Port

```bash
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --get-active-zones
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --reload
systemctl restart mariadb
```

---

### 2.2 - Memcache Setup

memcache is a high-performance, distributed memory object caching system, generic in nature, but intended for use in speeding up dynamic web applications by alleviating database load.

**Login** to the Memcache VM.

```bash
vagrant ssh mc01
sudo -i
cat /etc/hosts # to Verify Hosts entry.
```

**Install**, **Start** & **Enable** the **memcached** service on port 11211.

- Search and Replace, find 127.0.0.1, replace with 0.0.0.0 in this file
  Remember, some of the services are not allowed to be accessed from outside the machine, so we need to change the configuration file.
  For example in wordpress, Apache and MySQL on the same machine, so Apache can access MySQL,
  but if they're on different machines, MySQL does not allow Apache to access it.
  so Memcach or Tomcat will be connecting to Memcache from a different machine, remotely, remote connection.

```bash
sudo yum install memcached -y
sudo systemctl start memcached
sudo systemctl status memcached
sudo systemctl enable memcached
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
vim /etc/sysconfig/memcached # to check the changes
sudo systemctl restart memcached
```

<img src="img/memcached.png" width=50%>

**Starting** the **firewall** and **allowing** the memcached to access from **port 11211**.

- -p 11211: Memcache TCP Port
- -U 11111: Memcache UDP Port
- -d: Run as a daemon

```bash
# Permission to edit the file
sudo chmod 666 /etc/sysconfig/network-scripts/ifcfg-eth1

# add the TCP port to the permanent firewall rules
sudo firewall-cmd --add-port=11211/tcp --permanent

# add the UDP port to the permanent firewall rules
sudo firewall-cmd --add-port=11111/udp --permanent

# reload the firewall rules
sudo firewall-cmd --reload

# running as a daemon
sudo memcached -p 11211 -U 11111 -u memcached -d
```

---

### 2.3 - RabbitMQ Setup

Connecting to RabbitMQ from a different machine, remotely, remote connection.

```bash
vagrant ssh rmq01
sudo -i

# Verify Hosts entry.
cat /etc/hosts

# Update the system
yum update -y

# Disable SELinux on fedora
# Disabled for the sake of this project, not recommended for production
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

# Install Dependencies
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash
sudo yum clean all
sudo yum makecache
sudo yum install erlang -y

# Install Rabbitmq Server
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
sudo yum install rabbitmq-server -y

```

Start & Enable **RabbitMQ Service**

```bash
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo systemctl status rabbitmq-server
```

Config Change

```bash
# below command will create a file and add the configuration to it.
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
cat /etc/rabbitmq/rabbitmq.config

# add_user <username> <password>
sudo rabbitmqctl add_user test test

# set_user_tags <username> <tag>
sudo rabbitmqctl set_user_tags test administrator

# Fedora changes
firewall-cmd --add-port=5671/tcp --permanent
firewall-cmd --add-port=5672/tcp --permanent
firewall-cmd --reload

# Restart RabbitMQ
sudo systemctl restart rabbitmq-server

# reboot the rabbitmq
reboot

```

<img src="img/rabbit.png">

---

### 2.4 - Tomcat Setup
