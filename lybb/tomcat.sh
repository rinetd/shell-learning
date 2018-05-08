#!/bin/bash
# sudo sh -c "echo 3>/proc/sys/vm/drop_caches"
# bin_jre=jre-8u171-linux-x64.tar.gz
# bin_tomcat=apache-tomcat-8.5.30.tar.gz
# package_mariadb=mariadb-10.2.14-linux-systemd-x86_64.tar.gz
# package_redis=redis-stable.tar.gz
# url_jre=https://sdlc-esd.oracle.com/ESD6/JSCDL/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jre-8u171-linux-x64.tar.gz?GroupName=JSC&FilePath=/ESD6/JSCDL/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jre-8u171-linux-x64.tar.gz&BHost=javadl.sun.com&File=jre-8u171-linux-x64.tar.gz&AuthParam=1524052473_5076897c1ed25be16ec6a9f82abbb0af&ext=.gz
# package_tomcat=https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-8/v8.5.30/bin/apache-tomcat-8.5.30.tar.gz
# package_mariadb=https://mirrors.tuna.tsinghua.edu.cn/mariadb//mariadb-10.2.14/bintar-linux-systemd-x86_64/mariadb-10.2.14-linux-systemd-x86_64.tar.gz
# package_redis=http://download.redis.io/releases/redis-stable.tar.gz

# cd bin


jre="jre-8u171-linux-x64"
url_jre="https://sdlc-esd.oracle.com/ESD6/JSCDL/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jre-8u171-linux-x64.tar.gz"

echo "1. Install Java bin/$jre.tar.gz"
if [ ! -f bin/$jre.tar.gz ]; then
    echo "jre package not found "
# wget -c http://xieguoliang.com/downloads/jdk-8u111-linux-x64.tar.gz
#wget -N --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz
fi
[ -e bin/$jre.tar.gz ] || curl -o bin/$jre $url_jre
[ -e bin/$jre.tar.gz ] && {
    [ -d /usr/local/jre1.8.0_171 ] || sudo tar zxf bin/$jre.tar.gz -C /usr/local/
    sudo rm -fr /usr/lib/jvm/jdk8  && sudo ln -sf /usr/local/jre1.8.0_171 /usr/lib/jvm/jdk8
}

sudo tee /etc/profile.d/java.sh >/dev/null << EOF
export JAVA_HOME=/usr/lib/jvm/jdk8
#export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/lib
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
# sudo chmod +x /etc/profile.d/java.sh
. /etc/profile.d/java.sh

sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk8/bin/java 200000


echo "2. Config Tomcat8"

sudo tee /etc/profile.d/tomcat.sh >/dev/null << EOF
#/usr/local/tomcat
# Runtime Dir: "bin lib"
export CATALINA_HOME=/usr/share/tomcat8

# Project Dir: "conf  lib  logs  webapps  work "
# export CATALINA_BASE=/var/lib/tomcat8
export CATALINA_BASE=/docker/tomcat
export PATH=\$PATH:\$CATALINA_HOME/bin
EOF
# sudo chmod +x /etc/profile.d/tomcat.sh
. /etc/profile.d/tomcat.sh

sudo tee /etc/systemd/system/tomcat8.service >/dev/null << EOF
# Systemd unit file for tomcat /etc/systemd/system/tomcat8.service
[Unit]
Description=Apache Tomcat 8 Web Application Container
After=syslog.target network.target

[Service]
# User=tomcat
# Group=tomcat
Restart=always
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/jdk8
Environment=CATALINA_PID=/var/run/tomcat/tomcat8.pid
Environment=CATALINA_HOME=/usr/share/tomcat8
Environment=CATALINA_BASE=${CATALINA_BASE}
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/usr/share/tomcat8/bin/startup.sh
ExecStop=/usr/share/tomcat8/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF


echo "Install Tomcat8"
tomcat=apache-tomcat-8.5.30
url_tomcat=http://mirror.bit.edu.cn/apache/tomcat/tomcat-8/v8.5.30/bin/apache-tomcat-8.5.30.tar.gz
if [ ! -f bin/$tomcat.tar.gz ]; then
    exit "not found apache-tomcat-8"
    wget $url_tomcat
fi
sudo tar -zxf bin/$tomcat.tar.gz -C /usr/local/ 
sudo rm -fr ${CATALINA_HOME}  && sudo ln -sf /usr/local/apache-tomcat-8.5.30 ${CATALINA_HOME}



# sudo ln -sf /usr/local/apache-tomcat-8.5.30 /usr/share/tomcat8

#rm -rf /usr/local/tomcat/webapps/*
#rm -rf /usr/local/tomcat/webapps/{docs,examples,manager,ROOT/*}
#rm -rf /usr/local/tomcat/logs/*

# echo "2. add user tomcat"
# id tomcat || {
#     sudo groupadd -r -g 32 tomcat && sudo useradd -r -u 32 -g tomcat -c tomcat -d /var/lib/tomcat -s /sbin/nologin tomcat
# } 

echo "3. prepare tomcat directory"
sudo mkdir -p /var/run/tomcat && sudo chown -R tomcat:tomcat /var/run/tomcat
sudo mkdir -p /var/log/tomcat && sudo chown -R tomcat:tomcat /var/log/tomcat
sudo mkdir -p /var/lib/tomcat && sudo chown -R tomcat:tomcat /var/lib/tomcat 
sudo mkdir -p /docker/tomcat && sudo chown -R tomcat:tomcat /docker/tomcat 

sudo mkdir -p ${CATALINA_BASE}
sudo cp -r ${CATALINA_HOME}/conf ${CATALINA_BASE}/
sudo cp -r ${CATALINA_HOME}/logs ${CATALINA_BASE}/
sudo cp -r ${CATALINA_HOME}/webapps ${CATALINA_BASE}/
sudo cp -r ${CATALINA_HOME}/work ${CATALINA_BASE}/
sudo chown -R tomcat:tomcat ${CATALINA_BASE}

sudo sed -i -e"s/Connector port=\"8080\"/Connector port=\"80\" URIEncoding=\"UTF-8\"/g" ${CATALINA_BASE}/conf/server.xml

echo "4. start tomcat8"

sudo systemctl daemon-reload
sudo systemctl enable tomcat8
sudo systemctl restart tomcat8