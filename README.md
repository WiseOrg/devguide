# Drupal local Development
This project is a fork of [Drupal Development VM](https://github.com/geerlingguy/drupal-vm)

**For Drupal 7 development.**

This project aims to make spinning up a simple local Drupal test/development environment incredibly quick and easy, and to introduce new developers to the wonderful world of Drupal development on local virtual machines (instead of crufty old MAMP/WAMP-based development).

It will install the following on an Ubuntu 14.04 (by default) linux VM:

  - Apache 2.4.x
  - PHP 5.5.x (configurable)
  - MySQL 5.5.x
  - Drush (configurable)
  - Drupal Console (if using Drupal 8+)
  - Drupal 6.x, 7.x, or 8.x.x (configurable)
  - Optional (installed by default):
    - Varnish 4.x
    - Apache Solr 4.10.x (configurable)
    - Memcached
    - XHProf, for profiling your code
    - XDebug, for debugging your code
    - Adminer, for accessing databases directly
    - Pimp my Log, for easy viewing of log files
    - MailHog, for catching and debugging email

It should take 5-10 minutes to build or rebuild the VM from scratch on a decent broadband connection.

## Quick Start Guide

### 1 - Install dependencies (VirtualBox, Vagrant, Ansible)

  1. Download and install [VirtualBox](https://www.virtualbox.org/wiki/Linux_Downloads) for your OS
  2. Download and install [Vagrant](http://www.vagrantup.com/downloads.html).
  3. Install [Ansible](http://docs.ansible.com/intro_installation.html).
    quick install on ubuntu:
    - $ sudo apt-get install software-properties-common
    - $ sudo apt-add-repository ppa:ansible/ansible
    - $ sudo apt-get update
    - $ sudo apt-get install ansible
  4. If NFS is not already installed on your host, you will need to install it to use the default NFS synced folder configuration:
    - $ sudo apt-get install nfs-kernel-server
  5. Install a Vagrant plugin "vagrant-hostsupdater" to automatically add and remove the entry from your hosts file:
    - $ vagrant plugin install vagrant-hostsupdater


Note on versions: *Please make sure you're running the latest stable version of Vagrant, VirtualBox, and Ansible, as the current version of Drupal VM is tested with the latest releases. As of June 2015: Vagrant 1.7.2, VirtualBox 4.3.26, and Ansible 1.9.2.*


### 2 - Build the Virtual Machine

  1. Download this project and put it wherever you want.
  2. Change file config.yml if you need to.
  4. Open Terminal, cd to this directory (containing the `Vagrantfile` and this README file).
  5. Install Ansible Galaxy roles required for this VM:
    - $ sudo ansible-galaxy install -r provisioning/requirements.txt --force
  6. Now you can run vagrant:
    - $ vagrant up

Note: *If there are any errors during the course of running `vagrant up`, and it drops you back to your command prompt, just run `vagrant provision` to continue building the VM from where you left off.

  7. Open your browser and access http://local.dev (or another adress if you modify it in config.yml).

## Extra software/utilities

By default, this VM includes the extras listed in the `config.yml` option `installed_extras`:

    installed_extras:
      - adminer
      - mailhog
      - memcached
      - solr
      - varnish
      - xdebug
      - xhprof

MailHog - is an email testing tool for developers. MailHog Web UI - http://local.dev:8025

Xdebug - PHP extension for powerful debugging. It supports stack and function traces, profiling information and memory allocation and script execution analysis. [Instructions for setting up](https://docs.google.com/document/d/1Mmq-qemR-yWWdCrc6ON3m084o-nCMOoKDxazzOBFmJw/edit)

If you don't want or need one or more of these extras, just delete them or comment them from the list. This is helpful if you want to reduce PHP memory usage or otherwise conserve system resources.


## Other Notes
  - To shut down the virtual machine, enter in the Terminal in the same folder that has the `Vagrantfile`:
    - $ vagrant halt
  - To destroy it completely (if you want to save a little disk space, or want to rebuild it from scratch with `vagrant up` again), type:
    - $ vagrant destroy
  - More details read here: http://docs.vagrantup.com/v2/getting-started/teardown.html