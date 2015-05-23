class dopassenger (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $group = 'www-data',

  $ruby_version = 'ruby-1.9',
  $passenger_version = '4.0.59',

  $rvm_path = '/usr/local/rvm',
  $tmp_dir = '/var/tmp/passenger',

  # end of class arguments
  # ----------------------
  # begin class

) inherits dopassenger::params {

  # install passenger deps
  class { 'dopassenger::systemprep' : }

  class { 'rvm' :
    require => [Class['dopassenger::systemprep']],
  }
  rvm_system_ruby { $ruby_version :
    ensure      => 'present',
    default_use => false,
  }
  rvm_system_ruby { 'ruby-2.2' :
    ensure      => 'present',
    default_use => false,
  }
  rvm_gem { 'rails':
    ensure       => 'present',
    ruby_version => $ruby_version,
    require      => Rvm_system_ruby[$ruby_version],
  }
  class { 'rvm::passenger::gem':
    ruby_version => $ruby_version,
    version      => $passenger_version,
  }
  exec { 'passenger-install-apache2-module':
    path        => "${rvm_path}/bin:/usr/bin:/bin:/usr/sbin:/sbin:",
    command     => "rvm ${ruby_version} exec passenger-install-apache2-module -a",
    environment => [ 'HOME=/root', ],
    # @todo sensible creates so we don't install it everytime
    # creates     => $modobjectpath,
    require     => Class['rvm::passenger::gem'],
  }

  # create symlink 'ruby-master' for vhost configs
  exec { 'dopassenger-apache2-symlink-latest-gems' :
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    # find name of latest ruby that started ruby-1.9 and doesn't finish @global
    command => "find ${rvm_path}/gems/ -name '${ruby_version}.[[:digit:]]*-p[[:digit:]]*' ! -name '*\@global' -exec ln -fs {} ${rvm_path}/gems/ruby-master \;",
  }->

  # create symlink 'latest-passenger' for vhost configs
  exec { 'dopassenger-apache2-symlink-latest-passenger' :
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "find ${rvm_path}/gems/ruby-master/gems/ -name 'passenger-*' -exec ln -fs {} ${rvm_path}/gems/ruby-master/gems/passenger-master \;",
  }

  # selinux
  if (str2bool($::selinux)) {
    # allow access to gems
    docommon::setcontext { 'dopassenger-selinux-gem-context' :
      filename => "${rvm_path}/gems/ruby-master/gems/passenger-master",
      context => 'httpd_sys_content_t',
      require => Exec['dopassenger-apache2-symlink-latest-passenger'],
    }
  }
  # create a writeable temporary directory
  docommon::stickydir { 'dopassenger-tmpdir' :
    filename => $tmp_dir,
    user => $::apache::params::user,
    group => $group,
    mode => 660,
    dirmode => 2770,
    groupfacl => 'rwx',
    recurse => true,
    # httpd_tmpfs_t allows some special privileges, like ability to create socket files
    context => 'httpd_tmpfs_t',
  }

}
