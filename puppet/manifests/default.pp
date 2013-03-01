$packages = [
    "vim",
    "sqlite3",
    "curl",
    "nginx",
    "php5-fpm",
    "php5-sqlite",
    "php-apc",
    "git",
    "php5-cli",
    "php5-xdebug",
	"mysql-server",
	"mysql-client",
	"php5-mysql",
	"postgresql",
	"php5-pgsql",
	"php5-curl",
]

$services = ["nginx", "php5-fpm"]

group { "puppet":
    ensure => "present",
}

exec { "apt-get update":
    command => "/usr/bin/apt-get update",
}


package { $packages: 
    ensure  => installed,
    require => Exec["apt-get update"],
    notify  => Service[$services],
}

service { $services:
    ensure => running,
}

file {
    "/etc/nginx/sites-enabled/default":
        ensure    => absent,
        subscribe => Package["nginx"],
    ;

    "/etc/nginx/sites-available/site":
        source  => "/vagrant/puppet/files/etc/nginx/sites-available/site",
        notify  => [
            File["/etc/nginx/sites-enabled/site"],
            Service["nginx"]
        ],
        require => Package["nginx"],
    ;

    "/etc/nginx/sites-enabled/site":
        ensure => link,
        target => "/etc/nginx/sites-available/site",
        notify => Service["nginx"],
    ;

    "/etc/php5/conf.d/timezone.ini":
        source  => "/vagrant/puppet/files/etc/php5/conf.d/timezone.ini",
        notify  => Service["php5-fpm"],
        require => Package["php5-fpm"],
    ;

    "/etc/php5/fpm/pool.d/www.conf":
      source  => "/vagrant/puppet/files/etc/php5/fpm/pool.d/www.conf",
      notify  => Service["php5-fpm"],
      require => Package["php5-fpm"],
    ;

    "/etc/localtime":
        source => "/usr/share/zoneinfo/America/Chicago",
    ;
}

exec { "update-alternatives":
    command   => "/usr/sbin/update-alternatives --set editor /usr/bin/vim.basic",
    subscribe => Package["vim"],
}
