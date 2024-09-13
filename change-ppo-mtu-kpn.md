The UCG Ultra keeps it config in a file name `ubios-udapi-server.state` which is stored in `udapi-config/ubios-udapi-server`.
It's a json file that looks a lot like the json file from the USG, however it's not meant for direct modification.

[Reference](https://community.ui.com/questions/Research---Understanding-ubios-udapi-server-state-and-how-to-make-changes-persist-on-UniFi-consoles/0bc217af-2e26-48b3-ba71-29630a06ffdb?page=1)

It's modified like this:
1) copy the file, in this example to the home folder:
`cp /data/udapi-config/ubios-udapi-server/ubios-udapi-server.state ~`

2) create a copy of the file and name it udapi-request.json, this is the copy we are changing, the other one will serve as a backup
`cp ~/ubios-udapi-server.state ~/udapi-request.json`

3) we need to modify the mtu values for ETH4, ETH4.6 and PPP0 interfaces, here are the relevant sections from the json:
```json
identification": {
    "id": "eth4",
    "type": "ethernet"
   },
   "status": {
    "arpProxy": false,
    "enabled": true,
    "mtu": 1500,  <-- change to 1512
    "speed": "auto"
   }
{
   "addresses": [],
   "identification": {
    "id": "eth4.6",
    "type": "vlan"
   },
   "status": {
    "arpProxy": false,
    "enabled": true,
    "mtu": 1500,  <-- change to 1508
    "speed": "auto"
   },
"pppoe": {
    "encryption": false,
    "id": 0,
    "interface": {
     "id": "eth4.6"
    },
    "mru": 1492, <-- change to 1500
    "mruNegotiation": false,
    "password": "internet",
    "username": "internet"
   },
   "status": {
    "arpProxy": false,
    "baseReachableTime": 30,
    "comment": "WAN",
    "enabled": true,
    "mtu": 1492,  <-- change to 1500
    "speed": "auto"
   }
```
4) commit the new json:
```
cd ~
ubios-udapi-client PUT /system/ubios/udm/configuration @udapi-request.json
```

