define opendkim::domain (
    $domain        = $name,
    $selector      = $hostname,
    $pathkeys      = '/etc/opendkim/keys',
    $keytable      = 'KeyTable',
    $signing_table = 'SigningTable',
    $private_key_content = undef,
) {
    # $pathConf and $pathKeys must be without trailing '/'.
    # For example, '/etc/opendkim/keys'

    Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

    # Create directory for domain
    $path_params = {
        ensure  => directory,
        owner   => $opendkim::owner,
        group   => $opendkim::group,
        mode    => '0755',
        notify  => Service[$opendkim::service_name],
        require => Package[$opendkim::package_name],
    }

    ensure_resource('file', [$pathkeys, "${pathkeys}/${domain}"], $path_params)

    if (defined($private_key_content)) {
        file { "${pathkeys}/${domain}/${selector}.private":
            ensure  => file,
            owner   => $user,
            group   => 'root',
            mode    => '0600',
            content => $private_key_content;
        }
    } else {
        # Generate dkim-keys
        exec { "opendkim-genkey -D ${pathkeys}/${domain}/ -d ${domain} -s ${selector}":
            unless  => "/usr/bin/test -f ${pathkeys}/${domain}/${selector}.private && /usr/bin/test -f ${pathkeys}/${domain}/${selector}.txt",
            user    => $opendkim::owner,
            notify  => Service[$opendkim::service_name],
            require => [ Package[$opendkim::package_name], File["${pathkeys}/${domain}"], ],
        }
    }

    # this is a ugly hack. Need to fix with a complete
    # module refactor about how it manages trusted hosts and
    # any other dataset
    $kt_dir = { 'ensure'  => 'file',
                'replace' => 'false',
                'owner'   => 'root',
                'group'   => 'root',
                'mode'    => '0640',
                'require' => "Package[$opendkim::package_name]"
    }

    ensure_resource( 'file', "${opendkim::pathconf}/${keytable}", $kt_dir)

    $st_dir = { 'ensure'  => 'file',
                'replace' => 'false',
                'owner'   => 'root',
                'group'   => 'root',
                'mode'    => '0640',
                'require' => "Package[$opendkim::package_name]"
    }

    ensure_resource( 'file', "${opendkim::pathconf}/${signing_table}", $st_dir)


    # Add line into KeyTable
    file_line { "${opendkim::pathconf}/${keytable}_${domain}":
        path    => "${opendkim::pathconf}/${keytable}",
        line    => "${selector}._domainkey.${domain} ${domain}:${selector}:${pathkeys}/${domain}/${selector}.private",
        notify  => Service[$opendkim::service_name],
        require => Package[$opendkim::package_name],
    }

    # Add line into SigningTable
    file_line { "${opendkim::pathconf}/${signing_table}_${domain}":
        path    => "${opendkim::pathconf}/${signing_table}",
        line    => "*@${domain} ${selector}._domainkey.${domain}",
        notify  => Service[$opendkim::service_name],
        require => Package[$opendkim::package_name],
    }
}
