#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/bin:/sbin
export PATH

# Check if Directory existed.if not,create it!
echo "Please input LNMP Work Directory:"
read -p "(Default LNMP Work Directory:/opt/lnmp):" LNMP_DIR
if [ "$LNMP_DIR" = "" ]; then
    LNMP_DIR="/opt/lnmp"
    if [ -d $LNMP_DIR  ];then
        printf "LNMP Work Directory has existed!\n"
    fi
else
    mkdir -pv $LNMP_DIR && echo "LNMP Work Directory created"
fi
echo "==========================="
echo LNMP Work Directory:="$LNMP_DIR"
echo "==========================="


mkdir -pv $LNMP_DIR/src
NMP_SRC_DIR=$LNMP_DIR/src



# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

echo "Auto-compile & install Nginx+MySQL+PHP on Linux by Jerry "

#Optimize the system kernel parameters
cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

cat >>/etc/sysctl.conf<<eof
fs.file-max=262140
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time=120
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce=2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_synack_retries = 2
net.ipv4.conf.lo.arp_announce=2
vm.overcommit_memory = 1
net.core.somaxconn = 4096
net.ipv4.tcp_tw_reuse = 1
kernel.threads-max = 254737
eof

#set main domain name
    domain="www.jerry.vip"
    echo "Please input domain:"
    read -p "(Default domain: www.jerry.vip):" domain
    if [ "$domain" = "" ]; then
        domain="www.jerry.vip"
    fi
    echo "==========================="
    echo domain="$domain"
    echo "==========================="

#set mysql root password
    echo "==========================="

    mysqlrootpwd="root123"
    echo "Please input the root password of mysql:"
    read -p "(Default password: root123):" mysqlrootpwd
    if [ "$mysqlrootpwd" = "" ]; then
        mysqlrootpwd="root123"
    fi
    echo "==========================="
    echo mysqlrootpwd="$mysqlrootpwd"
    echo "==========================="

#Set timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#Update time
yum install -y ntp
ntpdate -u time3.aliyun.com
date

#Uninstall the same installation package that exists in the system
rpm -qa|grep  httpd
rpm -e httpd
rpm -qa|grep mysql
rpm -e mysql
rpm -qa|grep php
rpm -e php

yum -y remove httpd*
yum -y remove php*
yum -y remove mysql-server mysql
yum -y remove php-mysql
yum -y remove boost*
yum -y install yum-fastestmirror
yum -y remove httpd
#yum -y update

#Disable SeLinux
if [ -s /etc/selinux/config ]; then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi


