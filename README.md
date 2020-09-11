Vagrant ready image
===================

Ubuntu image with systemd and others requirements to be used with Vagrant.

This image use sudo and works with the Ansible provisioner (`become: yes` required).

Supported tags and `Dockerfile` links
-------------------------------------

* [`20.04`,`latest`](https://github.com/langouste/docker-vagrant-ready/blob/master/Dockerfile)

Usage
-----

See [ansible-skeleton](https://github.com/langouste/ansible-skeleton) for an usage example.

Credits
-------

Based on these works: 

- [boxrick/bionic-docker-ansible](https://github.com/boxrick/bionic-docker-ansible)
- [j8r/dockerfiles](https://github.com/j8r/dockerfiles/tree/master/systemd)
