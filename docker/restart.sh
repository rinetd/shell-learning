#!/bin/bash
# root:jWRSnemgE
# ubuntu:ubuntu
sudo docker exec -i mariadb mysqldump -uroot -pLinyiBR@2017! zhijian>/docker/backupsql/`date -I`.sql

sudo docker rm -f mariadb;
sudo docker run --restart=always -d --name mariadb -p3306:3306 -v /docker/mysql:/var/lib/mysql rinetd/mariadb:10.1

## 导入数据库
# docker exec -it mariadb mysql -uroot -pLinyiBR@2017!
# GRANT ALL PRIVILEGES ON zhijian.* TO ‘zhijian’@’%’ IDENTIFIED BY ‘ZQ4oegjqZ’ WITH GRANT OPTION; FLUSH PRIVILEGES;
# docker exec -i mariadb mysql -uzhijian -pZQ4oegjqZ zhijian<init-db.sql
# docker exec -i mariadb mysql -uzhijian -pZQ4oegjqZ -e 'show variables like "%timeout%"';
# 00 5 * * * docker exec -i mariadb mysqldump -uroot -pLinyiBR@2017! zhijian>/docker/backup/`date -I`.sql
# docker exec -i mariadb mysql -uzhijian -pZQ4oegjqZ zhijian</docker/backup/2017-07-14.sql
## 
sudo docker rm -f tomcat;
sudo docker run --restart=always -d --name tomcat --link mariadb:mysql -p 80:8080 -v /docker/tomcat/webapps:/usr/local/tomcat/webapps -v /docker/tomcat/logs:/usr/local/tomcat/logs rinetd/tomcat:8.5
sleep 1
sudo docker exec -i mariadb mysql -uroot -pLinyiBR@2017! -e 'set global wait_timeout=36000';
sudo docker exec -i mariadb mysql -uzhijian -pZQ4oegjqZ -e 'show variables like "%timeout%"';
sleep 1