Print_Sys_Info()
{
    eval echo "${DISTRO} \${${DISTRO}_Version}"
    cat /etc/issue
    cat /etc/*-release
    uname -a
    MemTotal=`free -m | grep Mem | awk '{print  $2}'`
    echo "Memory is: ${MemTotal} MB "
    df -h
}


MySQL_Opt()
{
    if [[ ${MemTotal} -gt 1024 && ${MemTotal} -lt 2048 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 32M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 128#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 768K#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 768K#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 8M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 16#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 16M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 32M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 128M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 32M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^performance_schema_max_table_instances.*#performance_schema_max_table_instances = 1000" $LNMP_DIR/mysql/conf/my.cnf
    elif [[ ${MemTotal} -ge 2048 && ${MemTotal} -lt 4096 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 64M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 256#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 1M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 1M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 16M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 32#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 32M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 64M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 256M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 64M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^performance_schema_max_table_instances.*#performance_schema_max_table_instances = 2000" $LNMP_DIR/mysql/conf/my.cnf
    elif [[ ${MemTotal} -ge 4096 && ${MemTotal} -lt 8192 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 128M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 512#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 2M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 2M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 32M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 64#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 64M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 64M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 512M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 128M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^performance_schema_max_table_instances.*#performance_schema_max_table_instances = 4000" $LNMP_DIR/mysql/conf/my.cnf
    elif [[ ${MemTotal} -ge 8192 && ${MemTotal} -lt 16384 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 256M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 1024#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 4M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 4M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 64M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 128#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 128M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 128M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 1024M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 256M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^performance_schema_max_table_instances.*#performance_schema_max_table_instances = 6000" $LNMP_DIR/mysql/conf/my.cnf
    elif [[ ${MemTotal} -ge 16384 && ${MemTotal} -lt 32768 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 512M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 2048#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 8M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 8M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 128M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 256#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 256M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 256M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 2048M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 512M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^performance_schema_max_table_instances.*#performance_schema_max_table_instances = 8000" $LNMP_DIR/mysql/conf/my.cnf
    elif [[ ${MemTotal} -ge 32768 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 1024M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 4096#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 16M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 16M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 256M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 512#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 512M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 512M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 4096M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 1024M#" $LNMP_DIR/mysql/conf/my.cnf
        sed -i "s#^performance_schema_max_table_instances.*#performance_schema_max_table_instances = 10000" $LNMP_DIR/mysql/conf/my.cnf
    fi
}

cp /etc/yum.conf /etc/yum.conf.lnmp
sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf

#Installation dependency package
for packages in make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel patch wget crontabs libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel unzip tar bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel libcurl libcurl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils ca-certificates net-tools libc-client-devel psmisc libXpm-devel git-core c-ares-devel libicu-devel libxslt libxslt-devel xz pcre-devel libticonv.x86_64 libticonv-devel.x86_64 php-mcrypt libmcrypt libmcrypt-devel mhash mhash-devel libevent libevent-devel libxml2 libxml2-devel bzip2-devel libcurl-devel libjpeg-devel libpng-devel freetype-devel vim-minimal nano fonts-chinese;
do yum -y install $packages; done

mv -f /etc/yum.conf.lnmp /etc/yum.conf


#Check the source installation package
#Donwload file from Sohu.com Open Source Mirror Site and soft.vpser.net
echo "=======================Check the source installation package================================="

cd $NMP_SRC_DIR

if [ -s mysql-boost-5.7.18.tar.gz ]; then
  echo "mysql-boost-5.7.18.tar.gz [found]"
  else
  echo "Error: mysql-boost-5.7.18.tar.gz not found!!!download now......"
  wget -c http://mirrors.sohu.com/mysql/MySQL-5.7/mysql-boost-5.7.18.tar.gz -P $NMP_SRC_DIR
fi

if [ -s boost_1_59_0.tar.gz ]; then
  echo "boost_1_59_0.tar.gz [found]"
  else
  echo "Error: boost_1_59_0.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/lib/boost/boost_1_59_0.tar.gz -P $NMP_SRC_DIR
fi

if [ -s phpMyAdmin-4.7.1-all-languages.tar.xz ]; then
  echo "phpMyAdmin-4.7.1-all-languages.tar.xz [found]"
  else
  echo "Error: phpMyAdmin-4.7.1-all-languages.tar.xz not found!!!download now......"
  wget -c http://soft.vpser.net/datebase/phpmyadmin/phpMyAdmin-4.7.1-all-languages.tar.xz -P $NMP_SRC_DIR
fi

if [ -s nginx-1.12.1.tar.gz ]; then
  echo "nginx-1.12.1.tar.gz [found]"
  else
  echo "Error: nginx-1.12.1.tar.gz not found!!!download now......"
  wget -c http://nginx.org/download/nginx-1.12.1.tar.gz -P $NMP_SRC_DIR
fi

if [ -s php-5.6.30.tar.bz2 ]; then
  echo "php-5.6.30.tar.bz2 [found]"
  else
  echo "Error: php-5.6.30.tar.bz2 not found!!!download now......"
  wget -c http://soft.vpser.net/web/php/php-5.6.30.tar.bz2 -P $NMP_SRC_DIR
fi


#Install MySQL 5.7
echo "============================Install MySQL 5.7.18=================================="
cd $NMP_SRC_DIR
rm -f /etc/my.cnf
tar zxvf mysql-boost-5.7.18.tar.gz
cd mysql-5.7.18/
groupadd mysql
useradd -s /sbin/nologin -M -g mysql mysql
mkdir -pv $LNMP_DIR/mysql/{conf,data,log}

cmake  -DCMAKE_INSTALL_PREFIX=$LNMP_DIR/mysql -DMYSQL_DATADIR=$LNMP_DIR/mysql/data -DSYSCONFDIR=$LNMP_DIR/mysql/conf -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DMYSQL_UNIX_ADDR=$LNMP_DIR/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DENABLED_LOCAL_INFILE=1 -DWITH_BOOST=$NMP_SRC_DIR -DENABLE_DOWNLOADS=1 -DDOWNLOAD_BOOST=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNODB_MEMCACHED=on 

make -j $(cat /proc/cpuinfo| grep "processor"|wc -l) && make install > $NMP_SRC_DIR/mysqlinstall

mysqltempwd=$(tail -1 $NMP_SRC_DIR/mysqlinstall | awk '{print $NF}')
#rm -f $NMP_SRC_DIR/mysqlinstall

cd $LNMP_DIR/mysql
./bin/mysqld --initialize --user=mysql --basedir=$LNMP_DIR/mysql --datadir=$LNMP_DIR/mysql/data --explicit_defaults_for_timestamp
chown -R mysql $LNMP_DIR/mysql
chgrp -R mysql $LNMP_DIR/mysql/.


 cat > $LNMP_DIR/mysql/conf/my.cnf<<EOF
[client]
#password   = your_password
port        = 3306
socket      = $LNMP_DIR/mysql/mysql.sock

[mysqld]
port        = 3306
socket      = $LNMP_DIR/mysql/mysql.sock
datadir = $LNMP_DIR/mysql/data
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64M
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 8M
tmp_table_size = 16M
performance_schema_max_table_instances = 500

explicit_defaults_for_timestamp = true
#skip-networking
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id   = 1
expire_logs_days = 10
early-plugin-load = ""

#loose-innodb-trx=0
#loose-innodb-locks=0
#loose-innodb-lock-waits=0
#loose-innodb-cmp=0
#loose-innodb-cmp-per-index=0
#loose-innodb-cmp-per-index-reset=0
#loose-innodb-cmp-reset=0
#loose-innodb-cmpmem=0
#loose-innodb-cmpmem-reset=0
#loose-innodb-buffer-page=0
#loose-innodb-buffer-page-lru=0
#loose-innodb-buffer-pool-stats=0
#loose-innodb-metrics=0
#loose-innodb-ft-default-stopword=0
#loose-innodb-ft-inserted=0
#loose-innodb-ft-deleted=0
#loose-innodb-ft-being-deleted=0
#loose-innodb-ft-config=0
#loose-innodb-ft-index-cache=0
#loose-innodb-ft-index-table=0
#loose-innodb-sys-tables=0
#loose-innodb-sys-tablestats=0
#loose-innodb-sys-indexes=0
#loose-innodb-sys-columns=0
#loose-innodb-sys-fields=0
#loose-innodb-sys-foreign=0
#loose-innodb-sys-foreign-cols=0

default_storage_engine = InnoDB
#innodb_file_per_table = 1
#innodb_data_home_dir = $LNMP_DIR/mysql/data
#innodb_data_file_path = ibdata1:10M:autoextend
#innodb_log_group_home_dir = $LNMP_DIR/mysql/data
#innodb_buffer_pool_size = 16M
#innodb_log_file_size = 5M
#innodb_log_buffer_size = 8M
#innodb_flush_log_at_trx_commit = 1
#innodb_lock_wait_timeout = 50

[mysqld_safe]
log-error=$LNMP_DIR/mysql/log/mysqld_err.log

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF

sed -i 's:^#innodb:innodb:g' $LNMP_DIR/mysql/conf/my.cnf
touch $LNMP_DIR/mysql/log/mysqld_err.log
chown -R mysql:mysql $LNMP_DIR/mysql/log/mysqld_err.log

MySQL_Opt

cp support-files/mysql.server /etc/init.d/mysql
chmod 755 /etc/init.d/mysql
sed -i "s:mysqld_pid_file_path=:mysqld_pid_file_path=$LNMP_DIR/mysql/mysqld.pid:g" /etc/init.d/mysql


cat > /etc/ld.so.conf.d/mysql.conf<<EOF
    /usr/local/mysql/lib
    /usr/local/lib
EOF
ldconfig

ln -sf $LNMP_DIR/mysql/lib/mysql /usr/lib/mysql
ln -sf $LNMP_DIR/mysql/include/mysql /usr/include/mysql
ln -sf $LNMP_DIR/mysql/bin/mysql /usr/bin/mysql
ln -sf $LNMP_DIR/mysql/bin/mysqldump /usr/bin/mysqldump
ln -sf $LNMP_DIR/mysql/bin/myisamchk /usr/bin/myisamchk
ln -sf $LNMP_DIR/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

/etc/init.d/mysql start >$NMP_SRC_DIR/mysqlstart

$LNMP_DIR/mysql/bin/mysqladmin -u root -p$mysqltempwd -h localhost password $mysqlrootpwd

#cat > /tmp/mysql_sec_script<<EOF
#use mysql;
#update user set authentication_string=password('$mysqlrootpwd') where user='root';
#delete from user where not (user='root') ;
#delete from user where user='root' and password=''; 
#drop database test;
#DROP USER ''@'%';
#flush privileges;
#EOF

#$LNMP_DIR/mysql/bin/mysql -u root -p$mysqltempwd -h localhost < /tmp/mysql_sec_script

#rm -f /tmp/mysql_sec_script

/etc/init.d/mysql restart

chkconfig --add mysql
chkconfig mysql on
#Install Nginx

echo "========================Starting install Nginx=================================="
cd $NMP_SRC_DIR
tar zxvf nginx-1.12.1.tar.gz
cd nginx-1.12.1/
groupadd nginx
useradd -s /sbin/nologin -M -g nginx nginx
mkdir -pv $LNMP_DIR/nginx

./configure --prefix=$LNMP_DIR/nginx --with-select_module --with-threads --with-file-aio --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --with-stream --with-stream_ssl_module --with-stream_realip_module --with-stream_ssl_preread_module

make -j $(cat /proc/cpuinfo| grep "processor"|wc -l) && make install

echo "====================Setup Nginx initd========================"

cp /root/nginx_initd  /etc/init.d/nginx

chkconfig --add nginx 
chkconfig nginx on


echo "============================php install======================"

cd $NMP_SRC_DIR
yum -y install gd zlib zlib-devel openssl openssl-devel libxml2 libxml2-devel libjpeg libjpeg-devel libpng libpng-devel libticonv.x8664 libticonv-devel.x8664 php-mcrypt libmcrypt libmcrypt-devel mhash mhash-devel libevent libevent-devel libxml2 libxml2-devel bzip2-devel libcurl-devel libjpeg-devel libpng-devel freetype-devel

tar jxvf php-5.6.30.tar.bz2
cd php-5.6.30/
./configure --prefix=$LNMP_DIR/php --sysconfdir=$LNMP_DIR/php/etc --enable-fpm --enable-pcntl --enable-shmop --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-sockets --enable-shared --enable-mbstring --enable-xml --enable-opcache --enable-bcmath --enable-soap --enable-zip --with-mysqli=$LNMP_DIR/mysql/bin/mysql_config --with-mysql=$LNMP_DIR/mysql --with-openssl --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --with-iconv --with-mhash --with-mcrypt --with-config-file-path=$LNMP_DIR/php/etc --with-config-file-scan-dir=$LNMP_DIR/php/etc/php.d --with-bz2 --with-curl --with-gettext --with-gd

make -j $(cat /proc/cpuinfo| grep "processor"|wc -l) && make install

cp sapi/fpm/init.d.php-fpm /etc/rc.d/init.d/php-fpm
chmod +x /etc/rc.d/init.d/php-fpm
chkconfig --add php-fpm && chkconfig php-fpm on
cd $LNMP_DIR/php/etc/
cp php-fpm.conf.default php-fpm.conf
cat >>$LNMP_DIR/php/etc/php-fpm.conf<<eof
pm.max_children = 150 
pm.start_servers = 8 
pm.min_spare_servers = 5 
pm.max_spare_servers = 10 
eof
service php-fpm start

echo "====================================php install completed=================================================="



echo "========================Integrating Nginx and PHP5========================================================="

cd $LNMP_DIR/nginx/conf 

sed -i '/pass the PHP scripts to FastCGI server/'a\ 'location ~ \\.php$ {'\\nroot\ html\;\\nfastcgi\_pass\ 127\.0\.0\.1\:9000\;\\nfastcgi\_index\ index\.php\;\\nfastcgi\_param\ SCRIPT\_FILENAME\ \/\$document\_root\$fastcgi\_script\_name\;\\ninclude\ fastcgi\_params\;\\n\} nginx.conf

sed -i "s/^[[:space:]]*index/index index.php/" nginx.conf

cat >>$LNMP_DIR/nginx/html/index.php<<eof
<?php
phpinfo();
?>
eof

service nginx configtest 
service nginx force-reload

echo "========================Completely  Integrating Nginx and PHP5==================================="
