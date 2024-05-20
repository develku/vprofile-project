#!/bin/bash

# -----------------------------------------------
# Step 1: Install Required Packages
# -----------------------------------------------
sudo dnf install epel-release -y
sudo dnf install memcached -y

# -----------------------------------------------
# Step 2: Configure and Start Memcached
# -----------------------------------------------
sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl status memcached
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached

# -----------------------------------------------
# Step 3: Install and Configure Firewalld
# -----------------------------------------------
sudo yum install firewalld -y
sudo systemctl start firewalld
sudo systemctl enable firewalld

# -----------------------------------------------
# Step 4: Add Firewall Rules for Memcached
# -----------------------------------------------
firewall-cmd --add-port=11211/tcp
firewall-cmd --runtime-to-permanent
firewall-cmd --add-port=11111/udp
firewall-cmd --runtime-to-permanent

# -----------------------------------------------
# Step 5: Start Memcached with Custom Ports
# -----------------------------------------------
sudo memcached -p 11211 -U 11111 -u memcached -d