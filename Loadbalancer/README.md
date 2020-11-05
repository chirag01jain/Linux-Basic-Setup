### Setup a Load balancer using SSL passthrough with 3 backend Droplets



User accessing "do.cjain.biz" -> Internet -> DigitalOcean Load balancer -> 3 Backend Droplets

### Steps:
```
1) Create 3 backend Droplets -> Setup webserver
2) Create a DigitalOcean LB
3) Create a DNS record on domain pointing to DigitalOcean LB
```


#### 1) Create 3 backend Droplets (Using [Cloud Panel](https://cloud.digitalocean.com/droplets/new) | [API](https://developers.digitalocean.com/documentation/v2/#create-a-new-droplet) | [DOCTL](https://www.digitalocean.com/community/tutorials/how-to-use-doctl-the-official-digitalocean-command-line-client)):

Examples:

**DOCTL:** ```doctl compute droplet create Backend-1 --size c-2-4gib --image ubuntu-18-04-x64 --region blr1 --ssh-keys 6359694```

API: 
```
curl -X POST -H “Content-Type: application/json” -H “Authorization: Bearer $TOKEN” -d ‘{“name”:“backend-1”,“region”:“brl1",“size”:“c-2-4gib",“image”:“ubuntu-18-04-x64",“backups”:false,“ipv6":true,“user_data”:null,“private_networking”:true,“volumes”: null,“tags”:null}’ “https://api.digitalocean.com/v2/droplets”
```

#### Setup webserver 

```
1. sudo apt update
2. apt install nginx
3. sudo mkdir -p /var/www/do.cjain.biz/html
4. sudo chmod -R 755 /var/www/do.cjain.biz
5. sudo vim /var/www/do.cjain.biz/html/index.html 
6. sudo vim /etc/nginx/sites-available/do.cjain.biz
7. sudo ln -s /etc/nginx/sites-available/do.cjain.biz /etc/nginx/sites-enabled/
8. sudo vim /etc/nginx/nginx.conf (Uncomment hash_bucket)
9. sudo nginx -t
10. sudo systemctl restart nginx
```

Configuration block #5:

```
server {
        listen 80;
        listen [::]:80;

        root /var/www/do.cjain.biz/html;
        index index.html index.htm index.nginx-debian.html;

        server_name do.cjain.biz www.do.cjain.biz;

        location / {
                try_files $uri $uri/ =404;
        }
}
```

##### Create a SSL certificate using Let's encrypt (for passthrough):
```
1) sudo add-apt-repository ppa:certbot/certbot (Add repo)
2) sudo apt install python-certbot-nginx (Install certificate)
3) sudo certbot --nginx -d do.cjain.biz (Obtain the certificate) - Certbox will make all the configuration)
```

Follow guide for more details: https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04


Once the Droplet is deployed with pre-requisites, snapshot and re-deploy it's replica for redundancy (Horizontal scaling).
