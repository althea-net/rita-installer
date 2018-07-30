# Althea Installer

This is the installer for Althea on general purpose Linux. Whereas the [Althea
firmware](https://github.com/althea-mesh/althea-firmware) which is targeted at
OpenWRT compatible routers this installer will work on normal deskop and server
Linux distributions.

Eventually we will publish more traditional packages, right now this automates
the installation process and system setup.

----------------

Is this where I get Althea?
------------------------------------------

If you just want Althea on your computer please download a release from
our website once it becomes available. This page is for developers who want
to help improve Althea. Or technically advanced users who want to try out cutting
edge changes.

Getting Started
--------------------

First off you need a Linux machine with Ansible.

On Ubuntu and Debian:
> sudo apt install python-pip libsqlite3-dev libssl-dev build-essential

> sudo pip install ansible

On Fedora:
> sudo dnf install ansible sqllite3-devel openssl-devel gcc

On Centos and RHEL:
> sudo yum install ansible sqllite3-devel openssl-devel gcc

All other required software will be installed by the setup playbook

Setting up an Exit server
-------------------------

An Althea Exit server is essentially a WireGuard proxy server setup to integrate
with the mesh network.

Create a file named `hosts` and populate it with the ip addreses
of your exit server like so.

>[exit]
>server a
>server b

You can then put some sort of load balancer in front of multiple servers. Optionally
of course.

Profiles are variables files pulled into Ansible for easy customization of what
the playbook will do. Edit `profiles/exit-example.yml' to match your needs. If you are
running against localhost use the `-c local` option and put 'localhost' in your
hosts file.

Once configured run

> ansible-playbook -e @profiles/[your profile name or exit-example.yml] <-c local if running against localhost> -i <your hosts file or ci-hosts> install-exit.yml

To update the users or gateways list simply run again. Users should not be disrupted
unless a new gateway was added. Even then the disruption should be very minor.

Setting up an Althea node
-------------------------

An Althea intermediary node will pass traffic for other users on the mesh 
as well as provide secure internet acces over the mesh from a configured lan
port. This also includes gateway functionality if you include an external_nic
in the profile.

For anything you don't wish to configure (lan, wan, mesh) just provide an empty list. 

Create a file named `hosts` and populate it with the ip addreses
of your exit server like so.

>[intermediary]
>server a
>server b

Profiles are variables files pulled into Ansible for easy customization of what
the playbook will do. Edit `profiles/example.yml` to match your needs. This should
mostly just involve setting the correct interfaces for your machine. If you are
running against localhost use the `-c local` option and put 'localhost' in your
hosts file.

Once configured run

> ansible-playbook -e @profiles/[your profile name or example.yml] <-c local if running against localhost> -i <your hosts file or ci-hosts>  install-intermediary.yml

To update the Rita version just run again after building a new binary and placing
it in the same folder as the playbook



