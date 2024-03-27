# import the required libraries
from diagrams import Cluster, Diagram
from diagrams.onprem.client import User, Users, Client
from diagrams.aws.network import ElasticLoadBalancing
from diagrams.onprem.network import Nginx, Apache, Tomcat
from diagrams.onprem.compute import Server
from diagrams.onprem.queue import Rabbitmq
# import memcache, elasticsearch, mysql.
from diagrams.onprem.inmemory import Memcached
from diagrams.onprem.database import Mysql

with Diagram("Workflow Diagram", show=False):
    with Cluster("Clients"):
        user = User("User")
        users = Users("Users")
        client = Client("Client")
        clients = [user, users, client]

    load_balancer = ElasticLoadBalancing("Load Balancer")
    nginx = Nginx("Nginx Server")

    with Cluster("Servers"):
        server = Server("Server1")
        apache = Apache("Apache")
        tomcat = Tomcat("Tomcat Server")
        server2 = Server("Server2")
        servers = [tomcat, server, server2, apache]

    rabbit_mq = Rabbitmq("RabbitMQ")
    memcached = Memcached("Memcached")
    mysql = Mysql("Mysql")

    for client in clients:
        client >> load_balancer >> nginx >> tomcat >> rabbit_mq >> memcached >> mysql
