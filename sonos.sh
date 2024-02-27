#!/usr/bin/env bash
# requires multicast-relay.py script, place it in /data/on_boot.d/settings/
# br0 i my devices lan, br20 is my IoT VLAN...
python3 /data/on_boot.d/settings/multicast-relay.py  --noMDNS --interfaces br0 br20
