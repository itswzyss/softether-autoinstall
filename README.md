# SoftEther Autoinstaller

This for will install the latest Beta version and not RTM.

This is my SoftEther autoinstaller. This script will *hopefully* make your life a little easier. I have not made **any** modifications to the SoftEther VPN Project code at all, this script simply downloads the latest build and compiles it for use on your supported system.

To get started, all you have to do is copy/paste the provided code for your OS. The script will handle everything else for you. Refer to the [Quick Start Guide](https://github.com/icoexist/softether-autoinstall#quick-start-guide) if you need to get set up quickly. Also refer to the [Commands List](https://github.com/icoexist/softether-autoinstall#commands-list) should you need them.

### Install & Configure
* [Supported Operating Systems](https://github.com/metallicats/softether-autoinstall#supported-operating-systems-64-bit-only)     
* [Open Ports for SoftEther VPN](https://github.com/icoexist/softether-autoinstall#open-ports-for-softether-vpn)
* [Using Local Bridge on SoftEther VPN](https://github.com/icoexist/softether-autoinstall#Using-Local-Bridge-Setting-on-SoftEther-VPN)

### Uninstall
* [Uninstall Script](https://github.com/icoexist/softether-autoinstall#uninstall-se-vpn-server-ubuntu-only)

### Configure SoftEther VPN Server
* [Quick Start Guide](https://github.com/icoexist/softether-autoinstall#quick-start-guide)   
* [Other Options](https://github.com/icoexist/softether-autoinstall#other-options)   
* [Commands List](https://github.com/icoexist/softether-autoinstall#commands-list)   

### Copyright & Credit
* [Information](https://github.com/icoexist/softether-autoinstall#copyright--credit-1)

## Supported Operating Systems (64-bit only)
#### Ubuntu 16.04 LTS +
```bash
wget -O se-install https://raw.githubusercontent.com/metallicats/softether-autoinstall/master/ubuntu/se-install-ubuntu.bash && chmod +x se-install && ./se-install
```

#### CentOS 7 (Currently depreciated, no longer in development)
```bash
curl -o se-install https://raw.githubusercontent.com/metallicats/softether-autoinstall/master/centos/x64/se-install-centos.bash && chmod 770 se-install && ./se-install
```
## Open Ports for SoftEther VPN
### Ubuntu
In terminal, execute the following: `ufw allow 443,1194,5555/tcp && ufw allow 500,1701,4500/udp`    

Please make sure you allow the port you use for SSH, otherwise you risk blocking inbound SSH connections. You can use `ufw allow ssh` or if you have set a custom port, use `ufw enable x/tcp` where `x = port`. For instance, if I use port `2222` for SSH, I'll use `ufw allow 2222/tcp`.    

Now enable UFW with `ufw enable`.

## Using Local Bridge Setting on SoftEther VPN
The Local Bridge Setting on SoftEther VPN allows you to run your own DHCP server on the VPN. This has much better performance than the built-in SecureNAT function. For instance, you can expect your Internet throughput speeds to increase by 100+ mbps (if your connection can handle it). It is important that you manually configure SoftEther VPN to use the new local bridge after setting this up. It will be outlined below.

By default, the IP addresses handed out by dnsmasq will be 10.42.10.10 - 10.42.10.100. The default gateway is 10.42.10.1.

### Installation (Ubuntu)
There's two methods of doing this. If you've already set up the SoftEther VPN Server, use the script below.
``` bash
wget -O se-install https://raw.githubusercontent.com/icoexist/softether-autoinstall/master/ubuntu/se-install-ubuntu.bash && chmod +x se-install && ./se-install
```

If you are just now installing SoftEther VPN Server, then select option 1 when asked "Are you going to use the bridge option on the VPN server?".

### SoftEther VPN Server Configuration
**Disable SecureNAT** [example here](https://upload.icoexist.io/2019/04/2019-04-25_22-46-40.mp4)
- Open the SoftEther VPN Server Management Utility
- Connect to your VPN server
- Select the VPN hub (or whatever hub you use on the VPN server) and click “Manage Virtual Hub”
- Click “Virtual NAT And Virtual DHCP Server (SecureNAT)”
- Click Disable, then exit to main configuration screen

**Create Local Bridge** [example here](https://upload.icoexist.io/2019/04/2019-04-25_22-49-08.mp4)
- Click “Local Bridge Setting”
- Under “New Local Bridge Definition” select the VPN hub (or whatever hub you use on the VPN server)
- Select the “Bridge with New Tap Device”
- Name the device soft and click “Create Local Bridge”
- Verify that the new device was create by running ifconfig tap_soft in a SSH terminal session. You should see something like this:

![Output example](https://forum.icoexist.io/uploads/default/original/1X/b20b7e2c67d55a9b75238b53dc62797ee9d7fbb8.png)

### Enable NAT and enable postrouting
We need to create a file in /etc/sysctl.d/ to enable ipv4 forwarding. Use the following command to create this file:
`nano /etc/sysctl.d/ipv4_forwarding.conf`
and insert the following into the file:
`net.ipv4.ip_forward = 1`

Again, save and close the file by hitting Ctrl + X then [ENTER].

Now we must enable this new option by issuing the following command:
`sysctl --system`

Now we need to add a POSTROUTING rule to iptables to correctly route traffic and enable NAT. Please replace [YOUR VPS IP ADDRESS] with the public IP address of your server.
`iptables -t nat -A POSTROUTING -s 10.42.10.0/24 -j SNAT --to-source [YOUR VPS IP ADDRESS]`

This rule will exist until the next system reboot, so to keep it persistent we will install iptables-persistent
`apt install iptables-persistent`

### Restart dnsmasq and SoftEther VPN Server
If everything above was done correctly, all we need to do now is to restart the DHCP server and the running SoftEther VPN server.
`/etc/init.d/dnsmasq restart && /etc/init.d/vpnserver restart`

### Need help?
Check out the forum post [here](https://forum.icoexist.io/t/how-to-use-softether-vpn-with-local-bridge-ubuntu/91) for a more in-depth explanation. If you can't seem to get your server to work at all, try running the install script again so you get a fresh start.

## Uninstall SE-VPN Server [Ubuntu Only]
As of now, this bash script will only work with Ubuntu due to the use of `update-rc.d`.
```
wget -O se-uninstall https://raw.githubusercontent.com/icoexist/softether-autoinstall/master/ubuntu/se-uninstall.bash && chmod 770 se-uninstall && ./se-uninstall
```

## Configure SoftEther
### Execute vpncmd
To execute SoftEther's cmd utility, use `sudo /usr/local/vpnserver/vpncmd` <-- This applies if you used my scripts. If you've installed SE yourself, find the vpnserver directory.

With `vpncmd` you are able to change every option in regard to SoftEther. It has the same exact purpose for the GUI version you can obtain on MacOS and Windows. I encourage people to use `vpncmd` because it can be easier than the GUI, plus there's no need to download anything since you can configure the entire server from an SSH session.

### Set a server password
It is important that you set a server password. This should be the first thing you do after launching the `vpncmd` utility. To set a password, type `serverpasswordset` into your terminal after you've launched the `vpncmd` utility. For verification, you have to type the password twice.

### Quick-start Guide
This section will provide you with a list of things to get you started with your VPN server. I'll have more commands listed below this section.

1. Start the `vpncmd` utility with `sudo /usr/local/vpncmd`
2. Set a server password with `ServerPasswordSet`
3. Select the DEFAULT hub with `hub default`
4. Create a new user with `UserCreate` | You can either use `UserCreate` or `UserCreate [username]`
5. Set a password for the new user with `UserPasswordSet` | You can either use `UserPasswordSet` or `UserPasswordSet [username]`
6. Enable SecureNAT for the DEFAULT hub with `SecurenatEnable`

   Optional: You can enable L2TP/IPsec with `IpsecEnable`. It is recommended that if you use this option, you only enable L2TP/IPsec. Do not enable RAW L2TP w/o encrpytion. You will be asked to set a pre-shared key for the IPsec server, you can use anything. I've used `vpn` as a pre-shared key for ages. Remember that this is NOT a password for the server or a user, so it's safe to use that. You'll also be asked for the default hub in the event that a user does not specify the hub to connect to in their username, you'll set this to `default` if you haven't changed any hub names. If you're more advanced user and have multiple hubs, you can specify what hub a user connects to by putting it in their username on the client. For instance `icoexist@public` or `icoexist@hub2`.

If everything was done properly, you're ready to use your new VPN server! To add new users, just launch the `vpncmd` utility and repeat steps 3 - 5.

### Other Options
#### Change SoftEther Ports
You can change the ports that SoftEther VPN server will use to listen for incoming connections. If you're using the `vpncmd` utility, you can list the current ports with `listenerlist`.

`ListenerCreate` - Creates a new listener on a specified port   
`ListenerDelete` - Deletes a listener on a specfied port   
`ListenerEnable` - Enables a listener on a specified port   
`ListenerDisable` - Disables a listener on a specified port

#### Manage Users & User Policies
SoftEther VPN server allows you to manage users and their policies. Below are some popular commands and descriptions on what they do. Remember that you first have to select a hub before you can manage users, as each hub has its own users.

`UserList` - Displays a list of users   
`UserGet [username]` - Displays information on a specified user   
`UserCreate [username]` - Creates a user   
`UserPasswordSet [username]` - Sets a password for specified user   
`UserDelete` - Deletes a specified user   
`UserPolicySet` - Sets a policy for a specified user | It is recommended that you enable "Privacy Filter Mode" on all newly created users on the same hub, unless you WANT them to see each other. To do this, type `UserPolicySet` then when it asks for what policy, type `PrivacyFilter`. It will ask for the new value, to enable it enter `1`, to disable it enter `0`.   
`UserPolicyRemove` - Removes a policy from a specified user

#### Manage Hubs & Hub Policies
SoftEther VPN server also allows you to manage virtual hubs and their policies. Below are some popular commands and descriptions on what they do. Remember that you first have to select a hub before you can manage it.

`Hub [HubName]` - Selects a hub for management   
`HubCreate [HubName]` - Creates a new virtual hub   
`HubDelete [HubName]` - Deletes a specified hub   
`HubList` - Lists the virtual hubs on the VPN server   
`AdminOptionList` - Get List of Virtual Hub Administration Options   
`AdminOptionSet` - Set Values of Virtual Hub Administration Options   

### Commands List

 `About`                      - Display the version information   
 `AcAdd`                      - Add Rule to Source IP Address Limit List (IPv4)   
 `AcAdd6`                     - Add Rule to Source IP Address Limit List (IPv6)   
 `AcDel`                      - Delete Rule from Source IP Address Limit List   
 `AcList`                     - Get List of Rule Items of Source IP Address Limit List   
 `AccessAdd`                  - Add Access List Rules (IPv4)   
 `AccessAdd6`                 - Add Access List Rules (IPv6)   
 `AccessAddEx`                - Add Extended Access List Rules (IPv4: Delay, Jitter and Packet Loss Generating)   
 `AccessAddEx6`               - Add Extended Access List Rules (IPv6: Delay, Jitter and Packet Loss Generating)   
 `AccessDelete`               - Delete Rule from Access List   
 `AccessDisable`              - Disable Access List Rule   
 `AccessEnable`               - Enable Access List Rule   
 `AccessList`                 - Get Access List Rule List    
 `AdminOptionList`            - Get List of Virtual Hub Administration Options   
 `AdminOptionSet`             - Set Values of Virtual Hub Administration Options   
 `BridgeCreate`               - Create Local Bridge Connection   
 `BridgeDelete`               - Delete Local Bridge Connection   
 `BridgeDeviceList`           - Get List of Network Adapters Usable as Local Bridge   
 `BridgeList`                 - Get List of Local Bridge Connection   
 `CAAdd`                      - Add Trusted CA Certificate   
 `CADelete`                   - Delete Trusted CA Certificate   
 `CAGet`                      - Get Trusted CA Certificate   
 `CAList`                     - Get List of Trusted CA Certificates   
 `Caps`                       - Get List of Server Functions/Capability   
 `CascadeAnonymousSet`        - Set User Authentication Type of Cascade Connection to Anonymous Authentication   
 `CascadeCertGet`             - Get Client Certificate to Use for Cascade Connection   
 `CascadeCertSet`             - Set User Authentication Type of Cascade Connection to Client Certificate Authentication   
 `CascadeCompressDisable`     - Disable Data Compression when Communicating by Cascade Connection   
 `CascadeCompressEnable`      - Enable Data Compression when Communicating by Cascade Connection   
 `CascadeCreate`              - Create New Cascade Connection   
 `CascadeDelete`              - Delete Cascade Connection Setting   
 `CascadeDetailSet`           - Set Advanced Settings for Cascade Connection   
 `CascadeEncryptDisable`      - Disable Encryption when Communicating by Cascade Connection   
 `CascadeEncryptEnable`       - Enable Encryption when Communicating by Cascade Connection   
 `CascadeGet`                 - Get the Cascade Connection Setting   
 `CascadeList`                - Get List of Cascade Connections   
 `CascadeOffline`             - Switch Cascade Connection to Offline Status   
 `CascadeOnline`              - Switch Cascade Connection to Online Status   
 `CascadePasswordSet`         - Set User Authentication Type of Cascade Connection to Password Authentication   
 `CascadePolicySet`           - Set Cascade Connection Session Security Policy   
 `CascadeProxyHttp`           - Set Connection Method of Cascade Connection to be via an HTTP Proxy Server   
 `CascadeProxyNone`           - Specify Direct TCP/IP Connection as the Connection Method of Cascade Connection   
 `CascadeProxySocks`          - Set Connection Method of Cascade Connection to be via an SOCKS Proxy Server   
 `CascadeRename`              - Change Name of Cascade Connection   
 `CascadeServerCertDelete`    - Delete the Server Individual Certificate for Cascade Connection   
 `CascadeServerCertDisable`   - Disable Cascade Connection Server Certificate Verification Option   
 `CascadeServerCertEnable`    - Enable Cascade Connection Server Certificate Verification Option   
 `CascadeServerCertGet`       - Get the Server Individual Certificate for Cascade Connection   
 `CascadeServerCertSet`       - Set the Server Individual Certificate for Cascade Connection   
 `CascadeSet`                 - Set the Destination for Cascade Connection   
 `CascadeStatusGet`           - Get Current Cascade Connection Status   
 `CascadeUsernameSet`         - Set User Name to Use Connection of Cascade Connection   
 `Check`                      - Check whether SoftEther VPN Operation is Possible   
 `ClusterConnectionStatusGet` - Get Connection Status to Cluster Controller   
 `ClusterMemberCertGet`       - Get Cluster Member Certificate   
 `ClusterMemberInfoGet`       - Get Cluster Member Information   
 `ClusterMemberList`          - Get List of Cluster Members   
 `ClusterSettingController`   - Set VPN Server Type as Cluster Controller   
 `ClusterSettingGet`          - Get Clustering Configuration of Current VPN Server   
 `ClusterSettingMember`       - Set VPN Server Type as Cluster Member   
 `ClusterSettingStandalone`   - Set VPN Server Type as Standalone   
 `ConfigGet`                  - Get the current configuration of the VPN Server   
 `ConfigSet`                  - Write Configuration File to VPN Server   
 `ConnectionDisconnect`       - Disconnect TCP Connections Connecting to the VPN Server   
 `ConnectionGet`              - Get Information of TCP Connections Connecting to the VPN Server   
 `ConnectionList`             - Get List of TCP Connections Connecting to the VPN Server   
 `Crash`                      - Raise a error on the VPN Server / Bridge to terminate the process forcefully.   
 `CrlAdd`                     - Add a Revoked Certificate   
 `CrlDel`                     - Delete a Revoked Certificate   
 `CrlGet`                     - Get a Revoked Certificate   
 `CrlList`                    - Get List of Certificates Revocation List   
 `Debug`                      - Execute a Debug Command   
 `DhcpDisable`                - Disable Virtual DHCP Server Function of SecureNAT Function   
 `DhcpEnable`                 - Enable Virtual DHCP Server Function of SecureNAT Function   
 `DhcpGet`                    - Get Virtual DHCP Server Function Setting of SecureNAT Function   
 `DhcpSet`                    - Change Virtual DHCP Server Function Setting of SecureNAT Function   
 `DhcpTable`                  - Get Virtual DHCP Server Function Lease Table of SecureNAT Function   
 `DynamicDnsGetStatus`        - Show the Current Status of Dynamic DNS Function   
 `DynamicDnsSetHostname`      - Set the Dynamic DNS Hostname   
 `EtherIpClientAdd`           - Add New EtherIP / L2TPv3 over IPsec Client Setting to Accept EthreIP / L2TPv3 Client Devices   
 `EtherIpClientDelete`        - Delete an EtherIP / L2TPv3 over IPsec Client Setting   
 `EtherIpClientList`          - Get the Current List of EtherIP / L2TPv3 Client Device Entry Definitions   
 `ExtOptionList`              - Get List of Virtual Hub Extended Options   
 `ExtOptionSet`               - Set a Value of Virtual Hub Extended Options   
 `Flush`                      - Save All Volatile Data of VPN Server / Bridge to the Configuration File   
 `GroupCreate`                - Create Group   
 `GroupDelete`                - Delete Group   
 `GroupGet`                   - Get Group Information and List of Assigned Users   
 `GroupJoin`                  - Add User to Group   
 `GroupList`                  - Get List of Groups   
 `GroupPolicyRemove`          - Delete Group Security Policy   
 `GroupPolicySet`             - Set Group Security Policy   
 `GroupSet`                   - Set Group Information   
 `GroupUnjoin`                - Delete User from Group   
 `Hub`                        - Select Virtual Hub to Manage   
 `HubCreate`                  - Create New Virtual Hub   
 `HubCreateDynamic`           - Create New Dynamic Virtual Hub (For Clustering)   
 `HubCreateStatic`            - Create New Static Virtual Hub (For Clustering)   
 `HubDelete`                  - Delete Virtual Hub   
 `HubList`                    - Get List of Virtual Hubs   
 `HubSetDynamic`              - Change Virtual Hub Type to Dynamic Virtual Hub   
 `HubSetStatic`               - Change Virtual Hub Type to Static Virtual Hub   
 `IPsecEnable`                - Enable or Disable IPsec VPN Server Function   
 `IPsecGet`                   - Get the Current IPsec VPN Server Settings   
 `IpDelete`                   - Delete IP Address Table Entry   
 `IpTable`                    - Get the IP Address Table Database   
 `KeepDisable`                - Disable the Keep Alive Internet Connection Function   
 `KeepEnable`                 - Enable the Keep Alive Internet Connection Function   
 `KeepGet`                    - Get the Keep Alive Internet Connection Function   
 `KeepSet`                    - Set the Keep Alive Internet Connection Function   
 `LicenseAdd`                 - Add License Key Registration   
 `LicenseDel`                 - Delete Registered License   
 `LicenseList`                - Get List of Registered Licenses   
 `LicenseStatus`              - Get License Status of Current VPN Server   
 `ListenerCreate`             - Create New TCP Listener   
 `ListenerDelete`             - Delete TCP Listener   
 `ListenerDisable`            - Stop TCP Listener Operation   
 `ListenerEnable`             - Begin TCP Listener Operation   
 `ListenerList`               - Get List of TCP Listeners   
 `LogDisable`                 - Disable Security Log or Packet Log   
 `LogEnable`                  - Enable Security Log or Packet Log   
 `LogFileGet`                 - Download Log file   
 `LogFileList`                - Get List of Log Files   
 `LogGet`                     - Get Log Save Setting of Virtual Hub   
 `LogPacketSaveType`          - Set Save Contents and Type of Packet to Save to Packet Log   
 `LogSwitchSet`               - Set Log File Switch Cycle   
 `MacDelete`                  - Delete MAC Address Table Entry   
 `MacTable`                   - Get the MAC Address Table Database   
 `MakeCert`                   - Create New X.509 Certificate and Private Key (1024 bit)   
 `MakeCert2048`               - Create New X.509 Certificate and Private Key (2048 bit)   
 `NatDisable`                 - Disable Virtual NAT Function of SecureNAT Function   
 `NatEnable`                  - Enable Virtual NAT Function of SecureNAT Function   
 `NatGet`                     - Get Virtual NAT Function Setting of SecureNAT Function   
 `NatSet`                     - Change Virtual NAT Function Setting of SecureNAT Function   
 `NatTable`                   - Get Virtual NAT Function Session Table of SecureNAT Function   
 `Offline`                    - Switch Virtual Hub to Offline   
 `Online`                     - Switch Virtual Hub to Online   
 `OpenVpnEnable`              - Enable / Disable OpenVPN Clone Server Function   
 `OpenVpnGet`                 - Get the Current Settings of OpenVPN Clone Server Function   
 `OpenVpnMakeConfig`          - Generate a Sample Setting File for OpenVPN Client   
 `OptionsGet`                 - Get Options Setting of Virtual Hubs   
 `PolicyList`                 - Display List of Security Policy Types and Settable Values   
 `RadiusServerDelete`         - Delete Setting to Use RADIUS Server for User Authentication   
 `RadiusServerGet`            - Get Setting of RADIUS Server Used for User Authentication   
 `RadiusServerSet`            - Set RADIUS Server to use for User Authentication   
 `Reboot`                     - Reboot VPN Server Service   
 `RouterAdd`                  - Define New Virtual Layer 3 Switch   
 `RouterDelete`               - Delete Virtual Layer 3 Switch   
 `RouterIfAdd`                - Add Virtual Interface to Virtual Layer 3 Switch   
 `RouterIfDel`                - Delete Virtual Interface of Virtual Layer 3 Switch   
 `RouterIfList`               - Get List of Interfaces Registered on the Virtual Layer 3 Switch   
 `RouterList`                 - Get List of Virtual Layer 3 Switches   
 `RouterStart`                - Start Virtual Layer 3 Switch Operation   
 `RouterStop`                 - Stop Virtual Layer 3 Switch Operation   
 `RouterTableAdd`             - Add Routing Table Entry for Virtual Layer 3 Switch   
 `RouterTableDel`             - Delete Routing Table Entry of Virtual Layer 3 Switch   
 `RouterTableList`            - Get List of Routing Tables of Virtual Layer 3 Switch    
 `SecureNatDisable`           - Disable the Virtual NAT and DHCP Server Function (SecureNat Function)   
 `SecureNatEnable`            - Enable the Virtual NAT and DHCP Server Function (SecureNat Function)   
 `SecureNatHostGet`           - Get Network Interface Setting of Virtual Host of SecureNAT Function   
 `SecureNatHostSet`           - Change Network Interface Setting of Virtual Host of SecureNAT Function   
 `SecureNatStatusGet`         - Get the Operating Status of the Virtual NAT and DHCP Server Function (SecureNat Function)   
 `ServerCertGet`              - Get SSL Certificate of VPN Server   
 `ServerCertRegenerate`       - Generate New Self-Signed Certificate with Specified CN (Common Name) and Register on VPN Server   
 `ServerCertSet`              - Set SSL Certificate and Private Key of VPN Server   
 `ServerCipherGet`            - Get the Encrypted Algorithm Used for VPN Communication.   
 `ServerCipherSet`            - Set the Encrypted Algorithm Used for VPN Communication.   
 `ServerInfoGet`              - Get server information   
 `ServerKeyGet`               - Get SSL Certificate Private Key of VPN Server   
 `ServerPasswordSet`          - Set VPN Server Administrator Password   
 `ServerStatusGet`            - Get Current Server Status   
 `SessionDisconnect`          - Disconnect Session   
 `SessionGet`                 - Get Session Information   
 `SessionList`                - Get List of Connected Sessions   
 `SetEnumAllow`               - Allow Enumeration by Virtual Hub Anonymous Users   
 `SetEnumDeny`                - Deny Enumeration by Virtual Hub Anonymous Users   
 `SetHubPassword`             - Set Virtual Hub Administrator Password   
 `SetMaxSession`              - Set the Max Number of Concurrently Connected Sessions for Virtual Hub   
 `SstpEnable`                 - Enable / Disable Microsoft SSTP VPN Clone Server Function   
 `SstpGet`                    - Get the Current Settings of Microsoft SSTP VPN Clone Server Function   
 `StatusGet`                  - Get Current Status of Virtual Hub   
 `SyslogDisable`              - Disable syslog Send Function   
 `SyslogEnable`               - Set syslog Send Function   
 `SyslogGet`                  - Get syslog Send Function   
 `TrafficClient`              - Run Network Traffic Speed Test Tool in Client Mode   
 `TrafficServer`              - Run Network Traffic Speed Test Tool in Server Mode   
 `UserAnonymousSet`           - Set Anonymous Authentication for User Auth Type   
 `UserCertGet`                - Get Certificate Registered for Individual Certificate Authentication User   
 `UserCertSet`                - Set Individual Certificate Authentication for User Auth Type and Set Certificate   
 `UserCreate`                 - Create User    
 `UserDelete`                 - Delete User   
 `UserExpiresSet`             - Set User's Expiration Date   
 `UserGet`                    - Get User Information   
 `UserList`                   - Get List of Users   
 `UserNTLMSet`                - Set NT Domain Authentication for User Auth Type   
 `UserPasswordSet`            - Set Password Authentication for User Auth Type and Set Password   
 `UserPolicyRemove`           - Delete User Security Policy   
 `UserPolicySet`              - Set User Security Policy   
 `UserRadiusSet`              - Set RADIUS Authentication for User Auth Type   
 `UserSet`                    - Change User Information   
 `UserSignedSet`              - Set Signed Certificate Authentication for User Auth Type   
 `VpnAzureGetStatus`          - Show the current status of VPN Azure function   
 `VpnAzureSetEnable`          - Enable / Disable VPN Azure Function   
 `VpnOverIcmpDnsEnable`       - Enable / Disable the VPN over ICMP / VPN over DNS Server Function   
 `VpnOverIcmpDnsGet`          - Get Current Setting of the VPN over ICMP / VPN over DNS Function  

## Copyright & Credit
The SoftEther VPN Project is managed by Daiyuu Nobori, the creator and owner of the SoftEther VPN Project. You can find their stable GitHub repo here: https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/   
The SoftEther VPN Developer branch is located here: https://github.com/SoftEtherVPN/SoftEtherVPN

I have not modified the code of the SoftEther VPN Project itself. I simply provide an installer that will make your life *just a little easier*.

For reference, their copyright statement is below.

```
Copyright (c) SoftEther Project at University of Tsukuba, Japan.

The development of SoftEther VPN was supported by the MITOH Project,
a research and development project by Japanese Government,
subsidized by METI (Ministry of Economy, Trade and Industry of Japan),
administrated by IPA (Information Promotion Agency, Japan).
https://www.ipa.go.jp/english/humandev/

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2
as published by the Free Software Foundation.
```
