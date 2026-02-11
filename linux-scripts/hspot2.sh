#!/bin/bash

# root acces
if [[ $(whoami) != root ]];then
    echo "! you are need root access"; exit
fi

# change fungsi
ipiface=10.0.1.1
iface_name="wlan0"

# kill proccess
if [[ $1 == "kill" ]] && [ -z $2 ];then
    killall hostapd
    killall dnsmasq
    iptables -F && iptables -t nat -F
    exit
fi

# check is running
if [ "$(pidof hostapd)" ];then echo "! hostpot is running another proccess......"; exit; fi

# chooser new or use file configuration
if [[ $1 == "-file" ]] && [ "$2" ] && [ -z "$3"];then
    file_configuration="$2"
elif [[ $1 == "-new" ]] && [ "$2" ] && [ "$3" ] && [ -z "$4"];then
    hotspot_name="$2"
    hotspot_password="$3"
    file_configuration="hotspot.conf"
    nwfile=1
else
    echo "usage : $0 -file [file_configuration] | -new [newHotspotName] [newHotspotPassword]"
    exit
fi

# create new interface
if [ -z "$(ip addr | grep ap0)" ];then
    iw dev $iface_name interface add ap0 type __ap
    sleep 2
    ip link set dev ap0 down
    echo "set interface....."
else
    echo "interface ready......"
    ip link set dev ap0 down
fi

# create new ip addr new interface
if [ -z "$(ip addr show dev ap0 | grep inet)" ];then
    ip addr add ${ipiface}/24 dev ap0
    echo "set ip addresss wlan....."
fi

# check macaddress different

# check channel, what is different
get_channel=$(iwgetid -c $iface_name | cut -d ':' -f 2)
if [ -z "$(iwgetid -c ap0)" ] || [[ "$(iwgetid -c ap0 | cut -d ':' -f 2)" != "$get_channel" ]];then
    iwconfig ap0 channel $get_channel
    echo "set channel......"
fi

# check channel from wifi have internet access
for gtc in $(cat $file_configuration);do
    if [[ ${gtc%=*} == "channel" ]];then
        check_channel=${gtc##*=}
    fi
done
if [[ $get_channel -ne $check_channel ]] && [[ $nwfile -ne 1 ]];then
    echo "please change channel like $iface_name......"
    exit
fi

# check permission on kernel
if [[ "$(sysctl net.ipv4.ip_forward | grep -o 1)" -ne 1 ]];then
    sysctl -w net.ipv4.ip_forward=1
    echo "set forward in kernel...."
fi

# create table connection route
if [ -z "$(iptables -t nat -L -v -n | grep wlan0)" ];then
    iptables -t nat -A POSTROUTING -s ${ipiface}/24 -o wlan0 -j MASQUERADE
    echo "set tables route....."
fi

# off ap from networkmanager
if [[ "$(systemctl status NetworkManager | grep -o running)" == "running" ]];then
    nmcli dev set ap0 managed no
fi

# kill dnsmasq
if [ "$(ps aux | grep dhcp)" ];then
    killall dnsmasq
    echo "restart dnsmasq process....."
fi

# running auto give ip if a device connect
if [ -z "$(ps aux | grep dnsmasq | grep 10.0.1.10)" ];then
    dnsmasq -i ap0 --port=0 --dhcp-range=${ipiface%.*}.10,${ipiface%.*}.50,12h --dhcp-option=6,8.8.8.8
    echo "set automatic ip address............"
fi

# run hotspot
if [ -f $file_configuration ] && [[ $nwfile -ne 1 ]];then
    hostapd $file_configuration
    echo "hotspot is running now........."
else
    echo """interface=ap0
driver=nl80211
ssid=$hotspot_name
hw_mode=g
channel=$get_channel
wpa=2
wpa_passphrase=$hotspot_password
wpa_key_mgmt=WPA-PSK
""" > $file_configuration
    echo "create default new file configuration....."
    echo "please run [sudo $0 -file $file_configuration] try again ..."
fi
