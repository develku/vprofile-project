#!/bin/bash
DATABASE_PASS='admin123'

# -----------------------------------------------
# Step 1: Update System and Install Required Packages
# -----------------------------------------------
sudo yum update -y
sudo yum install epel-release -y
sudo yum install git zip unzip -y
sudo yum install mariadb-server -y

# -----------------------------------------------
# Step 2: Start and Enable MariaDB Service
# -----------------------------------------------
sudo systemctl start mariadb
sudo systemctl enable mariadb

# -----------------------------------------------
# Step 3: Clone the Project Repository
# -----------------------------------------------
cd /tmp/
git clone -b main https://github.com/hkhcoder/vprofile-project.git

# -----------------------------------------------
# Step 4: Configure MariaDB
# -----------------------------------------------
# Set up MariaDB root user password and database for the application
sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# -----------------------------------------------
# Step 5: Restart MariaDB Service
# -----------------------------------------------
sudo systemctl restart mariadb

# -----------------------------------------------
# Step 6: Configure Firewall
# -----------------------------------------------
# Install and start Firewalld, then allow MariaDB port 3306
sudo yum install firewalld -y
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload

# -----------------------------------------------
# Step 7: Final Restart of MariaDB Service
# -----------------------------------------------
sudo systemctl restart mariadb