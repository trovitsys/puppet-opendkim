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
    $AutoRestart        = 'Yes',
    $AutoRestartRate    = '10/1h',
    $LogWhy             = 'Yes',
    $Syslog             = 'Yes',
    $SyslogSuccess      = 'Yes',
    $Mode               = 's',
    $Canonicalization   = 'relaxed/simple',
    $ExternalIgnoreList = 'refile:/etc/opendkim/TrustedHosts',
    $InternalHosts      = 'refile:/etc/opendkim/TrustedHosts',
    $KeyTable           = 'refile:/etc/opendkim/KeyTable',
    $SigningTable       = 'refile:/etc/opendkim/SigningTable',
    $SignatureAlgorithm = 'rsa-sha256',
    $Socket             = 'inet:8891@localhost',
    $PidFile            = '/var/run/opendkim/opendkim.pid',
    $UMask              = '022',
    $UserID             = 'opendkim:opendkim',
    $TemporaryDirectory = '/var/tmp',
    $packageName        = 'opendkim',
    $serviceName        = 'opendkim',
) {

    package { $packageName:
        ensure => present,
    }

    service { $serviceName:
        ensure => running,
        enable => true,
        require => Package[$packageName],
    }

    file {'/etc/opendkim.conf':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('opendkim/opendkim.conf'),
        notify  => Service[$serviceName],
        require => Package[$packageName],
    }
}

