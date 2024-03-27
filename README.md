# vprofile-project

![workflow](/img/workflow_diagram.png)

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

![vagrant_status](/img/vagrant_status.png)

### 1.1 - Check the hosts file on db0

In a multi-machine environment, the hosts file on each machine should have the IP address and hostname of all the machines in the environment.

```bash
ssh db01
cat /etc/hosts # to check the hosts file
```

![hosts](/img/hosts.png)

### 1.2 - Check the ping for web01 from db01

To check the connectivity between the machines, we can use the ping command.

```bash
ping web01 -c 4 # to check the ping 4 times
```

![ping](/img/ping_web01.png)

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
