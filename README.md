# unifi-cloudgateway-ultra
scripts for unifi-cloudgateway ultra

- sonos.sh -> takes care of forwarding ssdp discovery packets, useful when you have Sonos in a different (IoT) vlan
- setmtu.sh -> script to change the mtu values for a KPN fiber connection (1500 for ppp0, 1512 for eth4 and 1508 for eth4.6)
- change-ppo-mtu-kpn.md -> the better way to permanently set the correct MTU values (setmtu.sh was the first attempt)
- udm-iptv.conf -> config file for KPN iTV, requires https://github.com/fabianishere/udm-iptv
