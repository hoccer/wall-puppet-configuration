hoccer-receiver-puppet-configuration
===========================

## Requirements

* Ubuntu 14.04 LTS minimal install

## Production Setup

The following script installs all packages, dependencies and modules required (including this repository) and applys the puppet configuration. Make sure that an appropriate SSL certificate is present to clone the required repositories.

```bash
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

## Development Setup

The provisioning can be tested on a local VM using Vagrant as follows:

```bash
# create VM
vagrant up

# log into VM
vagrant ssh

# go to shared folder on the VM
cd /vagrant

# install puppet modules
librarian-puppet install

# apply puppet configuration
sudo puppet apply init.pp --no-report --modulepath modules --verbose
```
