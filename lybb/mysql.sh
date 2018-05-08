#!/bin/bash
#sudo sh -c "echo > 3 /proc/sys/vm/drop_caches"
# sudo -v
url_mariadb=https://mirrors.tuna.tsinghua.edu.cn/mariadb//mariadb-10.2.14/bintar-linux-x86_64/mariadb-10.2.14-linux-x86_64.tar.gz
# https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-10.2.14/yum/centos74-amd64/rpms/
# cd bin
DATA_DIR=/docker/var/lib/mysql

echo "1. Config mysql"
sudo tee /etc/profile.d/mysql.sh >/dev/null << EOF
export PATH=\$PATH:/usr/local/mysql/bin
EOF
. /etc/profile.d/mysql.sh

sudo tee /etc/systemd/system/mariadb.service >/dev/null << EOF
# /etc/systemd/system/mariadb.service

[Unit]
Description=MariaDB 10.2.14 database server
Documentation=man:mysqld(8)
Documentation=https://mariadb.com/kb/en/library/systemd/
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target
Alias=mysql.service
Alias=mysqld.service

[Service]
User=mysql
Group=mysql

WorkingDirectory=/var/lib/mysql/
PIDFile=/var/run/mysqld/mysqld.pid
ExecStart=/usr/share/mysql/bin/mysqld --defaults-file=/etc/my.cnf
ExecStop=/bin/kill -s QUIT $MAINPID
ExecReload=/bin/kill -s HUP $MAINPID

# We rely on systemd, not mysqld_safe, to restart mysqld if it dies
Restart=always

# Place temp files in a secure directory, not /tmp
PrivateTmp=true
EOF

sudo tee /etc/my.cnf >/dev/null<< EOF
[client]
default-character-set = utf8
socket = /var/run/mysqld/mysqld.sock
[mysqld]
datadir = $DATA_DIR
socket   = /var/run/mysqld/mysqld.sock
pid-file = /var/run/mysqld/mysqld.pid
[server]
#server-id = 2
#read_only=ON                 # slave从库只读
log_bin=master-binlog              
binlog_format = ROW                
log-bin-trust-function-creators=1  
max_binlog_size = 256M             
expire_logs_days = 7               
innodb_flush_log_at_trx_commit = 0 
sync_binlog = 0                    
binlog-ignore-db = test
binlog-ignore-db = mysql
binlog-ignore-db = information_schema
binlog-ignore-db = performance_schema

[server]
log-slave-updates = ON        
slave-skip-errors = ALL
slave-skip-errors = 1007,1008,1053,1062,1213,1158,1159    
relay_log_recovery=ON        
replicate-ignore-db = mysql
replicate-ignore-db = information_schema
replicate-ignore-db = performance_schema
[mysqld]
user = mysql
port = 3306
bind-address= 0.0.0.0
lower_case_table_names = 1      
default_storage_engine = InnoDB 
innodb_buffer_pool_size = 6G    
innodb_force_recovery=1
performance_schema = OFF     
skip-external-locking        
general_log = OFF   
slow_query_log = ON 
long_query_time = 5 
wait_timeout =86400
interactive_timeout=86400
character_set_server = utf8
collation_server     = utf8_general_ci
init_connect='SET collation_connection = utf8_general_ci'
init-connect='SET NAMES utf8'
back_log = 512          
open_files_limit = 8192
max_connections = 2000   
max_connect_errors = 100 
concurrent_insert = 2    
read_buffer_size = 16M    
read_rnd_buffer_size = 16M    
binlog_cache_size = 1M      
key_buffer_size = 256M      
join_buffer_size = 64M    
sort_buffer_size = 64M
query_cache_type = on         
query_cache_size = 2G
query_cache_limit= 2M         
tmp_table_size = 1G        
max_heap_table_size = 1G
bulk_insert_buffer_size  = 256M 
max_allowed_packet = 256M 
innodb_thread_concurrency = 0     
innodb_commit_concurrency = 16    
innodb_log_files_in_group = 3     
innodb_log_file_size = 512M       
innodb_log_buffer_size = 128M     
EOF

