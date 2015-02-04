class registry::nginx {
  if ! file_exists('/registry/ssl/certs/registry.crt') {
    require registry::nginx::ssl
  }

  file { '/etc/nginx/conf.d/default.conf':
    ensure => present,
    content => template('registry/default.conf.erb'),
    mode => 644
  }

  file { '/etc/nginx/conf.d/default-ssl.conf':
    ensure => present,
    content => template('registry/default-ssl.conf.erb'),
    mode => 644
  }

  if ! file_exists('/registry/.htpasswd') {
    exec { "htpasswd -b -c /registry/.htpasswd '$username' '$password'":
      timeout => 0,
      path => ['/usr/bin']
    }
  }
}
