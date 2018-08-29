class { 'quartermaster':
    dban_enable          => true,
    matchbox_enable      => true,
    puppetmaster         => "puppetmaster.${domain}",
  }
  quartermaster::pxelinux{'ubuntu-16.04-amd64':}
  quartermaster::pxelinux{'ubuntu-18.04-amd64':}
  # Centos
  quartermaster::pxelinux{'centos-6.9-x86_64':}
  quartermaster::pxelinux{'centos-7.4.1708-x86_64':}
