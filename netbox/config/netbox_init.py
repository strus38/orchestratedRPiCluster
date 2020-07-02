import pynetbox 
import yaml 
import os 
import requests
import urllib3
from config import NETBOX_URL, NETBOX_TOKEN

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

data_file = "site.yaml"

with open(data_file) as f: 
    data = yaml.safe_load(f.read())

# Instantiate pynetbox.api class with URL of your NETBOX and your API TOKEN
session = requests.Session()
session.verify = False
nb = pynetbox.api(url=NETBOX_URL, token=NETBOX_TOKEN)
nb.http_session = session

# sites: 
for site in data["sites"]: 
    print(f"Creating or Updating Site {site['name']}")
    nb_data = nb.dcim.sites.get(slug=site["slug"])
    if not nb_data: 
        nb_data = nb.dcim.sites.create(name=site["name"], slug=site["slug"])

for region in data["regions"]: 
    print(f"Creating or Updating Region {region['name']}")
    nb_data = nb.dcim.regions.get(slug=region["slug"])
    if not nb_data: 
        nb_data = nb.dcim.regions.create(name=region["name"], slug=region["slug"], site_slug=region["site_slug"])

for rack in data["racks"]: 
    print(f"Creating or Updating Rack {rack['name']}")
    nb_data = nb.dcim.racks.get(slug=rack["slug"])
    if not nb_data: 
        nb_data = nb.dcim.racks.create(
            name=rack["name"], 
            slug=rack["slug"], 
            site=nb.dcim.sites.get(slug=rack["site_slug"]).id, 
            region=nb.dcim.regions.get(slug=rack["region_slug"]).id, 
            u_height=rack["height"])

# manufacturers 
for manufacturer in data["manufacturers"]: 
    print(f"Creating or Updating Manufacture {manufacturer['name']}")
    nb_data = nb.dcim.manufacturers.get(slug=manufacturer["slug"])
    if not nb_data: 
        nb_data = nb.dcim.manufacturers.create(name=manufacturer["name"], slug=manufacturer["slug"])

# device_types
for device_type in data["device_types"]: 
    print(f"Creating or Updating device_type {device_type['model']}")
    nb_data = nb.dcim.device_types.get(slug=device_type["slug"])
    if not nb_data: 
        nb_data = nb.dcim.device_types.create(
            model=device_type["model"], 
            slug=device_type["slug"], 
            manufacturer=nb.dcim.manufacturers.get(slug=device_type["manufacturer_slug"]).id, 
            height=device_type["height"]
            )

# device_roles
for device_role in data["device_roles"]: 
    print(f"Creating or Updating device_role {device_role['name']}")
    nb_data = nb.dcim.device_roles.get(slug=device_role["slug"])
    if not nb_data: 
        nb_data = nb.dcim.device_roles.create(
            name=device_role["name"], 
            slug=device_role["slug"], 
            color=device_role["color"]
            )

# platforms
for platform in data["platforms"]: 
    print(f"Creating or Updating platform {platform['name']}")
    nb_data = nb.dcim.platforms.get(slug=platform["slug"])
    if not nb_data: 
        nb_data = nb.dcim.platforms.create(
            name=platform["name"], 
            slug=platform["slug"], 
            manufacturer=nb.dcim.manufacturers.get(slug=platform["manufacturer_slug"]).id, 
            )

# vrfs 
for vrf in data["vrfs"]: 
    print(f"Creating or Updating vrf {vrf['name']}")
    nb_data = nb.ipam.vrfs.get(rd=vrf["rd"])
    if not nb_data: 
        nb_data = nb.ipam.vrfs.create(name=vrf["name"], rd=vrf["rd"])

