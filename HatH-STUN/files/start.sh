#!/bin/sh

echo "Starting..."

[ "$HathData" ] || HathData=/share/hath
HathWorkDir=$HathData

if echo "$HathWorkDir" | grep -q '^/share\(/.*\)\?$'; then
	mount | grep ' /share ' >/dev/null || echo "Warning: /share is not mounted; data will not persist"
fi

mkdir -p "$HathWorkDir"
export HathWorkDir

# Only use custom directories that are actually mounted
[ -d /hath_cache ] && export HathCache=/hath_cache && echo Custom cache dir mounted
[ -d /hath_data ] && export HathData=/hath_data && echo Custom data dir mounted
[ -d /hath_download ] && export HathDownload=/hath_download  && echo Custom download dir mounted
[ -d /hath_log ] && export HathLog=/hath_log && echo Custom log dir mounted
[ -d /hath_temp ] && export HathTemp=/hath_temp  && echo Custom temp dir mounted

# If HathClientId or HathClientKey is not set, read from client_login
[ "$HathData" ] || HathData="$HathWorkDir"
[ "$HathCache" ] || HathCache="$HathWorkDir/cache"
[ "$HathDownload" ] || HathDownload="$HathWorkDir/download"
[ "$HathLog" ] || HathLog="$HathWorkDir/log"
[ "$HathTemp" ] || HathTemp="$HathWorkDir/temp"
mkdir -p "$HathData" "$HathCache" "$HathDownload" "$HathLog" "$HathTemp"
export HathData HathCache HathDownload HathLog HathTemp
if [ "$HathClientId" ] && [ "$HathClientKey" ]; then
	echo -n ''$HathClientId'-'$HathClientKey'' >"$HathData/client_login"
else
	if [ -f "$HathData/client_login" ]; then
		export HathClientId=$(awk -F '-' '{print$1}' "$HathData/client_login")
		export HathClientKey=$(awk -F '-' '{print$2}' "$HathData/client_login")
	fi
fi
([ $(echo $HathClientId | grep -E '^[0-9]*$') ] && [ $(echo -n $HathClientKey | wc -m) = 20 ]) || \
(echo H@H client ID or key format is invalid)

ADD_UPNP() {
	[ $UpnpInterface ] && UpnpInterface='-m '$UpnpInterface''
	[ $UpnpUrl ] && UpnpUrl='-u '$UpnpUrl''
	[ $UpnpAddr ] || UpnpAddr=@
	if [ $Stun ]; then
		UpnpInPort=$StunHathPort
		UpnpExPort=$StunBindPort
	else
		if [ ! $UpnpInPort ] || [ ! $UpnpExPort ]; then
			if [ ! $UpnpClientPort ]; then
				ActTime=$(date +%s)
				ActKey=$(echo -n "hentai@home-client_settings--$HathClientId-$ActTime-$HathClientKey" | sha1sum | cut -c -40)
				UpnpClientPort=$(curl -Ls 'http://rpc.hentaiathome.net/15/rpc?clientbuild='$BUILD'&act=client_settings&add=&cid='$HathClientId'&acttime='$ActTime'&actkey='$ActKey'' | grep port= | grep -oE '[0-9]*')
			fi
			if [ $UpnpClientPort ];then
				[ $UpnpInPort ] || UpnpInPort=$UpnpClientPort
				[ $UpnpExPort ] || UpnpExPort=$UpnpClientPort
			else
				echo Failed to get port info; skipping UPnP
				return 1
			fi
		fi
	fi
	echo UPnP rule: forward external port $UpnpExPort to internal port $UpnpInPort
	UpnpStart='upnpc '$UpnpArgs' '$UpnpInterface' '$UpnpUrl' -i -e "STUN H@H Client@'$HathClientId'" -a '$UpnpAddr' '$UpnpInPort' '$UpnpExPort' tcp'
	echo UPnP command
	echo $UpnpStart
	$UpnpStart
}

rm -f "$HathWorkDir/WANPORT"
if [ $Stun ]; then
	echo "STUN enabled; starting H@H client after traversal"
	([ $(echo $StunIpbId | grep -E '^[0-9]*$') ] && [ $(echo -n $StunIpbPass | wc -m) = 32 ]) || \
	(echo "User ID (ipb_member_id) or key (ipb_pass_hash) format is invalid" && exit 1)
	[ $StunServer ] || StunServer=turn.cloudflare.com
	[ $StunHttpServer ] || StunHttpServer=github.com
	[ $StunBindPort ] || StunBindPort=44377
	[ $StunHathPort ] || StunHathPort=44388
	export HathPort=$StunHathPort
	[ $StunInterval ] || StunInterval=25
	[ $StunInterface ] && StunInterface='-i '$StunInterface''
	if [ $StunForward ]; then
		[ $StunForwardAddr ] || StunForwardAddr=127.0.0.1
		StunForward='-t '$StunForwardAddr' -p '$StunHathPort''
		export HathSkipIpCheck=1
		echo "STUN forwarding enabled to $StunForwardAddr:$StunHathPort; skipping IP origin check"
	fi
	[ $Upnp ] && echo UPnP enabled; starting && ADD_UPNP
	NatmapStart='natmap '$StunArgs' -4 -s '$StunServer' -h '$StunHttpServer' -b '$StunBindPort' -k '$StunInterval' '$StunInterface' '$StunForward' -e /files/natmap.sh'
	echo NATMap command
	echo $NatmapStart
	exec $NatmapStart
else
	echo "STUN disabled; starting H@H client directly"
	[ $Upnp ] && echo UPnP enabled; starting && ADD_UPNP
	exec hath.sh
fi
