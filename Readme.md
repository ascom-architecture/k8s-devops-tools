# K8S Containerized DevOps Toolkit

## Functionality & Instruction 

### Web Server

The web site can be reached using port 80 or 443. Modify the contents in the (redirected) folder /var/www/html. 
    
### MS SQL Client
    
There is a MS SQl Server client (mssql-tools18) installed. Use the command 'sqlcmd' to access a SQL Server instance.

Example: 

    sqlcmd -S HOSTNAME_OF_SQLSERVER -U USERNAME -P 'PASSWORD'


### TCP Proxy

The nginx instance can be used as a TCP proxy, for instance to access a remote SQL Server instance. Place configuration files in the (redirected) folder /etc/nginx/stream-conf.d.

## Runtime

### Docker

Example container creation:
   - Linux:

```
docker run -d --name k8s-devops-tools -p 50080:80 -p 50443:443 -p 50434:1433 -v $(pwd)/nginx/webroot:/var/www/html -v $(pwd)/nginx/sites-available:/etc/nginx/sites-available -v $(pwd)/nginx/sites-enabled:/etc/nginx/sites-enabled -v $(pwd)/nginx/conf.d:/etc/nginx/conf.d -v $(pwd)/nginx/stream-conf.d:/etc/nginx/stream-conf.d -v $(pwd)/nginx/certs:/etc/nginx/certs janben/k8s-devops-tools
```

   - Windows Powershell:

```
docker run -d --name k8s-devops-tools -p 50080:80 -p 50443:443 -p 50434:1433 -v ${PWD}/nginx/webroot:/var/www/html -v ${PWD}/nginx/sites-enabled:/etc/nginx/sites-enabled -v ${PWD}/nginx/sites-available:/etc/nginx/sites-available -v ${PWD}/nginx/conf.d:/etc/nginx/conf.d -v ${PWD}/nginx/stream-conf.d:/etc/nginx/stream-conf.d -v ${PWD}/nginx/certs:/etc/nginx/certs janben/k8s-devops-tools
```

### Kubernetes

Use the YAML files(s) located in the Kubernetes folder to deploy the container in a Kubernetes cluster.
