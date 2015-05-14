define opendkim::domain (
    $domain       = $name,
    $selector     = $hostname,
    $pathConf     = '/etc/opendkim',
    $pathKeys     = '/etc/opendkim/keys',
    $owner        = 'opendkim',
    $group        = 'opendkim',
    $packageName  = 'opendkim',
    $serviceName  = 'opendkim',
    $KeyTable     = 'KeyTable',
    $SigningTable = 'SigningTable',
) {
    # $pathConf and $pathKeys must be without leading '/'.
    # For example, '/etc/opendkim/keys'

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

    # Create directory for domain
    file { "${pathKeys}/${domain}":
        ensure  => "directory",
        owner   => $owner,
        group   => $group,
        mode    => 755,
        notify  => Service[$serviceName],
        require => Package[$packageName],
    }

    # Generate dkim-keys
    exec { "/usr/sbin/opendkim-genkey -D ${pathKeys}/${domain}/ -d ${domain} -s ${selector}":
        unless  => "/usr/bin/test -f ${pathKeys}/${domain}/${selector}.private && /usr/bin/test -f ${pathKeys}/${domain}/${selector}.txt",
        user    => $owner,
        notify  => Service[$serviceName],
        require => [ Package[$packageName], File["${pathKeys}/${domain}"], ],
    }

    # Add line into KeyTable
    file_line { "${pathConf}/${KeyTable}_${domain}":
        path    => "${pathConf}/${KeyTable}",
        line    => "${selector}._domainkey.${domain} ${domain}:${selector}:${pathKeys}/${domain}/${selector}.private",
        notify  => Service[$serviceName],
        require => Package[$packageName],
    }

    # Add line into SigningTable
    file_line { "${pathConf}/${SigningTable}_${domain}":
        path    => "${pathConf}/${SigningTable}",
        line    => "*@${domain} ${selector}._domainkey.${domain}",
        notify  => Service[$serviceName],
        require => Package[$packageName],
    }
}
