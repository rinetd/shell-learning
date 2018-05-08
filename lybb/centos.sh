#!/bin/bash
## 
# ssh-keygen
# for host in $1 $2
# do ssh-copy-id -i ~/.ssh/id_rsa.pub $host;
# done
## free memery clear_buffer.sh
sync
echo 1 > /proc/sys/vm/drop_caches
echo 2 > /proc/sys/vm/drop_caches
echo 3 > /proc/sys/vm/drop_caches

## 1.
echo "1. Ulimit setup..."

sed -i 's/^fs.file-max/#fs.file-max/g' /etc/sysctl.conf
echo "fs.file-max = 65535" >>  /etc/sysctl.conf

sudo cat << EOF >> /etc/sysctl.d/99-sysctl.conf
fs.file-max=10485760
net.ipv4.netfilter.ip_conntrack_max = 262144
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.core.rmem_max = 8388608
net.core.wmem_max = 8388608
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 87380 8388608
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_syn_retries = 2    
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_retries2 = 5
EOF

sed -i 's/^*/#*/g' /etc/security/limits.conf
echo "" >> /etc/security/limits.conf
echo "* soft  core  1024000" >> /etc/security/limits.conf
echo "* soft  nproc   65535" >> /etc/security/limits.conf
echo "* hard  nproc   65535" >> /etc/security/limits.conf
echo "* soft  nofile  65535" >> /etc/security/limits.conf
echo "* hard  nofile  65535" >> /etc/security/limits.conf
ulimit -n 65535

## 2. 
echo "2. SElinux disabling..."

setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 
sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux
echo "SELINUX status : " $(getenforce)
## 3.
{
    echo "Time setup..."
    # ntpdate ntp.ubuntu.com

    # #set GMT
    # cp /usr/share/zoneinfo/GMT /etc/localtime
    # /etc/init.d/ntpd start
    # chkconfig ntpd on
}
