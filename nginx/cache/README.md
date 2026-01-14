In this setup nginx works as a local cache server for a remote web server.

# Server information:

laud@contentcache:~$ neofetch
            .-/+oossssoo+/-.               laud@contentcache.laud-media.com
        `:+ssssssssssssssssss+:`           --------------------------------
      -+ssssssssssssssssssyyssss+-         OS: Ubuntu 24.04.3 LTS x86_64
    .ossssssssssssssssssdMMMNysssso.       Host: OptiPlex 7040
   /ssssssssssshdmmNNmmyNMMMMhssssss/      Kernel: 6.8.0-90-generic
  +ssssssssshmydMMMMMMMNddddyssssssss+     Uptime: 1 hour, 4 mins
 /sssssssshNMMMyhhyyyyhmNMMMNhssssssss/    Packages: 797 (dpkg)
.ssssssssdMMMNhsssssssssshNMMMdssssssss.   Shell: bash 5.2.21
+sssshhhyNMMNyssssssssssssyNMMMysssssss+   Resolution: 640x480
ossyNMMMNyMMhsssssssssssssshmmmhssssssso   Terminal: /dev/pts/1
ossyNMMMNyMMhsssssssssssssshmmmhssssssso   CPU: Intel i3-6100 (4) @ 3.700GHz
+sssshhhyNMMNyssssssssssssyNMMMysssssss+   GPU: NVIDIA GeForce GTX 1050 Ti
.ssssssssdMMMNhsssssssssshNMMMdssssssss.   Memory: 323MiB / 7846MiB
 /sssssssshNMMMyhhyyyyhdNMMMNhssssssss/
  +sssssssssdmydMMMMMMMMddddyssssssss+
   /ssssssssssshdmNNNNmyNMMMMhssssss/
    .ossssssssssssssssssdMMMNysssso.
      -+sssssssssssssssssyyyssss+-
        `:+ssssssssssssssssss+:`
            .-/+oossssoo+/-.

# Nginx information:

sudo apt update
sudo apt install nginx

laud@contentcache:~$ sudo nginx -version
nginx version: nginx/1.24.0 (Ubuntu)


# Config files:

## nginx.conf 

DESC: Nginx main config file
PATH: /etc/nginx/nginx.conf

## proxy.conf

DESC: Site specific config
PATH: /etc/nginx/sites-available/proxy.conf


# Instructions:

## Enable site:

sudo ln -s /etc/nginx/sites-available/proxy.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

### Verify config: 

sudo nginx -t

### Service commands:

sudo systemctl start nginx
sudo systemctl reload nginx
sudo systemctl status nginx

### Read access log:

sudo tail -f /var/log/nginx/access.log
