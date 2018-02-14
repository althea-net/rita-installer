# Althea Installer

This is the installer for Althea on general purpose Linux. Whereas the [Althea
firmware](https://github.com/althea-mesh/althea-firmware) which is targeted at
OpenWRT compatible routers this installer will work on normal deskop and server
Linux distributions.

Eventually we will publish more traditional packages, in the meantime this
clones and builds the latest release of various Althea components locally. So
to update Althea just run the deployment script again.

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
> sudo apt install python-pip

> sudo pip install ansible

On Fedora:
> sudo dnf install ansible

On Centos and RHEL:
> sudo yum install ansible

All other required software will be installed by the setup playbook

Setting up an Exit server
-------------------------

An Althea Exit server is essentially a WireGuard proxy server setup to integrate
with the mesh network.

To allow Babel to handle negotiation all the way up to the exit server 'gateway'
devices created a tunnel over the internet to the exit server, this tunnel is
used to run Babel. In this way multiple gateways can operate in one mesh and traffic
will be sent to the best possible route for the exit server.

This results in the major quirk of the current exit setup, while gateways dial
out to the exit server, regular client devices are polled by the exit server
not the other way around. This is because WireGuard doesn't like nested tunnels.

Regardless create a file named `hosts` and populate it with the ip addreses
of your exit server like so.

>[exit]
>server a
>server b

You can then put some sort of load balancer in front of multiple servers. Optionally
of course.

Profiles are variables files pulled into Ansible for easy customization of what
the playbook will do. Edit `profiles/example.yml' to match your needs. You may
notice that the Althea firmware repo and the gateway, user, and intermediary install
playbooks in this repo produce a short list of yaml variables required by the exit
that can be simply copy pasted into the users/gateways lists.

Once configured run

> ansible-playbook -e profiles/profile-name.yml install-exit.yml

To update the users or gateways list simply run again. Users should not be disrupted
unless a new gateway was added. Even then the disruption should be very minor.


