function install_php(){
    oldpwd=$(pwd)
    sysname=$(lsb_release --id -s)
    if [ ${sysname} = "CentOS" ];then
        yum -y install libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel pcre-devel curl-devel
    fi
    if [ ${sysname} = "Ubuntu" ];then
        apt-get -y install libxml2-dev build-essential openssl libssl-dev libjpeg-dev libpng-dev libfreetype6-dev libmcrypt-dev libreadline6 libreadline6-dev
    fi

    #################################################
    # php
    #################################################
    local install_dir=${g_dir_soft}/${g_php_version}
    cd ${g_dir_source}
    local srcfile_php=${g_dir_source}/${g_php_version}.tar.gz
    local srcdir_php=${g_dir_source}/${g_php_version}
    #if [ -d ${srcdir_php} ];then
    #    rm -rf ${srcdir_php}
    #    notice "rm php srcdir_php success"
    #fi
    if [ ! -d ${srcdir_php} ];then
        tar zxvf ./${g_php_version}.tar.gz
        if [ $? -ne 0 ];then
            error "unpack php tarball failed"
        fi
    fi
    cd ${g_php_version}
    ./configure --prefix=${install_dir} \
    --enable-fpm \
    --with-config-file-path=${install_dir}/etc \
    --with-config-file-scan-dir=${install_dir}/etc/ext \
    --enable-bcmath \
    --enable-mbstring \
    --with-openssl \
    --with-curl \
    --with-gd \
    --with-jpeg-dir \
    --with-png-dir \
    --with-freetype-dir \
    --with-libxml-dir \
    --with-mysqli \
    --with-pdo-mysql
    if [ $? -ne 0 ];then
        error "php ./configure faild"
    fi
    make && make install
    if [ $? -ne 0 ];then
        error "nginx make && make install faild"
    fi
    if [ -d ${g_dir_link}/php ];then
        rm -rf ${g_dir_link}/php
    fi
    ln -s ${g_dir_soft}/${g_php_version} ${g_dir_link}/php
    if [ $? -ne 0 ];then
        error "php make soft link failed"
    fi

    ####################################################
    # install yaf
    ####################################################
    export PATH=${g_dir_link}/php/bin:${PATH}
    cd ${g_dir_source}
    yaf_source_file=${g_yaf_version}.tgz
    yaf_source_dir=${g_yaf_version}
    if [ -d ${yaf_source_dir} ];then
        rm -rf ${yaf_source_dir}
    fi
    tar zxvf ./${yaf_source_file}
    if [ $? -ne 0 ];then
        error "unpack yaf failed"
    fi
    cd ${yaf_source_dir}
    phpize
    ./configure
    if [ $? -ne 0 ];then
        error "configure yaf failed"
    fi
    make && make install
    if [ $? -ne 0 ];then
        error "make && make install yaf failed"
    fi

    cd ${oldpwd}
}