# vlan-groups
if "vlan_groups" in data:
    for group in data["vlan_groups"]: 
        print(f"Creating or updating vlan-group {group['name']}")
        nb_group = nb.ipam.vlan_groups.get(slug=group["slug"])
        if not nb_group: 
            nb_group = nb.ipam.vlan_groups.create(
                name = group["name"], 
                slug = group["slug"], 
                site=nb.dcim.sites.get(slug=group["site_slug"]).id,
            )
        # vlans
        for vlan in group["vlans"]: 
            print(f"Creating or updating vlan {vlan['name']}")
            nb_vlan = nb.ipam.vlans.get(
                group_id=nb_group.id, 
                vid=vlan["vid"],
                )
            if not nb_vlan: 
                nb_vlan = nb.ipam.vlans.create(
                    group=nb_group.id, 
                    site=nb_group.site.id, 
                    name=vlan["name"], 
                    vid=vlan["vid"], 
                    description=vlan["description"], 
                )
            if "prefix" in vlan.keys(): 
                print(f"Configuring prefix {vlan['prefix']}")
                nb_prefix = nb.ipam.prefixes.get(
                    vrf_id = nb.ipam.vrfs.get(rd=vlan["vrf"]).id, 
                    site_id=nb_group.site.id, 
                    vlan_vid=nb_vlan.vid, 
                )
                if not nb_prefix: 
                    # print("  Creating new prefix")
                    nb_prefix = nb.ipam.prefixes.create(
                        prefix=vlan["prefix"], 
                        vrf=nb.ipam.vrfs.get(rd=vlan["vrf"]).id,
                        description=vlan["description"],
                        site=nb_group.site.id, 
                        vlan=nb_vlan.id
                    )

# devices
for device in data["devices"]: 
    print(f"Creating or Updating device {device['name']}")
    nb_device = nb.dcim.devices.get(name=device["name"])
    if not nb_device: 
        nb_device = nb.dcim.devices.create(
            name=device["name"], 
            manufacturer=nb.dcim.manufacturers.get(slug=device["manufacturer_slug"]).id, 
            site=nb.dcim.sites.get(slug=device["site_slug"]).id,
            rack=nb.dcim.racks.get(slug=device["rack_slug"]).id,
            position=device["position"],
            face="front",
            device_role=nb.dcim.device_roles.get(slug=device["device_role_slug"]).id, 
            device_type=nb.dcim.device_types.get(slug=device["device_types_slug"]).id, 
            )
    if "interfaces" in device:
        for interface in device["interfaces"]: 
            print(f"  Creating or updating interface {interface['name']}")
            nb_interface = nb.dcim.interfaces.get(
                device_id=nb_device.id,
                type=interface["type"],
                name=interface["name"]
            )
            if not nb_interface: 
                nb_interface = nb.dcim.interfaces.create(
                    device=nb_device.id,
                    type=interface["type"],
                    name=interface["name"], 
                )
            if "description" in interface.keys():
                nb_interface.description = interface["description"]
            if "mgmt_only" in interface.keys():
                nb_interface.mgmt_only = interface["mgmt_only"]
            if "enabled" in interface.keys():
                nb_interface.enabled = interface["enabled"]
            if "mode" in interface.keys():
                nb_interface.mode = interface_mode[interface["mode"]]
                if "untagged_vlan" in interface.keys():
                    nb_interface.untagged_vlan = nb.ipam.vlans.get(
                        name=interface["untagged_vlan"]
                    ).id
                if "tagged_vlans" in interface.keys():
                    vl = [ nb.ipam.vlans.get(name=vlan_name).id for vlan_name in interface["tagged_vlans"] ]
                    # print("VLAN LIST")
                    # print(vl)
                    nb_interface.tagged_vlans = vl
            if "ip_addresses" in interface.keys(): 
                for ip in interface["ip_addresses"]: 
                    print(f"  Adding IP {ip['address']}")
                    nb_ipadd = nb.ipam.ip_addresses.get(
                        address = ip["address"], 
                        vrf_id = nb.ipam.vrfs.get(rd=ip["vrf"]).id,
                    )
                    if not nb_ipadd: 
                        nb_ipadd = nb.ipam.ip_addresses.create(
                            address = ip["address"], 
                            vrf = nb.ipam.vrfs.get(rd=ip["vrf"]).id,
                        )
                    nb_ipadd.interface = nb_interface.id
                    nb_ipadd.save()
                    if "primary" in ip.keys(): 
                        nb_device.primary_ip4 = nb_ipadd.id
                        nb_device.save()
        
        nb_interface.save()
