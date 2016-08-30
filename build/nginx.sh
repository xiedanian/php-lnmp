function install_nginx(){
    oldpwd=$(pwd)
    cd ${g_dir_source}
    local base_dir=${g_dir_soft}
    local nginx_version=${g_nginx_version}
    if [ ! -d ${base_dir} -o ${base_dir} = "" ];then
        error "install nginx faild, base_dir not exist! base_dir=${base_dir}"
    fi
    local install_dir=${base_dir}/${nginx_version}
    local source_dir=${g_dir_source}
    if [ ! -d ${source_dir} ];then
        error "source_dir not found, source_dir=${source_dir}"
    fi
    cd ${source_dir}
    local source_file=${source_dir}/${nginx_version}.tar.gz
    local source_unpack_dir=${source_dir}/${nginx_version}
    #if [ ! -d ${source_unpack_dir} ];then
    #    rm -rf ${source_unpack_dir}
    #    notice "rm nginx source_unpack_dir success"
    #fi
    if [ ! -d ${source_unpack_dir} ];then
        tar zxvf ./${nginx_version}.tar.gz
        if [ $? -ne 0 ];then
            error "unpack nginx tarball failed"
        fi
    fi

    local zlib_version="zlib-1.2.8"
    local zlib_dir=${source_dir}/${zlib_version}
    if [ ! -d ${zlib_dir} ];then
        tar zxvf ./${zlib_version}.tar.gz
    fi

    local openssl_version="openssl-1.0.2h"
    local openssl_dir=${source_dir}/${openssl_version}
    if [ ! -d ${openssl_dir} ];then
        tar zxvf ./${openssl_version}.tar.gz
    fi

    cd ${source_unpack_dir}
    ./configure --prefix=${install_dir} --http-client-body-temp-path=${install_dir}/tmp/http-client-body --http-proxy-temp-path=${install_dir}/tmp/http-proxy --http-fastcgi-temp-path=${install_dir}/tmp/http-fastcgi --http-uwsgi-temp-path=${install_dir}/tmp/http-uwsgi --http-scgi-temp-path=${install_dir}/tmp/http-scgi --with-pcre --with-zlib=${source_dir}/${zlib_version} --with-openssl=${source_dir}/${openssl_version}
    if [ $? -ne 0 ];then
        error "nginx ./configure faild"
    fi
    make
    if [ $? -ne 0 ];then
        error "nginx make faild"
    fi
    make install
    if [ $? -ne 0 ];then
        error "nginx make install faild"
    fi
    cd ${g_dir_install}
    ln -s ${g_dir_soft}/${g_nginx_version} ${g_dir_link}/nginx
    cd ${oldpwd}
}
