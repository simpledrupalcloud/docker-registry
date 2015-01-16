class registry::nginx::ssl {
  file { '/root/opensslCA.cnf':
    ensure => present,
    content => template('registry/opensslCA.cnf.erb')
  }

  exec { 'openssl genrsa -out /registry/ssl/private/registryCA.key 4096':
    timeout => 0,
    path => ['/usr/bin'],
    require => File['/root/opensslCA.cnf']
  }

  exec { "openssl req -sha256 -x509 -new -days 3650 -extensions v3_ca -key /registry/ssl/private/registryCA.key -config /root/opensslCA.cnf -out /registry/ssl/certs/registryCA.crt":
    timeout => 0,
    path => ['/usr/bin'],
    require => Exec['openssl genrsa -out /registry/ssl/private/registryCA.key 4096']
  }

  exec { 'openssl genrsa -out /registry/ssl/private/registry.key 4096':
    timeout => 0,
    path => ['/usr/bin'],
    require => Exec["openssl req -sha256 -x509 -new -days 3650 -extensions v3_ca -key /registry/ssl/private/registryCA.key -config /root/opensslCA.cnf -out /registry/ssl/certs/registryCA.crt"]
  }

  file { '/root/openssl.cnf':
    ensure => present,
    content => template('registry/openssl.cnf.erb'),
    require => Exec['openssl genrsa -out /registry/ssl/private/registry.key 4096']
  }

  exec { "openssl req -sha256 -new -key /registry/ssl/private/registry.key -config /root/openssl.cnf -out /registry/ssl/certs/registry.csr":
    timeout => 0,
    path => ['/usr/bin'],
    require => File['/root/openssl.cnf']
  }

  exec { "openssl x509 -req -sha256 -in /registry/ssl/certs/registry.csr -CA /registry/ssl/certs/registryCA.crt -CAkey /registry/ssl/private/registryCA.key -CAcreateserial -config /root/opensslCA.cnf -out /registry/ssl/certs/registry.crt":
    timeout => 0,
    path => ['/usr/bin'],
    require => Exec["openssl req -sha256 -new -key /registry/ssl/private/registry.key -config /root/openssl.cnf -out /registry/ssl/certs/registry.csr"]
  }
}
