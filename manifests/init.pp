# == Class: opendkim
#
# === Examples
#
#  class { 'opendkim':}
#
# === Authors
#
# Vladimir Bykanov <vladimir@bykanov.ru>
#
# === Copyright
#
# Copyright 2015 Vladimir Bykanov
#
class opendkim (
    $autorestart          = 'Yes',
    $autorestart_rate     = '10/1h',
    $log_why              = 'Yes',
    $syslog               = 'Yes',
    $syslog_success       = 'Yes',
    $mode                 = 's',
    $canonicalization     = 'relaxed/simple',
    $external_ignore_list = 'refile:/etc/opendkim/TrustedHosts',
    $internal_hosts       = 'refile:/etc/opendkim/TrustedHosts',
    $keytable             = 'refile:/etc/opendkim/KeyTable',
    $signing_table        = 'refile:/etc/opendkim/SigningTable',
    $signature_algorithm  = 'rsa-sha256',
    $socket               = 'inet:8891@localhost',
    $pidfile              = '/var/run/opendkim/opendkim.pid',
    $umask                = '022',
    $userid               = 'opendkim:opendkim',
    $temporary_directory  = '/var/tmp',
    $package_name         = 'opendkim',
    $service_name         = 'opendkim',
    $pathconf             = '/etc/opendkim',
    $owner                = 'opendkim',
    $group                = 'opendkim',
) {

    package { $package_name:
        ensure => present,
    }

    service { $service_name:
        ensure  => running,
        enable  => true,
        require => Package[$package_name],
    }

    case $::operatingsystem {
      'Debian': {
            # Debian doesn't ship this directory in its package
            file { $pathconf:
              ensure => directory,
              owner  => 'root',
              group  => 'root',
              mode   => '0755',
              before => Package[$package_name],
            }
           # this package provides programs used by this module
           package { 'opendkim-tools': }
      }
      default: {}
    }

    file {'/etc/opendkim.conf':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('opendkim/opendkim.conf'),
        notify  => Service[$service_name],
        require => Package[$package_name],
    }
}

