# PHP Docker for dev

This project help to set up a local developing environment for php developer with
- Nginx
- PHP: 7.4, 8.0, 8.1
- MariaDB
- Redis
- Meilisearch
- Mailhog

So that, you can run multi php projects 
within containers from this project, no need to create docker/container for each project.

This project is build base on [Laravel Sail](https://laravel.com/docs/9.x/sail), so it inherits feature from Sail, and 
extend it a little

## Setup
- Install [Docker desktop](https://docs.docker.com/desktop/) on your computer
- This project build base on Laravel Sail, but it's NOT necessary to install Composer & Laravel Sail
- Download or clone code from this repository
- Copy ".env.example" to ".env" file
- Update new ".env" file
  - "SOURCE_DIRECTORY": path to your projects folder
- Depend on what you need, there are 3 version, which provides:
  - ```docker-composer.mini.yml```: web server (nginx + php) & mariadb
  - ```docker-composer.laravel.yml```: web server (nginx + php), mariadb & redis
  - ```docker-composer.full.yml```: web server (nginx + php), mariadb, redis, meilisearch & mailhog
  - ```docker-composer.yml```: same as full
  - Let copy content from the version you want and replace in ```docker-composer.yml```
- If you run this project on Windows, there are some notes at the bottom   

## Commands
1. Go to this folder
```shell
cd phpdocker4dev
```

2. Build images
```shell
./sail build
```

3. Start
```shell
./sail up

# Start & run in background
./sail up -d
```

4. Stop
```shell
./sail stop
```

5. Terminate
```shell
./sail down
```
> Your data won't be lost, let feel free terminate

6. Access web server
```
# with "sail" user
./sail bash

# with "root" user
./sail root
```


## Datatabase
1. Import sql files to database
- This will help create new database from your sql file, but it won't override exist database.
- Let copy your.sql files in "mysql/backup" folder and run command
```shell
./sail db-import
```

2. Backup database
- This will help to export databases into sql files, and store in "mysql/backup" files
- It will override existing sql files, so let be care
```shell
./sail db-backup
```
3. Access database
- You can access MariaDB database by any mysql client app, with account:
  - Host: ```localhost```, within PHP project
  - Port: ```3306``` or value you set for "DB_PORT" in .env file
  - Account: ```root```
  - Password: ```password``` or value you set for "DB_PASSWORD" in .env file
- In PHP projects, when it runs in container, the host should be ```mariadb```

## Configure Nginx for new site
Ex: You want to set up a php project name "laravelrock" with domain name "laravelrock.test":

1. Create new config file in "nginx" folder name "laravelrock"
```shell
server {
    listen 80;

    root /home/sail/laravelrock;
    # Should be "root /home/sail/laravelrock/public" if it is Laravel project
    
    # For HTTPS, if you want to support https uncomment 3 lines below
    # listen 443 ssl;
    # ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    # ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    index index.html index.htm index.php;

    server_name laravelrock.test;

    charset utf-8;

    location = /favicon.ico { log_not_found off; access_log off; }
    location = /robots.txt  { log_not_found off; access_log off; }

    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.0-fpm.sock;
    }

    error_page 404 /index.php;
}
```

2. Restart
```shell
./sail restart

Or just restart nginx
./sail root -c "service nginx restart"
```

3. Update your host file, map "laravelrock.test" to 127.0.0.1


4. HTTPS
- Uncomment 3 lines which config for https and restart nginx
- Add exception if browser show warning
- MacOS: you may need to trust the self-sign certificate in container 
  - Download certificate from
  - Update trust certificate [search by Google](https://www.google.com/search?q=macos+trust+self+signed+certificate)

## Some notice for Windows:
- It requires [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install), so let install WSL2 or WSL on your windows first
- Let install ```Ubuntu 20.04``` on WSL, or any linux distro you like
- On ```Ubuntu 20.04``` terminal 
  - Let install ```dos4unix```, it would help reformat files to unix format, you will need it after edit nginx config files, or docker-compose.yml file
    - Install: ```sudo apt-get install dos2unix```
    - Reformat file after edit: ```dos2unix docker-compose.yml```, or ```docker2unix nginx/[config-file]```
- On first run after build, nginx may not work properly, let restart it by ```./sail restart``` 