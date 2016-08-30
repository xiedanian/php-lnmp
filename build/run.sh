#!/bin/bash
curr_dir=$(cd $(dirname "$0"); pwd)
cd ${curr_dir}
source ./config.sh
source ./common.sh
source ./util.sh
source ./nginx.sh
source ./php.sh
g_env_type=$2
g_dir_source=${curr_dir}/../src
g_dir_tmp=${curr_dir}/../tmp
g_dir_base=${curr_dir}/..
g_dir_install=$1
g_dir_soft=${g_dir_install}/local/soft
g_dir_link=$(dirname ${g_dir_soft})
g_dir_logs=${g_dir_install}/logs
if [ ${g_dir_soft} = "" ];then
    error "g_dir_install required"
fi
notice "global install dir is: ${g_dir_soft}"
#if [ -d ${g_dir_soft} ];then
#    error "global install dir alread exists: ${g_dir_soft}"
#fi
mkdir -p ${g_dir_soft}
if [ $? -ne 0 ];then
    error "mkdir faild, dir: ${g_dir_soft}"
fi
#which unzip
#if [ $? -ne 0 ];then
#    yum install unzip zip -y
#fi
#cd ${g_dir_install}
install_nginx
install_php

CONF_PHP_FPM_POOL=${g_conf_user}
VARS=(
CONF_USER=${g_conf_user}
CONF_GROUP=${g_conf_group}
#php/etc/php-fpm.conf
CONF_PATH_INSTALL_HOME=${g_dir_install}
CONF_PATH_PHP_LOG_ERROR=${g_dir_logs}/php/error.log
CONF_PATH_PHP_FPM_LOG=${g_dir_logs}/php/php-fpm.log
CONF_PATH_PHP_FPM_LOG_ACCESS=${g_dir_logs}/php/access.log
CONF_PATH_PHP_FPM_LOG_SLOW=${g_dir_logs}/php/slow.log
CONF_PATH_NGINX_LOG_ACCESS=${g_dir_logs}/nginx/access.log
CONF_PATH_NGINX_LOG_ERROR=${g_dir_logs}/nginx/error.log
#php/etc/php-fpm.d/www.conf
CONF_PHP_FPM_USER=${g_conf_user}
CONF_PHP_FPM_GROUP=${g_conf_group}
CONF_PHP_FPM_POOL=${g_conf_user}
CONF_PHP_FPM_PORT=${g_conf_phpfpm_port}
CONF_NGINX_WORKER_PROCESSES=$(cat /proc/cpuinfo | grep processor | wc -l)
CONF_NGINX_PORT=${g_conf_nginx_port}
CONF_NGINX_DOMAIN=${g_conf_nginx_domain}
CONF_NGINX_WEBROOT=${g_dir_install}/webroot
)
FILES=(
local/php/etc/php-fpm.conf
local/php/etc/ext/yaf.ini
local/php/etc/php-fpm.d/${g_conf_user}.conf
local/php/etc/php.ini
local/nginx/conf/nginx.conf
local/nginx/conf/nginx.d/default.conf
bin/controll
)

cd ${g_dir_base}
if [ ! -d ${g_dir_tmp} ];then
    mkdir -p ${g_dir_tmp}
fi
if [ -d "${g_dir_tmp}/template" ];then
    rm -rf "${g_dir_tmp}/template"
fi
cp -r template ${g_dir_tmp}
cd ${g_dir_tmp}
mv ./template/local/php/etc/php-fpm.d/default.conf ./template/local/php/etc/php-fpm.d/${g_conf_user}.conf
if [ ${g_env_type} = "development" ];then
    cp -r ./template/local/php/etc/php.ini-development ./template/local/php/etc/php.ini
fi
if [ ${g_env_type} != "development" ];then
    cp -r ./template/local/php/etc/php.ini-production ./template/local/php/etc/php.ini
fi
for item in ${VARS[@]};do
    var=${item%=*}
    val=${item#*=}
    for file in ${FILES[@]};do
        echo sed -i "s#\${${var}}#${val}#g" ./template/${file}
        sed -i "s#\${${var}}#${val}#g" ./template/${file}
    done
done
sed -i "s#\${CONF_PATH_LINK}#${g_dir_link}#g" ./template/bin/controll
#rsync -avh ./template/ ${g_dir_install}
mkdir -p ${g_dir_install}/bin
mkdir -p ${g_dir_link}/php/etc/ext
mkdir -p ${g_dir_link}/nginx/conf/nginx.d
cd ${g_dir_tmp}/template
for file in ${FILES[@]};do
    cp -f ${file} ${g_dir_install}/${file}
done
mkdir -p ${g_dir_install}/logs/php
mkdir -p ${g_dir_install}/logs/nginx
mkdir -p ${g_dir_link}/nginx/tmp/http-client-body #### todo:move to data dir
mkdir -p ${g_dir_install}/webroot
mkdir -p ${g_dir_install}/data
mkdir -p ${g_dir_install}/tmp
mkdir -p ${g_dir_install}/apps
mkdir -p ${g_dir_install}/templates

id ${g_conf_user}
if [ $? -ne 0 ];then
    useradd ${g_conf_user}
fi
chown -R ${g_conf_user}:${g_conf_group} ${g_dir_install}

${g_dir_install}/bin/controll start all
