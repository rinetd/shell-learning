#!/bin/bash

package_redis=redis-stable.tar.gz
REQUIREPASS="hr2018"

echo "Install Redis "
# cp redis-4.0.9-1.fc29.x86_64.rpm /usr/local && yum localinstall redis-4.0.9-1.fc29.x86_64.rpm 
yum  install bin/centos/redis-3.2.8-1.el7.x86_64.rpm bin/centos/jemalloc-3.6.0-1.el7.x86_64.rpm

sed -i "s/bind 127.0.0.1/#bind 127.0.0.1/g" /etc/redis/redis.conf

# sed -i "s/port 6379/port $CLIENTPORT/g" /etc/redis/redis.conf
sed -i "s/# requirepass foobared/requirepass $REQUIREPASS/g" /etc/redis/redis.conf


## slaveof <masterip> <masterport> => slaveof $MASTERHOST $MASTERPORT
if [ "$MASTERPORT" != "" ];then
    sed -i "s/# masterauth <master-password>/masterauth $REQUIREPASS/g" /etc/redis/redis.conf
    sed -i "s/# slaveof <masterip> <masterport>/slaveof $MASTERHOST $MASTERPORT/g" /etc/redis/redis.conf

fi

## appendfsync everysec => appendfsync $APPENDFSYNC
if [ "$APPENDFSYNC" != "" ];then
    sed -i "s/appendonly no/appendonly yes/g" /etc/redis.conf
    sed -i "s/appendfsync everysec/appendfsync $APPENDFSYNC/g" /etc/redis/redis.conf
fi


# sudo sed -i "s/appendonly .*/appendonly yes/g" /etc/redis/redis.conf
# sudo sed -i "s/# slaveof .*/slaveof $1 6379/g" /etc/redis/redis.conf
# sudo sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf 
# sudo sed -i 's/^\(daemonize .*\)$/# \1/' /etc/redis/redis.conf
# sudo sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf
# sudo sed -i 's/^\(logfile .*\)$/# \1/' /etc/redis/redis.conf