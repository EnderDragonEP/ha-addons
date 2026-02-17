#!/bin/sh

cd /hath

# Port args
[ $HathPort ] && HathPort='--port='$HathPort''

# Directory args
[ $HathCache ] && HathDirs=''$HathDirs' --cache-dir='$HathCache''
[ $HathData ] && HathDirs=''$HathDirs' --data-dir='$HathData''
[ $HathDownload ] && HathDirs=''$HathDirs' --download-dir='$HathDownload''
[ $HathLog ] && HathDirs=''$HathDirs' --log-dir='$HathLog''
[ $HathTemp ] && HathDirs=''$HathDirs' --temp-dir='$HathTemp''

# Proxy args
[ $HathProxyHost ] && HathProxy=''$HathProxy' --image-proxy-host='$HathProxyHost''
[ $HathProxyType ] && HathProxy=''$HathProxy' --image-proxy-type='$HathProxyType''
[ $HathProxyPort ] && HathProxy=''$HathProxy' --image-proxy-port='$HathProxyPort''

# Other args
[ $HathRpc ] && HathArgs=''$HathArgs' --rpc-server-ip='$HathRpc''
[ $HathSkipIpCheck ] && HathArgs=''$HathArgs' --disable-ip-origin-check'

# JVM args
[ $JvmHttpHost ] && JvmArgs=''$JvmArgs' -Dhttp.proxyHost='$JvmHttpHost''
[ $JvmHttpPort ] && JvmArgs=''$JvmArgs' -Dhttp.proxyPort='$JvmHttpPort''
[ $JvmHttpUser ] && JvmArgs=''$JvmArgs' -Dhttp.proxyUser='$JvmHttpUser''
[ $JvmHttpPass ] && JvmArgs=''$JvmArgs' -Dhttp.proxyPassword='$JvmHttpPass''
[ $JvmHttpsHost ] && JvmArgs=''$JvmArgs' -Dhttps.proxyHost='$JvmHttpsHost''
[ $JvmHttpsPort ] && JvmArgs=''$JvmArgs' -Dhttps.proxyPort='$JvmHttpsPort''
[ $JvmHttpsUser ] && JvmArgs=''$JvmArgs' -Dhttps.proxyUser='$JvmHttpsUser''
[ $JvmHttpsPass ] && JvmArgs=''$JvmArgs' -Dhttps.proxyPassword='$JvmHttpsPass''
[ $JvmSocksHost ] && JvmArgs=''$JvmArgs' -DsocksProxyHost='$JvmSocksHost''
[ $JvmSocksPort ] && JvmArgs=''$JvmArgs' -DsocksProxyPort='$JvmSocksPort''
[ $JvmSocksUser ] && JvmArgs=''$JvmArgs' -DsocksProxyUser='$JvmSocksUser''
[ $JvmSocksPass ] && JvmArgs=''$JvmArgs' -DsocksProxyPassword='$JvmSocksPass''

# Fetch RPC server IP
ActTime=$(date +%s)
ActKey=$(echo -n "hentai@home-client_settings--$HathClientId-$ActTime-$HathClientKey" | sha1sum | cut -c -40)
RpcServerIp=$(curl -Ls 'http://rpc.hentaiathome.net/15/rpc?clientbuild='$BUILD'&act=client_settings&add=&cid='$HathClientId'&acttime='$ActTime'&actkey='$ActKey'' | grep rpc_server_ip)
if [ $RpcServerIp ]; then
	echo $RpcServerIp | grep -oE '([0-9]*\.?){4}' >/hath/rpc_server_ip.txt
	echo RPC server IP fetched; saved to rpc_server_ip.txt
else
	echo Failed to fetch RPC server IP; check whether the client starts
fi

# Start H@H client
HathStart='java '$JvmArgs' -jar /files/HentaiAtHome.jar '$HathPort' '$HathDirs' '$HathProxy' '$HathArgs''
echo H@H client command
echo $HathStart
exec $HathStart
