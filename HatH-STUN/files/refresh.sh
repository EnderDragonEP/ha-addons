#!/bin/sh

[ "$HathWorkDir" ] || HathWorkDir=${HathData:-/share/hath}

[ $Stun ] || \
(echo STUN not enabled; skipping refresh && exit 1)

ps aux | grep natmap | grep -v grep || \
(echo NATMap is not running; restart the container && exit 1)

[ -f "$HathWorkDir/WANPORT" ] || \
(echo Public port not detected; check the STUN server && exit 1)

echo Refreshing Hentai@Home with STUN

[ $HathData ] || HathData=$HathWorkDir
HATHCID=$HathClientId
HATHKEY=$HathClientKey
EHIPBID=$(awk -F '-' '{print$1}' $HathData/client_login)
EHIPBPW=$(awk -F '-' '{print$2}' $HathData/client_login)
WANPORT=$(cat "$HathWorkDir/WANPORT")

[ $StunProxy ] || echo STUN proxy not set; check whether client settings can be fetched and updated
[ $StunProxy ] && PROXY='-x '$StunProxy''

# Function to talk to the RPC server
ACTION() {
	ACT=$1
	ACTTIME=$(date +%s)
	ACTKEY=$(echo -n "hentai@home-$ACT--$HATHCID-$ACTTIME-$HATHKEY" | sha1sum | cut -c -40)
	curl -Ls 'http://rpc.hentaiathome.net/15/rpc?clientbuild='$BUILD'&act='$ACT'&add=&cid='$HATHCID'&acttime='$ACTTIME'&actkey='$ACTKEY''
}

# Check if port change is needed
[ $(ACTION client_settings | grep port=$WANPORT) ] && \
echo External port $WANPORT/tcp unchanged && SKIP=1

# Fetch H@H client settings
while [ ! $SKIP ] && [ ! $f_cname ]; do
	let GET++
	[ $GET -gt 3 ] && echo Failed to fetch H@H client settings; check proxy && exit 1
	[ $GET -ne 1 ] && echo Failed to fetch H@H client settings; retrying in 15s && sleep 15
	HATHPHP=/tmp/settings.php
	>$HATHPHP
	curl $PROXY -Ls -m 15 \
	-b 'ipb_member_id='$EHIPBID'; ipb_pass_hash='$EHIPBPW'' \
	-o $HATHPHP \
	'https://e-hentai.org/hentaiathome.php?cid='$HATHCID'&act=settings'
	f_cname=$(grep f_cname $HATHPHP | awk -F '"' '{print$6}' | sed 's/[ ]/+/g')
	f_throttle_KB=$(grep f_throttle_KB $HATHPHP | awk -F '"' '{print$6}')
	f_disklimit_GB=$(grep f_disklimit_GB $HATHPHP | awk -F '"' '{print$6}')
	p_mthbwcap=$(grep p_mthbwcap $HATHPHP | awk -F '"' '{print$6}')
	f_diskremaining_MB=$(grep f_diskremaining_MB $HATHPHP | awk -F '"' '{print$6}')
	f_enable_bwm=$(grep f_enable_bwm $HATHPHP | grep checked)
	f_disable_logging=$(grep f_disable_logging $HATHPHP | grep checked)
	f_use_less_memory=$(grep f_use_less_memory $HATHPHP | grep checked)
	f_is_hathdler=$(grep f_is_hathdler $HATHPHP | grep checked)
done

# Send client_suspend, update port info, then verify with client_settings
[ $SKIP ] || ACTION client_suspend >/dev/null
while [ ! $SKIP ]; do
	let SET++
	[ $SET -gt 3 ] && echo Failed to update H@H client settings; check proxy && exit 1
	[ $SET -ne 1 ] && echo Failed to update H@H client settings; retrying in 15s && sleep 15
	DATA='settings=1&f_port='$WANPORT'&f_cname='$f_cname'&f_throttle_KB='$f_throttle_KB'&f_disklimit_GB='$f_disklimit_GB''
	[ "$p_mthbwcap" = 0 ] || DATA=''$DATA'&p_mthbwcap='$p_mthbwcap''
	[ "$f_diskremaining_MB" = 0 ] || DATA=''$DATA'&f_diskremaining_MB='$f_diskremaining_MB''
	[ $f_enable_bwm ] && DATA=''$DATA'&f_enable_bwm=on'
	[ $f_disable_logging ] && DATA=''$DATA'&f_disable_logging=on'
	[ $f_use_less_memory ] && DATA=''$DATA'&f_use_less_memory=on'
	[ $f_is_hathdler ] && DATA=''$DATA'&f_is_hathdler=on'
	curl $PROXY -Ls -m 15 \
	-b 'ipb_member_id='$EHIPBID'; ipb_pass_hash='$EHIPBPW'' \
	-o $HATHPHP \
	-d ''$DATA'' \
	'https://e-hentai.org/hentaiathome.php?cid='$HATHCID'&act=settings'
	[ $(ACTION client_settings | grep port=$WANPORT) ] && \
	echo External port $WANPORT/tcp updated successfully && break
done

[ $SKIP ] || ACTION client_start >/dev/null
echo Refresh complete for Hentai@Home with STUN
