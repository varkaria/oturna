wget $sqlproxyfile
chmod +x proxy.sh
./proxy.sh
./cloud_sql_proxy $cloud_sql_proxy_args