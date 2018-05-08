#! /usr/bin/sh

 #! /usr/bin/sh

CONFIG=~/backend.conf
INITSQL=~/lzkp_v4_20180507init.sql

if [[ ! -e $CONFIG ]]; then
echo "#NAME,PORT,SSH_HOST,SSH_PORT,SSH_USER,DB_HOST,DB_PORT,DB_USER,DB_PASSWORD,REDIS_HOST,REDIS_PASSWORD"
cat > $CONFIG << EOF
lanshanqu,1302,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
luozhuangqu,1311,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
hedongqu,1312,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
gaoxinqu,1313,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
jingkaiqu,1314,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
lingangqu,1315,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
yinan,1321,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
tancheng,1322,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
yishui,1323,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
lanling,1324,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
feixian,1325,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
pingyi,1326,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
junan,1327,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
mengyin,1328,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
linshu,1329,,,,10.114.0.14,3306,lzkp,yqhtfjzm,10.114.0.5,hangruan2018
EOF
fi

# IFS="$DELIM"
MYSQL=`which mysql`
MYSQLDUMP=`which mysqldump`
GZIP=`which gzip`
# 检测mysql是否安装
type mysql || echo "install mysql-client" || exit "please install mysql-client"
mysql_root_host=10.114.0.14
mysql_root_user=root
mysql_root_password=toor
MYROOTCMD="$MYSQL -h$mysql_root_host -u$mysql_root_user -p$mysql_root_password"


restart(){


    #PID=`sudo lsof -t -i:$port`
    #echo $PID
    [[ -z $name ]] && return "name is null"
    ## 2. 本地安装
    echo "1. create mysql user $DB_USER"
    MYCMD="$MYSQL -h$DB_HOST -u$DB_USER -p$DB_PASSWORD"
    $MYROOTCMD -N -e "GRANT ALL PRIVILEGES ON $name.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'; FLUSH PRIVILEGES;"
    echo "2. check DATABASE $name and import $INITSQL"
    $MYROOTCMD -N -e "use $name;" 2>/dev/null || {
    $MYROOTCMD -N -e "CREATE DATABASE IF NOT EXISTS $name DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci"
    $MYCMD $name<$INITSQL
    }

    ## 3. backend
    mkdir -p /tmp/$name

    LAST_PID=`cat /tmp/$name.pid`; kill $LAST_PID;

    nohup java -jar /docker/tomcat/lzkpv4/backendv4.jar --datasource.url="jdbc:mysql://${DB_HOST}:${DB_PORT}/${name}?useUnicode=true&characterEncoding=utf-8&useSSL=false" --server.port=$port $@>/tmp/$name/$name.log 2> /tmp/$name/$name.err < /dev/null &

    pid=$!
    echo $pid
    echo "$pid">/tmp/$name.pid

    ## gen nginx 
    # ## 4. lzkpv4
    # if [[ -z $name ]] || [[ -d  /docker/tomcat/lzkpv4/$name ]]; then
    #     echo rm -r /docker/tomcat/lzkpv4/$name
    #     rm -r /docker/tomcat/lzkpv4/$name
    # fi
    # cp -r /docker/tomcat/lzkpv4/ROOT /docker/tomcat/lzkpv4/$name
    # sed -i -e "s|.dbServerName=.*|.dbServerName=${DB_HOST}:${DB_PORT}|g" -e "s|.dbName=.*|.dbName=${name}|g" -e "s|.dbUser=.*|.dbUser=${DB_USER}|g" -e "s|.dbPws=.*|.dbPws=${DB_PASSWORD}|g" /docker/tomcat/lzkpv4/$name/WEB-INF/classes/utility/hrlzkp.properties
}


while IFS=', ' read -r name port ssh_host ssh_port ssh_user DB_HOST DB_PORT DB_USER DB_PASSWORD redis_host redis_password; do
    echo
    echo name          :   $name
    echo port          :   $port
    echo ssh_host      :   $ssh_host
    echo ssh_port      :   $ssh_port
    echo ssh_user      :   $ssh_user
    echo DB_HOST       :   $DB_HOST
    echo DB_PORT       :   $DB_PORT
    echo DB_USER       :   $DB_USER
    echo DB_PASSWORD   :   $DB_PASSWORD
    echo redis_host    :   $redis_host
    echo redis_password:   $redis_password
    [[ -z $name ]] || restart
done <"$CONFIG"
