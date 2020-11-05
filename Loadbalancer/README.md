### Setup a Load balancer using SSL passthrough with 3 backend Droplets



User accessing "LB1.CJAIN.BIZ" -> Internet -> DigitalOcean Load balancer -> 3 Backend Droplets

### Steps:
```
1) Create 3 backend Droplets -> Setup webserver
2) Create a DigitalOcean LB
3) Create a DNS record on domain pointing to DigitalOcean LB
```


#### 1) Create 3 backend Droplets (Using [Cloud Panel](https://cloud.digitalocean.com/droplets/new) | [API](https://developers.digitalocean.com/documentation/v2/#create-a-new-droplet) | [DOCTL](https://www.digitalocean.com/community/tutorials/how-to-use-doctl-the-official-digitalocean-command-line-client)):

Examples:

**DOCTL:** ```doctl compute droplet create Backend-4 --size s-2vcpu-4gb  --image ubuntu-18-04-x64 --region blr1 --ssh-keys 6359694```

API: 
```
curl -X POST -H “Content-Type: application/json” -H “Authorization: Bearer 71d852c58e91ec83d5ae6f7286d4902990f4875f73a72786a3b76b74b4937a94” -d ‘{“name”:“test”,“region”:“nyc1",“size”:“s-8vcpu-32gb",“image”:“ubuntu-16-04-x64",“backups”:false,“ipv6":true,“user_data”:null,“private_networking”:true,“volumes”: null,“tags”:null}’ “https://api.digitalocean.com/v2/droplets”
```

#### Setup webserver 

```
1. sudo apt update
2. apt install nginx
3. sudo mkdir -p /var/www/dl.cjain.biz/html
4. sudo chmod -R 755 /var/www/dl.cjain.biz
5. sudo vim /var/www/dl.cjain.biz/html/index.html 
6. sudo vim /etc/nginx/sites-available/dl.cjain.biz
7. sudo ln -s /etc/nginx/sites-available/dl.cjain.biz /etc/nginx/sites-enabled/
8. sudo vim /etc/nginx/nginx.conf (Uncomment hash_bucket)
9. sudo nginx -t
10. sudo systemctl restart nginx
```

Configuration block #5:

```
server {
        listen 80;
        listen [::]:80;

        root /var/www/example.com/html;
        index index.html index.htm index.nginx-debian.html;

        server_name dl.cjain.biz www.dl.cjain.biz;

        location / {
                try_files $uri $uri/ =404;
        }
}
```

##### Create a SSL certificate using Let's encrypt (for passthrough):
```
1) sudo add-apt-repository ppa:certbot/certbot (Add repo)
2) sudo apt install python-certbot-nginx (Install certificate)
3) sudo certbot --nginx -d dl.cjain.biz -d www.example.com (Obtain the certificate) - Certbox will make all the configuration)
```
Follow guide for more details: https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04
