#!/bin/bash
# Define console colors
RED='\033[0;31m'
NC='\033[0m' # No Color

# Execute as sudo
(( EUID != 0 )) && exec sudo -- "$0" "$@"
clear

# User confirmation
read -rep $'!!! IMPORTANT !!!\n\nThis script will remove SoftEther if it has been previously installed. Please backup your config file via the GUI manager or copy it from /opt/vpnserver/ if you are upgrading.\n\nThis will download and compile SoftEther VPN on your server. Are you sure you want to continue? [y/N] ' response
case $response in
[yY][eE][sS]|[yY])

# REMOVE PREVIOUS INSTALL
# Check for SE install folder
if [ -d "/opt/vpnserver" ]; then
  rm -rf /opt/vpnserver > /dev/null 2>&1
fi

if [ -d "/tmp/softether-autoinstall" ]; then
  rm -rf /tmp/softether-autoinstall > /dev/null 2>&1
fi

# Check for init script
if
  [ -f "/etc/init.d/vpnserver" ]; then rm /etc/init.d/vpnserver;
fi

# Remove vpnserver from systemd
update-rc.d vpnserver remove > /dev/null 2>&1

# Create working directory
mkdir -p /tmp/softether-autoinstall
cd /tmp/softether-autoinstall

# Perform apt update
apt update &&

# Install build-essential and checkinstall
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' build-essential|grep "install ok installed")
echo  "Checking for build-essential: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "build-essential not installed. Installing now."
  sudo apt install -y build-essential
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' checkinstall|grep "install ok installed")
echo "Checking for checkinstall: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "checkinstall not installed. Installing now."
  sudo apt install -y checkinstall
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' build-essential|grep "install ok installed")
echo  "Checking for build-essential: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "build-essential is still not installed. Possible problem with apt? Exiting."
  exit 1
fi

# Download SoftEther | Version 4.29 | Build 9680
printf "\nDownloading release: ${RED}4.29 RTM${NC} | Build ${RED}9680${NC}\n\n"
wget https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.34-9745-beta/softether-vpnserver-v4.34-9745-beta-2020.04.05-linux-x64-64bit.tar.gz
tar -xzf softether-vpnserver-v4.34-9745-beta-2020.04.05-linux-x64-64bit.tar.gz
cd vpnserver
echo $'1\n1\n1' | make &&
cd /tmp/softether-autoinstall && mv vpnserver/ /opt
chmod 600 /opt/vpnserver/* && chmod 700 /opt/vpnserver/vpncmd && chmod 700 /opt/vpnserver/vpnserver
cd /tmp/softether-autoinstall
PS3='Are you going to use the bridge option on the VPN server? If unsure or are using SecureNAT, select No.'
options=("Yes" "No" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Yes")
        apt install -y dnsmasq
        wget -O dnsmasq.conf https://raw.githubusercontent.com/icoexist/softether-autoinstall/master/dnsmasq.conf
        rm /etc/dnsmasq.conf && mv dnsmasq.conf /etc/dnsmasq.conf
        wget -O vpnserver-init-bridge https://raw.githubusercontent.com/icoexist/softether-autoinstall/master/vpnserver-init-bridge > /dev/null 2>&1
        mv vpnserver-init-bridge /etc/init.d/vpnserver
        chmod 755 /etc/init.d/vpnserver
        printf "\nSystem daemon created. Registering changes...\n\n"
        update-rc.d vpnserver defaults > /dev/null 2>&1
        printf "\nSoftEther VPN Server should now start as a system service from now on.\n\n"
        systemctl start vpnserver
        systemctl restart dnsmasq
        printf "\nCleaning up...\n\n"
        cd && rm -rf /tmp/softether-autoinstall > /dev/null 2>&1
        systemctl is-active --quiet vpnserver && echo "Service vpnserver is running."
        printf "\n${RED}!!! IMPORTANT !!!${NC}\n\nTo configure the server, use the SoftEther VPN Server Manager located here: http://bit.ly/2D30Wj8 or use ${RED}sudo /opt/vpnserver/vpncmd${NC}\n\n${RED}!!! UFW is not enabled with this script !!!${NC}\n\nTo see how to open ports for SoftEther VPN, please go here: http://bit.ly/2JdZPx6\n\nNeed help? Feel free to join the Discord server: https://icoexist.io/discord\n\n"
        printf "\n${RED}!!! IMPORTANT !!!${NC}\n\nYou still need to add the local bridge using the SoftEther VPN Server Manager. It is important that after you add the local bridge, you restart both dnsmasq and the vpnserver!\nSee the tutorial here: http://bit.ly/2HoxlQO\n\n"

        break
            ;;
        "No")
        wget -O vpnserver-init https://raw.githubusercontent.com/icoexist/softether-autoinstall/master/vpnserver-init > /dev/null 2>&1
        mv vpnserver-init /etc/init.d/vpnserver
        chmod 755 /etc/init.d/vpnserver
        printf "\nSystem daemon created. Registering changes...\n\n"
        update-rc.d vpnserver defaults > /dev/null 2>&1
        printf "\nSoftEther VPN Server should now start as a system service from now on.\n\n"
        systemctl start vpnserver
        printf "\nCleaning up...\n\n"
        cd && rm -rf /tmp/softether-autoinstall > /dev/null 2>&1
        systemctl is-active --quiet vpnserver && echo "Service vpnserver is running."
        printf "\n${RED}!!! IMPORTANT !!!${NC}\n\nTo configure the server, use the SoftEther VPN Server Manager located here: http://bit.ly/2D30Wj8 or use ${RED}sudo /opt/vpnserver/vpncmd${NC}\n\n${RED}!!! UFW is not enabled with this script !!!${NC}\n\nTo see how to open ports for SoftEther VPN, please go here: http://bit.ly/2JdZPx6\n\nNeed help? Feel free to join the Discord server: https://icoexist.io/discord\n\n"
        break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
esac
