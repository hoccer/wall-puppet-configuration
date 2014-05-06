hoccer-receiver-puppet-configuration
===========================

## Requirements

### OS

* Ubuntu 14.04 LTS minimal install

### Packages
```
# install git 
sudo apt-get -y install git-core

# install puppet
sudo apt-get -y install puppet

# install librarian-puppet
sudo apt-get -y install librarian-puppet
```

## Puppet Provisioning

* Prepare Puppet modules:

```
librarian-puppet install
```

* Apply Puppet configuration:
 
```
sudo puppet apply init.pp --no-report --modulepath modules --verbose
```