  class{'quartermaster':
    dban_enable          => true,
    matchbox_enable      => true,
    puppetmaster         => "puppetmaster.${domain}",
    preferred_nameserver => $::dhcp,
  }
  # Ubuntu
  quartermaster::pxelinux{'ubuntu-16.04-amd64':}
  quartermaster::pxelinux{'ubuntu-18.04-amd64':}
  # Centos
  quartermaster::pxelinux{'centos-7.4.1708-x86_64':}
  # CoreOS
  quartermaster::pxelinux{'coreos-stable-amd64':}
  # Oracle Linux
  quartermaster::pxelinux{'oraclelinux-7.5-x86_64':}
  # Debian
  quartermaster::pxelinux{'debian-9-amd64':}
  # RancherOS
  quartermaster::pxelinux{'rancheros-1.3.0-amd64':}
