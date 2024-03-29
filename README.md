Hoccer XO Wall Provisioning
===========================

Provides a puppet manifest with basic modules for a Hoccer XO Wall.

Following the steps below, most packages, dependencies and modules required (including this repository) are downloaded and applied using _puppet apply_.

Make sure that an appropriate SSL certificate is present to clone the required repositories from GitHub. This can be achieved by installing one manually or by using ssh [agent forwarding](https://help.github.com/articles/using-ssh-agent-forwarding). For the latter you might need to make your key available via `ssh-add -K` first.

**NOTE:** After provisioning, the [Bouncycastle Security Provider](https://github.com/hoccer/hoccer-talk-spike/wiki/Extend-Java-Security#install-bouncycastle-as-security-provider-in-the-jre) must be **installed manually** to `/usr/lib/jvm/java-7-openjdk-amd64`.

## Requirements

* Ubuntu 14.04 LTS minimal install
* Open Port: 80

## Production Setup

```bash
# ensure that all package information are up-to-date
sudo apt-get update

# install git, puppet, ruby-dev and make if not present
sudo apt-get -y install git-core puppet ruby-dev make

# install librarian-puppet gem (you might need to reopen your terminal afterwards)
sudo gem install librarian-puppet --version=1.1.2

# checkout puppet provisioning repository and apply
git clone git@github.com:hoccer/wall-puppet-configuration.git
cd wall-puppet-configuration

# install puppet modules
librarian-puppet install --verbose

# apply puppet configuration
sudo -E puppet apply init.pp --no-report --modulepath modules --verbose
```
## Development Setup

To be able to ssh into the vagrant box with the deployment user on your local machine, you need to make sure that your public ssh key is also provisioned as in /modules/deployment-user/manifests/install.pp

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
sudo -E puppet apply init.pp --no-report --modulepath modules --verbose
```
