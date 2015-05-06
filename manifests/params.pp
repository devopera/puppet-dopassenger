class dopassenger::params {

  case $operatingsystem {
    centos, redhat, fedora: {
      $passenger_gems_path = '/usr/lib64/ruby/gems/1.8/gems'
      $passenger_gems_path_32 = '/usr/lib/ruby/gems/1.8/gems'
    }
    ubuntu, debian: {
      $passenger_gems_path = '/var/lib/gems/1.8/gems'
      $passenger_gems_path_32 = '/var/lib/gems/1.8/gems'
    }
  }

}

