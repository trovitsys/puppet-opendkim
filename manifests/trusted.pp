define opendkim::trusted (
    $host         = $name,
    $pathConf     = '/etc/opendkim',
    $TrustedHosts = 'TrustedHosts',
    $packageName  = 'opendkim',
    $serviceName  = 'opendkim',
) {
    # Add line into KeyTable
    file_line { "${pathConf}/${TrustedHosts}_${host}":
        path    => "${pathConf}/${TrustedHosts}",
        line    => $host,
        notify  => Service[$serviceName],
        require => Package[$packageName],
    }
}
