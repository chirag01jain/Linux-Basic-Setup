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
3. sudo mkdir -p /var/www/lb1.cjain.biz/html
4. sudo chmod -R 755 /var/www/lb1.cjain.biz
5. sudo vim /var/www/lb1.cjain.biz/html/index.html 
6. sudo vim /etc/nginx/sites-available/lb1.cjain.biz
7. sudo ln -s /etc/nginx/sites-available/lb1.cjain.biz /etc/nginx/sites-enabled/
8. sudo vim /etc/nginx/nginx.conf
9. sudo nginx -t
10. sudo systemctl restart nginx
```

Follow guide for more details: https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04
