class dopassenger (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $group = 'www-data',
  $passenger_gems_path = $dopassenger::params::passenger_gems_path,
  $tmp_dir = '/tmp/passenger',

  # end of class arguments
  # ----------------------
  # begin class

) inherits dopassenger::params {

  # install passenger deps
  case $operatingsystem {
    centos, redhat: {
      if ! defined(Package['gcc-c++']) {
        package { 'gcc-c++' : 
          ensure => 'installed',
        }
      }
      if ! defined(Package['ruby-devel']) {
        package { 'ruby-devel' :
          ensure => 'installed',
        }
      }
      if ! defined(Package['libcurl-devel']) {
        package { 'libcurl-devel' :
          ensure => 'installed',
        }
      }
      if ! defined(Package['httpd-devel']) {
        package { 'httpd-devel' :
          ensure => 'installed',
        }
      }
      if ! defined(Package['apr-devel']) {
        package { 'apr-devel' :
          ensure => 'installed',
        }
      }
      if ! defined(Package['apr-util-devel']) {
        package { 'apr-util-devel' :
          ensure => 'installed',
        }
      }
      if ! defined(Package['openssl-devel']) {
        package { 'openssl-devel' :
          ensure => 'installed',
        }
      }
      if ! defined(Package['zlib-devel']) {
        package { 'zlib-devel' :
          ensure => 'installed',
        }
      }
      # install passenger gem
      if ! defined(Package['passenger']) {
        package { 'passenger' :
          ensure => 'installed',
          provider => 'gem',
          require => [Package['gcc-c++'], Package['ruby-devel'], Package['libcurl-devel'], Package['httpd-devel'], Package['apr-devel'], Package['apr-util-devel'], Package['openssl-devel'], Package['zlib-devel'],],
        }
      }
      Exec <| title == 'dopassenger-apache2-install-module' |> {
        # require Passenger and also any packages potentially already defined elsewhere
        require => [Package['passenger'], Package['gcc-c++'], Package['ruby-devel'], Package['libcurl-devel'], Package['httpd-devel'], Package['apr-devel'], Package['apr-util-devel'], Package['openssl-devel'], Package['zlib-devel']],
      }
    }
    ubuntu, debian: {
      if ! defined(Package['libcurl4-openssl-dev']) {
        package { 'libcurl4-openssl-dev' :
          ensure => 'installed',
        }
      }
      if ! defined(Package['apache2-threaded-dev']) {
        package { 'apache2-threaded-dev' :
          ensure => 'installed',
        }
      }
      if ! defined(Package['libapr1-dev']) {
        package { 'libapr1-dev' :
          ensure => 'installed',
        }
      }
      if ! defined(Package['libaprutil1-dev']) {
        package { 'libaprutil1-dev' :
          ensure => 'installed',
        }
      }
      if ! defined(Package['ruby-dev']) {
        package { 'ruby-dev' :
          ensure => 'installed',
        }
      }
      # install passenger gem
      if ! defined(Package['passenger']) {
        package { 'passenger' :
          ensure => 'installed',
          provider => 'gem',
          require => [Package['libcurl4-openssl-dev'], Package['apache2-threaded-dev'], Package['libapr1-dev'], Package['libaprutil1-dev'], Package['ruby-dev']],
        }
      }
      Exec <| title == 'dopassenger-apache2-install-module' |> {
        # require Passenger and also any packages potentially already defined elsewhere
        require => [Package['passenger'], Package['libcurl4-openssl-dev'], Package['apache2-threaded-dev'], Package['libapr1-dev'], Package['libaprutil1-dev'], Package['ruby-dev']],
      }
    }
  }

  # install apache2 module
  exec { 'dopassenger-apache2-install-module' :
    path => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin',
    command => 'passenger-install-apache2-module --auto',
    # it's actually the symlink that creates this, but it's a useful proxy
    creates => "${passenger_gems_path}/latest-passenger",
  }->

  # create symlink 'latest-gems' for vhost configs
  exec { 'dopassenger-apache2-symlink-latest-gems' :
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "ln -fs ${passenger_gems_path} /usr/lib/ruby/latest-gems",
  }->

  # create symlink 'latest-passenger' for vhost configs
  # together these two symlinks give us a cross-platform /usr/lib/ruby/latest-gems/latest-passenger/mod_passenger.so
  exec { 'dopassenger-apache2-symlink-latest-passenger' :
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "find ${passenger_gems_path}/ -name 'passenger-*' -exec ln -fs {} ${passenger_gems_path}/latest-passenger \;",
  }

  # selinux
  if (str2bool($::selinux)) {
    # allow access to gems
    docommon::setcontext { 'dopassenger-selinux-gem-context' :
      filename => "${passenger_gems_path}/latest-passenger",
      context => 'httpd_sys_content_t',
      require => Exec['dopassenger-apache2-symlink-latest-passenger'],
    }
  }
  # create a writeable temporary directory
  docommon::stickydir { 'dopassenger-tmpdir' :
    filename => $tmp_dir,
    user => $::apache::params::user,
    group => $group,
    mode => 2660,
    dirmode => 2770,
    groupfacl => 'rwx',
    recurse => true,
    # httpd_tmpfs_t allows some special privileges, like ability to create socket files
    context => 'httpd_tmpfs_t',
  }

}
