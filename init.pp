define line($file, $line, $ensure = 'present') {
    case $ensure {
        default : { err ( "unknown ensure value ${ensure}" ) }
        present: {
            exec { "/bin/echo '${line}' >> '${file}'":
                unless => "/bin/grep -qFx '${line}' '${file}'"
            }
        }
        absent: {
            exec { "/bin/grep -vFx '${line}' '${file}' | /usr/bin/tee '${file}' > /dev/null 2>&1":
              onlyif => "/bin/grep -qFx '${line}' '${file}'"
            }

            # Use this resource instead if your platform's grep doesn't support -vFx;
            # note that this command has been known to have problems with lines containing quotes.
            # exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
            #     onlyif => "/bin/grep -qFx '${line}' '${file}'"
            # }
        }
    }
}

include backuppc-client
include deployment-user
include hoccer-certs
include nrpe
include java
include rvm

file_line { 'urandom fix':
  path => '/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/java.security',
  line => 'securerandom.source=file:/dev/./urandom',
  match => '^securerandom.source=.*',
  require => Package['java'],
}

package { 'pwgen':
  ensure => 'installed'
}

package { 'libmagickwand-dev':
  ensure => 'installed'
}

package { 'unzip':
  ensure => 'installed'
}

user { 'talk':
  ensure => present,
  groups => [],
  managehome => true,
  shell => '/bin/bash'
}

rvm::system_user {
  'deployment':
    require => User['deployment'];
  'talk':
    require => User['talk'];
}

rvm_system_ruby { 'ruby-2.1.1':
  ensure => 'present',
}

rvm_gemset { 'ruby-2.1.1@exif-orientation-service':
  ensure  => present,
  require => Rvm_system_ruby['ruby-2.1.1'];
}

class { 'nginx':
  confd_purge => true,
  proxy_http_version => '1.1',
  proxy_cache_path => '/var/cache/nginx/decrypted_attachments',
  proxy_cache_keys_zone => 'decrypted_attachments:10m',
}

nginx::resource::vhost { 'wall.talk.hoccer.de':
  ensure => present,
  www_root => '/var/www',
}

file { '/var/cache/nginx/decrypted_attachments':
  ensure => directory,
  owner => 'www-data',
  group => 'root',
  require => Class['nginx'],
}

file { '/var/www':
  ensure => directory,
  owner => 'www-data',
  group => 'www-data',
}

file { '/var/www/viewer':
  ensure => link,
  target => '/home/talk/wall-image-viewer/current',
  owner => 'www-data',
  group => 'www-data',
}

file { '/var/www/reviewer':
  ensure => link,
  target => '/home/talk/wall-image-reviewer/current',
  owner => 'www-data',
  group => 'www-data',
}

file { ['/home/talk/exif-orientation-service',
        '/home/talk/exif-orientation-service/shared',
        '/home/talk/exif-orientation-service/shared/images']:
  ensure => directory,
  owner => 'deployment',
  group => 'deployment',
  require => [
    User['talk'],
    User['deployment'],
  ],
}

file { '/home/talk/exif-orientation-service/shared/images/decrypted_attachments':
  ensure => link,
  target => '/home/talk/webclient-backend/shared/decrypted_attachments',
  owner => 'deployment',
  group => 'deployment',
  require => User['talk'],
}

nginx::resource::location { '= /':
  ensure => present,
  vhost => 'wall.talk.hoccer.de',
  location_custom_cfg => {
    return => '301 /viewer/',
  },
}

nginx::resource::location { '/decrypted_attachments':
  ensure => present,
  vhost => 'wall.talk.hoccer.de',
  proxy => 'http://localhost:4567',
  proxy_cache => 'decrypted_attachments',
  proxy_cache_valid => '1y',
}

nginx::resource::location { '/api':
  ensure => present,
  vhost => 'wall.talk.hoccer.de',
  proxy => 'http://localhost:5000',
}

nginx::resource::map { 'connection_upgrade':
  ensure    => present,
  default   => 'upgrade',
  string    => '$http_upgrade',
  mappings  => {
    '""' => 'close',
  }
}

nginx::resource::location { '/updates':
  ensure => present,
  vhost => 'wall.talk.hoccer.de',
  proxy => 'http://localhost:5000',
  proxy_set_header => [
    'Upgrade $http_upgrade',
    'Connection $connection_upgrade',
  ],
}
