define opendkim::trusted (
    $host          = $name,
    $trusted_hosts = 'TrustedHosts',
    
) {

    # this is a ugly hack. Need to fix with a complete
    # module refactor about how it manages trusted hosts and
    # any other dataset
    $th_dir = { "${opendkim::pathconf}/${trusted_hosts}" => {
                  ensure  => file,
                  replace => false,
                  owner   => 'root',
                  group   => 'root',
                  mode    => '0640',
                  require => Package[$opendkim::package_name],
      },
    }

    ensure_resource($th_dir)

    # Add line into KeyTable
    file_line { "${opendkim::pathconf}/${trusted_hosts}_${host}":
        path    => "${opendkim::pathconf}/${trusted_hosts}",
        line    => $host,
        notify  => Service[$opendkim::service_name],
        require => File["${opendkim::pathconf}/${trusted_hosts}"],
    }
}
