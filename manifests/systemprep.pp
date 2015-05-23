class dopassenger::systemprep (

  # class arguments
  # ---------------
  # setup defaults

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
          # before => [Exec['dopassenger-apache2-symlink-latest-gems']],
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
      anchor { 'dopassenger-systemprep-package-ready' :
        require => [Package['gcc-c++'], Package['ruby-devel'], Package['libcurl-devel'], Package['httpd-devel'], Package['apr-devel'], Package['apr-util-devel'], Package['openssl-devel'], Package['zlib-devel']],
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
          # before => [Exec['dopassenger-apache2-symlink-latest-gems']],
        }
      }
      # install passenger gem
      anchor { 'dopassenger-systemprep-package-ready' :
        require => [Package['libcurl4-openssl-dev'], Package['apache2-threaded-dev'], Package['libapr1-dev'], Package['libaprutil1-dev'], Package['ruby-dev']],
      }
    }
  }

}
