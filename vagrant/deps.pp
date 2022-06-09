# Apache Drupal Config: https://www.drupal.org/node/2461583
class { '::php':
  composer   => true,
  settings   => {
    'PHP/memory_limit' => '512M'
  },

  extensions => {
    opcache   => {},
    pdo       => {},
    xml       => {
      # settings => {
      #   xmlwriter => {},
      #   xmlreader => {},
      #   xsl       => {},
      # }
    },
    calendar  => {},
    ctype     => {},
    dom       => {},
    exif      => {},
    ffi       => {},
    fileinfo  => {},
    ftp       => {},
    gettext   => {},
    # inconv    => {},
    json      => {},
    phar      => {},
    posix     => {},
    readline  => {},
    shmop     => {},
    # simplexmp => {},
    sockets   => {},
    sysvmsg   => {},
    sysvshm   => {},
    tokenizer => {},
    gd        => {},
    curl      => {},
    mbstring  => {},
    mysql     => {},
  }
}

$deps = [ 'unzip', 'libapache2-mpm-itk', 'libapache2-mod-php7.4']

package { $deps:
  ensure => 'installed'
}

class { 'mysql::server':
  package_name            => 'mariadb-server',
  root_password           => 'vagrantroot',
  remove_default_accounts => true,
  restart                 => true,
  override_options        => {
    mysqld      => {
      'log-error' => '/var/log/mysql/mariadb.log',
      'pid-file'  => '/var/run/mysqld/mysqld.pid',
    },
    mysqld_safe => {
      'log-error' => '/var/log/mysql/mariadb.log',
    },
  }
}

class { 'mysql::client':
  package_name    => 'mariadb-client',
  bindings_enable => true,
}

::mysql::db { 'drupal':
  user     => 'vagrant',
  password => 'vagrant',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE', 'CREATE', 'DROP', 'INSERT', 'DELETE'],
}


class { '::apache':
  purge_configs => true,
  default_vhost => false,
  mpm_module    => 'prefork',
} -> exec { '/usr/sbin/a2enmod mpm_itk && /usr/sbin/a2enmod php7.4':
  require => [Package['libapache2-mpm-itk'], Package['libapache2-mod-php7.4']]
}

include ::apache::mod::rewrite

apache::vhost { $facts['fqdn']:
  servername  => $facts['fqdn'],
  port        => '80',
  docroot     => '/var/www/html/drupal',
  directories => [
    {
      'path'           => '/',
      'allow'          => 'from all',
      'allow_override' => 'All',
    },
  ],
}

file { '/var/www/html/drupal':
  ensure  => 'link',
  target  => '/home/vagrant/example.localhost/web',
  require => [
    Apache::Vhost[$facts['fqdn']],
  ]
}

# Drupal Install: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/set-up-a-local-development-drupal-0-4
