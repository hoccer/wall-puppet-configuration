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

file_line { 'urandom fix':
  path => '/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/java.security',
  line => 'securerandom.source=file:/dev/./urandom',
  match => '^securerandom.source=.*',
  require => Package['java'],
}

package { 'curl':
  ensure => 'installed'
}

package { 'pwgen':
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

class { 'nginx':
  confd_purge => true,
  proxy_http_version => '1.1',
}

nginx::resource::vhost { 'wall.talk.hoccer.de':
  ensure => present,
  www_root => '/var/www',
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

file { '/var/www/decrypted_attachments':
  ensure => link,
  target => '/home/talk/webclient-backend/shared/decrypted_attachments',
  owner => 'www-data',
  group => 'www-data',
}

nginx::resource::location { '= /':
  ensure => present,
  vhost => 'wall.talk.hoccer.de',
  location_custom_cfg => {
    return => '301 /viewer/',
  },
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
