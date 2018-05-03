class { 'quartermaster':
    dban_enable          => true,
    matchbox_enable      => true,
    puppetmaster         => "puppetmaster.${domain}",
  }
  # Fedora
  quartermaster::pxelinux{'fedora-27-x86_64':}
  # Ubuntu
  quartermaster::pxelinux{'ubuntu-16.04-amd64':}
  quartermaster::pxelinux{'ubuntu-16.04-i386':}
  quartermaster::pxelinux{'ubuntu-17.10-amd64':}
  quartermaster::pxelinux{'ubuntu-17.10-i386':}
  quartermaster::pxelinux{'ubuntu-18.04-i386':}
  quartermaster::pxelinux{'ubuntu-18.04-amd64':}
  # Centos
  quartermaster::pxelinux{'centos-6.9-x86_64':}
  quartermaster::pxelinux{'centos-7.4.1708-x86_64':}
  # CoreOS
  quartermaster::pxelinux{'coreos-stable-amd64':}
  # RancherOS
  quartermaster::pxelinux{'rancheros-1.3.0-amd64':}
