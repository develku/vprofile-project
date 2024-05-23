#!/bin/bash

# -----------------------------------------------
# Step 1: Install RabbitMQ and Erlang Repositories
# -----------------------------------------------
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash

# -----------------------------------------------
# Step 2: Update Yum Cache and Install RabbitMQ Server
# -----------------------------------------------
sudo yum makecache -y --disablerepo='*' --enablerepo='rabbitmq_rabbitmq-server'
sudo yum -y install rabbitmq-server
rpm -qi rabbitmq-server 

# -----------------------------------------------
# Step 3: Start and Enable RabbitMQ Service
# -----------------------------------------------
systemctl start rabbitmq-server
systemctl enable rabbitmq-server

# -----------------------------------------------
# Step 4: Configure RabbitMQ
# -----------------------------------------------
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo systemctl restart rabbitmq-server

# -----------------------------------------------
# Step 5: Install and Configure Firewalld
# -----------------------------------------------
sudo yum install firewalld -y
sudo systemctl start firewalld
sudo systemctl enable firewalld

# -----------------------------------------------
# Step 6: Add Firewall Rules for RabbitMQ
# -----------------------------------------------
firewall-cmd --add-port=5672/tcp
firewall-cmd --runtime-to-permanent