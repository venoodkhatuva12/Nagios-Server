#!/bin/bash
#Check whether root user is running the script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
host=$(/bin/hostname)

#add epel Repo to system
sudo yum install -y epel-release
yum install -y wget unzip
pip install pymongo
sudo yum install -y nrpe nagios-plugins-users nagios-plugins-load nagios-plugins                                 -swap nagios-plugins-disk nagios-plugins-procs

echo "##########################################################################                                 ######
#
# nrpe command configuration file
#
# COMMAND DEFINITIONS
# Syntax:
#       command[<command_name>]=<command_line>
#
#Moofwd Custom Setting

command[check_disk_apps]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /                                 apps
command[check_disk_root]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /
command[check_mem]=/usr/lib64/nagios/plugins/check-memory-pcnt.sh -w 90 -c 95
command[check_mem_swap]=/usr/lib64/nagios/plugins/check_swap -w 20 -c 10
command[check_load]=/usr/lib64/nagios/plugins/check_load -w 8.00,5.00,2.00 -c 10                                 .00,8.00,3.00
command[check_smtp]=/usr/lib64/nagios/plugins/check_smtp -H localhost -p 25
command[check_of]=/usr/lib64/nagios/plugins/check_of  WARNING = 5000,CRITICAL =                                  100000
command[check_activemq]=/usr/lib64/nagios/plugins/check_activemq
command[check_memcached]=/usr/lib64/nagios/plugins/check_memcache -H localhost -                                 p 11211
command[check_tmgr]=/usr/lib64/nagios/plugins/check_tmgr -l tomcat -a m00fwd@123                                  -w 50% -c 60%
command[check_mysql]=/usr/lib64/nagios/plugins/check_mysql -H localhost -u moofw                                 d -p moofwd -w 5 -c 10
command[check_tomcat]=/usr/lib64/nagios/plugins/check_tomcat
command[check_https]=/usr/lib64/nagios/plugins/check_http -H upn.mooestro.com -w                                  5 -c 10
command[check_http_rt]=/usr/lib64/nagios/plugins/check_http_ssl -H upn.mooestro.                                 com -u http://upn.mooestro.com/moofwd-rt
command[check_mongodb]=/usr/lib64/nagios/plugins/check_mongodb.py -H localhost -                                 u moofwd -p moofwd@123 -A connections -P 27017 -W 10 -C 20
command[check_mongodb_mem]=/usr/lib64/nagios/plugins/check_mongodb.py -H localho                                 st -u moofwd -p moofwd@123  -A memory -P 27017 -W 10 -C 20" >> /etc/nrpe.d/$host                                 .cfg

read -p "What is the Portal Address? " portal
read -p "What is the RT Address " rtadd
sed -i "s/upn.mooestro.com/$portal/g" /etc/nrpe.d/$host.cfg
sed -i "s/https:\/\/upn.mooestro.com\/moofwd-rt/$rtadd/g" /etc/nrpe.d/$host.cfg

sed -i 's/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1,54.225.134.240/g' /etc                                 /nagios/nrpe.cfg

#Installing wget and adding Services
rm -rf /usr/lib64/nagios/plugins
cd /usr/lib64/nagios/
wget https://s3-eu-west-1.amazonaws.com/moofwd-devops/plugins.zip
cd /usr/lib64/nagios/ && unzip plugins.zip
service nrpe restart
chkconfig nrpe on

echo "Please open Port 5666 and icmpV4 port from AWS Security Group"
