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

user { 'talk':
  ensure => present,
  groups => [],
  managehome => true,
  shell => '/bin/bash'
}

class { 'nginx':
  confd_purge => true
}
