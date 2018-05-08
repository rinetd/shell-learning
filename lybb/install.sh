#!/bin/bash
#sudo sh -c "echo > 3 /proc/sys/vm/drop_caches"
package_jre=jre-8u171-linux-x64.tar.gz
package_tomcat=apache-tomcat-8.5.30.tar.gz
package_mariadb=mariadb-10.2.14-linux-systemd-x86_64.tar.gz
package_redis=redis-stable.tar.gz
url_jre=https://sdlc-esd.oracle.com/ESD6/JSCDL/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jre-8u171-linux-x64.tar.gz?GroupName=JSC&FilePath=/ESD6/JSCDL/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jre-8u171-linux-x64.tar.gz&BHost=javadl.sun.com&File=jre-8u171-linux-x64.tar.gz&AuthParam=1524052473_5076897c1ed25be16ec6a9f82abbb0af&ext=.gz
package_tomcat=https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-8/v8.5.30/bin/apache-tomcat-8.5.30.tar.gz
package_mariadb=https://mirrors.tuna.tsinghua.edu.cn/mariadb//mariadb-10.2.14/bintar-linux-systemd-x86_64/mariadb-10.2.14-linux-systemd-x86_64.tar.gz
package_redis=http://download.redis.io/releases/redis-stable.tar.gz

echo "Install Java"
 
sudo alternatives --install /usr/bin/java java /usr/local/java/jre1.8.0_171/bin/java 200000
 
sudo cat > /etc/profile.d/java.sh << EOF
 export JAVA_HOME=/usr/local/java/jre1.8.0_171
 export PATH=$PATH:$JAVA_HOME/bin
 export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
EOF
sudo chmod +x /etc/profile.d/java.sh
source /etc/profile.d/java.sh

echo "Install Tomcat8"


rm -rf /usr/share/tomcat8 && mkdir -p $CATALINA_HOME
tar zxf apache-tomcat-8.5.30.tar.gz 
mv apache-tomcat-8.5.30/* $CATALINA_HOME/
#rm -rf apache-tomcat-8.5.4/webapps/*
#rm -rf apache-tomcat-8.5.4/webapps/{docs,examples,manager,ROOT/*}
#rm -rf apache-tomcat-8.5.4/logs/*

sudo cat << EOF >> /etc/profile.d/tomcat.sh
#/usr/local/tomcat
NAME=tomcat8
# Directory where the Tomcat 8 binary distribution resides
# conf  lib  logs  webapps  work
export CATALINA_HOME=/usr/share/$NAME

# Directory for per-instance configuration files and webapps
# bin lib
CATALINA_BASE=/var/lib/$NAME

EOF

sudo chmod +x /etc/profile.d/tomcat.sh
source /etc/profile.d/tomcat.sh


echo "Install mariadb "
rm -fr /usr/local/mysql/
[ -d mariadb-10.2.14-linux-systemd-x86_64 ] || tar zxf mariadb-10.2.14-linux-systemd-x86_64.tar.gz
cp -r mariadb-10.2.14-linux-systemd-x86_64 /usr/local/mysql


sudo cat << EOF >> /etc/profile.d/mysql.sh
export PATH=$PATH:/usr/local/mysql/bin
EOF

chmod +x /etc/profile.d/mysql.sh
source /etc/profile.d/mysql.sh


echo "Install Redis "
cp redis-4.0.9-1.fc29.x86_64.rpm /usr/local
yum localinstall redis-4.0.9-1.fc29.x86_64.rpm
