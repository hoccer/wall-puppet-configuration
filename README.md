hoccer-receiver-puppet-configuration
===========================

## Requirements

* Ubuntu 14.04 LTS minimal install

## Installation

The following script installs all packages, dependencies and modules required (including this repository) and applys the puppet configuration. Make sure that an appropriate ssl certificate is present to clone the required repositories.

```
#!/bin/bash

# install git 
sudo apt-get -y install git-core

# install puppet
sudo apt-get -y install puppet

# install librarian-puppet
sudo apt-get -y install librarian-puppet

# add github to known hosts (for full automation only)
sudo mkdir /root/.ssh
sudo touch /root/.ssh/known_hosts
ssh-keyscan -H "github.com" >> /root/.ssh/known_hosts
sudo chmod 600 /root/.ssh/known_hosts

# checkout puppet provisioning repository and apply
git clone git@github.com:hoccer/hoccer-receiver-puppet-configuration.git
cd hoccer-receiver-puppet-configuration

# install puppet modules
librarian-puppet install

# apply puppet configuration
puppet apply init.pp --no-report --modulepath modules --verbose

```

## Vagrant

An appropriate vagrant file to build a box using the installation script above could look like this (where 'provision.sh' is the name of the script above).

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "virtualbox" do |v|
    v.name = "hoccer_receiver"
  end
  
  config.vm.box = "berendt/ubuntu-14.04-amd64"

  # ssh agent support
  config.ssh.private_key_path = [ '~/.vagrant.d/insecure_private_key', '~/.ssh/id_rsa' ]
  config.ssh.forward_agent = true

  # Enable shell provisioning
  config.vm.provision :shell, :path => "provision.sh"

end
```
