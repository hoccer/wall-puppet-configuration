hoccer-receiver-puppet-configuration
===========================

## Requirements

* Ubuntu 14.04 LTS minimal install
* Open Port: 80

## General Setup

```bash
# install git 
sudo apt-get -y install git-core

# install puppet
sudo apt-get -y install puppet

# install ruby-dev
sudo apt-get install ruby-dev

# install make if not present
sudo apt-get install make

# install librarian-puppet gem instead (you might need to reopen your terminal afterwards)
sudo gem install librarian-puppet
```

## Production Setup

The following steps install all packages, dependencies and modules required (including this repository) and apply the puppet configuration. Make sure that an appropriate SSL certificate is present to clone the required repositories.

```bash
# checkout puppet provisioning repository and apply
git clone git@github.com:hoccer/hoccer-receiver-puppet-configuration.git
cd hoccer-receiver-puppet-configuration

# install puppet modules
librarian-puppet install --verbose

# apply puppet configuration
sudo puppet apply init.pp --no-report --modulepath modules --verbose

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
librarian-puppet install --verbose

# apply puppet configuration
sudo puppet apply init.pp --no-report --modulepath modules --verbose
```
