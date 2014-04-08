class dopassenger::params {

  case $operatingsystem {
    centos, redhat, fedora: {
      $passenger_gems_path = '/usr/lib/ruby/gems/1.8/gems'
    }
    ubuntu, debian: {
      $passenger_gems_path = '/var/lib/gems/1.8/gems'
    }
  }

}