echo "1. Install mariadb "
# mariadb="mariadb-10.2.14-linux-glibc_214-x86_64"
mariadb="mariadb-10.2.14-linux-x86_64"
[ -e bin/$mariadb.tar.gz ] || curl -o bin/$mariadb $url_mariadb
[ -e bin/$mariadb.tar.gz ] && [ -d /usr/local/$mariadb ] || sudo tar zxf bin/$mariadb.tar.gz -C /usr/local/
sudo rm -fr /usr/local/mysql && sudo ln -sf /usr/local/$mariadb  /usr/local/mysql
sudo rm -fr /usr/share/mysql && sudo ln -sf /usr/local/$mariadb  /usr/share/mysql
# sudo ln -sf /usr/share/mysql/bin/mysql  /usr/bin/mysql
# sudo ln -sf /usr/share/mysql/bin/mysqld  /usr/bin/mysqld
sudo update-alternatives --install /usr/bin/mysql mysql /usr/share/mysql/bin/mysql 200000
sudo update-alternatives --install /usr/bin/mysqld mysqld /usr/share/mysql/bin/mysqld 200000

echo "2. add user mysql"
# sudo groupadd -r -g 999 mysql && sudo useradd -r -u 999 -g mysql -c mysql -d /var/lib/mysql -s /sbin/nologin mysql
id mysql || {
    sudo groupadd -r -g 27 mysql && sudo useradd -r -u 27 -g mysql -c mysql -d /var/lib/mysql -s /sbin/nologin mysql
} 

echo "3. prepare mysql directory"
sudo mkdir -p /var/run/mysqld && sudo chown -R mysql:mysql /var/run/mysqld 
sudo mkdir -p /var/log/mysql && sudo chown -R mysql:mysql /var/log/mysql
# sudo mkdir -p /var/lib/mysql && sudo chown -R mysql:mysql /var/lib/mysql 
sudo mkdir -p $DATA_DIR && sudo chown -R mysql:mysql $DATA_DIR 

[ -e /usr/share/mysql/errmsg.sys ] || sudo cp /usr/share/mysql/share/english/errmsg.sys /usr/share/mysql/errmsg.sys
# sudo chown mysql:mysql /usr/share/mysql/errmsg.sys

echo "4. initialize mysql db"
[ -e $DATA_DIR/mysql ] || sudo /usr/share/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/share/mysql/ --datadir=$DATA_DIR --ldata=$DATA_DIR
# [ -e /var/lib/mysql/ibdata1 ] || sudo /usr/share/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/share/mysql/ --datadir=/var/lib/mysql --ldata=/var/lib/mysql
[ -e /var/lib/mysql/mysql ] || sudo rm -rf /var/lib/mysql && sudo ln -sf $DATA_DIR /var/lib/mysql
# mysqld --initialize --user=mysql --basedir=/usr/share/mysql --datadir=$DATA_DIR/
# 初始化参数使用了--initialize-insecure，这样不会设置初始化root密码，如果是 --initialize的话，会随机生成一个密码，这个密码显示在安装过程最后

# sudo apt-get install libaio1
# mysqld --verbose --help
echo "5. start mysql"

# sudo cp mariadb.service /etc/systemd/system/mariadb.service
sudo systemctl daemon-reload
sudo systemctl enable mariadb
sudo systemctl restart mariadb

# sudo kill `cat /var/run/mysqld/mysqld.pid` ;
# sudo nohup /usr/share/mysql/bin/mysqld --basedir=/usr/share/mysql --datadir=/var/lib/mysql --user=mysql --bind-address='0.0.0.0' &
# sudo nohup /usr/share/mysql/bin/mysqld --defaults-file=/etc/my.cnf > /tmp/mysql.log 2>&1 &


clean(){
    rm -rf /etc/mysql /etc/my.cnf /var/run/mysqld /var/log/mysql /var/lib/mysql
}