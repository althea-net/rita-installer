# Althea Installer

This repo contains tools for setting up an Althea client/relay/gateway (here on known as a client)
as well as an Althea exit server. The client softare is what the [Althea firmware](https://github.com/althea-mesh/althea-firmware) packges as a complete system image.

If you are looking for a simple client to spin up in a vm please use [The x86 OpenWrt image](https://github.com/althea-mesh/althea-firmware/releases/) as it's a much more polished package.

This repo is useful for when you want to build your own client on a non-openwrt platform or when
you want to setup your own exit server.

---

## Is this where I get Althea?

Althea runs on home routers, not typically on normal computers. Please see [althea.net/firmware](https://althea.net/firmware) for a list of compatible devices and instructions.

This repository is for technical users who want to setup their own exit or build a special purpose
Althea client.

## Getting Started

First off you need a Linux machine with Ansible.

On Ubuntu and Debian:

> sudo apt install python-pip libsqlite3-dev libssl-dev build-essential

> sudo pip install ansible

On Fedora:

> sudo dnf install ansible sqllite3-devel openssl-devel gcc

On Centos and RHEL:

> sudo yum install ansible sqllite3-devel openssl-devel gcc

All other required software will be installed by the setup playbook

## Setting up an Exit server

An Althea Exit server is essentially a WireGuard proxy server setup to integrate
with the mesh network.

Create a file named `hosts` and populate it with the ip addreses
of your exit server like so.

```
[exit]
1.1.1.1 description="My Exit Primary!" primary=True  wg_private_key="" wg_public_key=""
2.2.2.2 description="My Exit Secondary!"               wg_private_key="" wg_public_key=""
[exit:vars]
eth_private_key = ""
fee_multiplier = 20
enterprise = true
mailer=True
email_address=""
smtp_url=""
smtp_domain=""
smtp_username=""
smtp_password=""
balance_notification_interval=86400
balance_notification_body="Your Althea router has a low balance! Your service will be slow until more funds are added. Visit althea.net/top-up"
database_uri=""
external_nic=""
system_chain="Rinkeby"
full_nodes=["https://rinkeby.infura.io/v3/174d2ebf288a452fab8a8f90eab57be7"]
#system_chain="Ethereum"
#full_nodes=["https://eth.althea.org:443", "https://mainnet.infura.io/v3/
6b080f02d7004a8394444cdf232a7081"]
#system_chain="Xdai"
#full_nodes=["https://dai.althea.org:443"]
exit_mesh_ip="fd00::xxxxx"
wg_exit_public_key=""
wg_exit_private_key=""
allowed_country_codes="[]"
exit_price_wei = 714000
standalone = true
entry_timeout = "86400"
debt_limit = false
```

There's a lot of data that goes into the hosts file for an exit. This configuration outlines
a cluster of two exits with a primary and secondary failover. If you configure your gateway with
a url containing multiple DNS entires for each server Althea clients will automatically connect and failover. Sadly the failover process isn't quite perfect and having active failover may somtimes create minor connection disruptions for the users.

If you don't want to run multiple servers simply remove that line.

next are authentication settings, I've included blank SMTP mail auth settings. If you leave mailer
True you can fill out those details and have the exit send users emails to authorize. If you turn
mailer to False it will disable authentication of new users.

Finally you need to generate another set of keys and uncomment the appropriate blockchain full nodes and settings. You must also select an arbitrary valid ipv6 address out of the fd00::/8 range

I've left 'standalone' on, this should setup a local postgres server for you to use but it's not as well tested as having standalone false and using a postgres database uri.

When setting up a new postgres database you'll need to run the migrations [here](https://github.com/althea-net/althea_rs/tree/master/exit_db)

```
# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# install diesel
cargo install diesel_cli
# clone althea_rs
git clone https://github.com/althea-net/althea_rs
# run the migrations
cd althea_rs/exit_db
diesel migration run --database-url=""
```

Now that everything is finally configured you can run ansible to configure your exit server

> ansible-playbook -i \[your hosts file] install-exit.yml

To update the exit software simply run the playbook again, there will be a minor disruption
for users

## Setting up an Althea node

An Althea client/relay node will pass traffic for other users on the mesh
as well as provide secure internet acces over the mesh from a configured lan
port. This also includes gateway functionality if you include an external_nic
in the profile.

For anything you don't wish to configure (lan, wan, mesh) just provide an empty list.

Create a file named `hosts` and populate it with the ip addreses
of your devices server like so. You can use 'localhost' for your local machine.

```
[intermediary]
localhost
```

Profiles are variables files pulled into Ansible for easy customization of what
the playbook will do. Edit `profiles/example.yml` to match your needs. This should
mostly just involve setting the correct interfaces for your machine. If you are
running against localhost use the `-c local` option and put 'localhost' in your
hosts file.

Once configured run

> ansible-playbook -e @profiles/[your profile name or example.yml][-c local if running against localhost] -i [your hosts file or ci-hosts] install-intermediary.yml

To update the Rita version just run again after building a new binary and placing
it in the same folder as the playbook
