# Class: quartermaster::pxelinux
#
# This Class defines the creation of the linux pxe infrastructure
#
define quartermaster::pxelinux {
# this regex works w/ no .
#if $name =~ /([a-zA-Z0-9_]+)-([a-zA-Z0-9_]+)-([a-zA-Z0-9_]+)/ {

  Staging::File {
    # Some curl_options to add for downloading large files over questionable links
    # Use local cache   * --proxy http://${ipaddress}:3128
    # Continue Download * -C 
    # Maximum Time      * --max-time 1500 
    # Retry             * --retry 3 
    curl_option => "--proxy http://${ipaddress}:3128 --retry 3",
    #
    # Puppet waits for the Curl execution to finish
    #
    timeout     => '0',
  }

  # Define proper name formatting matching distro-release-p_arch
  if $name =~ /([a-zA-Z0-9_\.]+)-([a-zA-Z0-9_\.]+)-([a-zA-Z0-9_\.]+)/ {
    $distro  = $1
    $release = $2
    $p_arch  = $3
    notice($distro)
    notice($release)
    notice($p_arch)
    validate_string($distro, '^(debian|centos|fedora|kali|scientificlinux|opensuse|oraclelinux|ubuntu)$', 'The currently supported values for distro are debian, centos, fedora, kali, oraclelinux, scientificlinux, opensuse',)
    validate_string($p_arch, '^(i386|i586|i686|x86_65|amd64)$', 'The currently supported values for pocessor architecture  are i386,i586,i686,x86_64,amd64',)
  } else {
    fail('You must put your entry in format "<Distro>-<Release>-<Processor Arch>" like "centos-7-x86_64" or "ubuntu-14.04-amd64"')
  }
  # convert release into rel_number to check to major and minor releases
  $rel_number = regsubst($release, '(\.)','','G')
  notice($rel_number)

  if $release =~/([0-9]+).([0-9])/{
    $rel_major = $1
    $rel_minor = $2
    notice($rel_major)
    notice($rel_minor)
  } else {
    warning("${distro} ${release} does not have major and minor point releases.")
  }

  notice($_dot_bootsplash)
  notice($autofile)
  notice($linux_installer)
  notice($pxekernel)
  notice($initrd)
  notice($target_initrd)
  notice($url)
  notice($inst_repo)
  notice($update_repo)
  notice($splashurl)
  notice($boot_iso_url)
  notice($boot_iso_name)
  notice($rel_name)

  if ( $distro == 'centos') {
    case $release {
      '2.1','3.1','3.3','3.4','3.5','3.6','3.7','3.8','3.9',
      '4.0','4.1','4.2','4.3','4.4','4.5','4.6','4.7','4.8','4.9',
      '5.0','5.1','5.2','5.3','5.4','5.5','5.6','5.7','5.8','5.9','5.10','5.11':{
        $centos_url = "http://vault.centos.org/${release}"
        $_dot_bootsplash = '.lss'
      }
      '6.0','6.1','6.2','6.3','6.4','6.5','6.6','6.7','6.8':{
        $centos_url = "http://vault.centos.org/${release}"
        $_dot_bootsplash = '.jpg'
      }
      '7.0','7.1','7.2':{
        $centos_url = "http://mirror.centos.org/centos/${rel_major}"
        $_dot_bootsplash = '.png'
      }
    }
    notice($centos_url)
    $autofile        = 'kickstart'
    $linux_installer = 'anaconda'
    $pxekernel       = 'vmlinuz'
    $initrd          = '.img'
    $target_initrd   = "${rel_number}${initrd}"
    $url             = "${centos_url}/os/${p_arch}/images/pxeboot"
    $inst_repo       = "${centos_url}/os/${p_arch}/"
    $update_repo     = "${centos_url}/updates/${p_arch}/"
    $splashurl       = "${centos_url}/isolinux/splash${_dot_bootsplash}"
    $boot_iso_url  = "${centos_url}/os/${p_arch}/images/boot.iso"

  }
      
  if ( $distro == 'fedora') {
    case $release {
      '2','3','4','5','6':{
        $fedora_url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/core"
        $fedora_flavor  = ""
        $_dot_bootsplash = '.lss'
      }
      '7','8','9','10','11','12','13','14','15','16','17','18','19','20':{
        $fedora_url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/releases"
        $fedora_flavor  = "Fedora/"
        $_dot_bootsplash = '.jpg'
      }
      '21':{
        $fedora_url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/releases"
        $fedora_flavor  = "Server/"
        $_dot_bootsplash = '.png'
      }
      '22','23','24','25':{
        $fedora_url = "http://download.fedoraproject.org/pub/fedora/linux/releases"
        $fedora_flavor  = "Server/"
        $_dot_bootsplash = '.png'
      }
    }
    notice($fedora_url)
    notice($fedora_flavor)
    $autofile        = 'kickstart'
    $linux_installer = 'anaconda'
    $pxekernel       = 'vmlinuz'
    $initrd          = '.img'
    $target_initrd   = "${rel_number}${initrd}"
    $url             = "${fedora_url}/${release}/${fedora_flavor}${p_arch}/os/images/pxeboot"
    $inst_repo       = "${fedora_url}/${release}/${fedora_flavor}/${p_arch}/os"
    $update_repo     = "${fedora_url}/${release}/${fedora_flavor}/${p_arch}/os"
    $splashurl       = "${fedora_url}/isolinux/splash${_dot_bootsplash}"
    $boot_iso_url    = "${fedora_url}/${release}/${fedora_flavor}${p_arch}/os/images/boot.iso"
  }
  if ( $distro == 'scientificlinux'){
    case $release {
      '50','51','52','53','54','55','56','57','58','59','510','511':{
        $scientificlinux_url        = "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}"
        $_dot_bootsplash = '.lss'
      }
      '6.0','6.1','6.2','6.3','6.4','6.5','6.6','6.7','6.8':{
        $scientificlinux_url = "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/os"
        $_dot_bootsplash = '.jpg'
      }
      '7.0','7.1','7.2':{
        $scientificlinux_url = "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/os"
        $_dot_bootsplash = '.png'
      }
    }
    notice($scientificlinux_url)
    $autofile        = 'kickstart'
    $linux_installer = 'anaconda'
    $pxekernel       = 'vmlinuz'
    $initrd          = '.img'
    $target_initrd   = "${rel_number}${initrd}"
    $url             = "${scientificlinux_url}/images/pxeboot"
    $inst_repo       = "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/os"
    $update_repo     = "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/updates/security"
    $splashurl       = "${scientificlinux_url}/isolinux/splash${_dot_bootsplash}" 
    $boot_iso_url    = "${scientificlinux_url}/images/boot.iso"
  }

  if ( $distro == 'opensuse') {
    case $release {
      '10.2','10.3','11.0','11.1','11.2','11.3','11.4','12.1','12.2':{
        warning("OpenSUSE ${release} for ${p_arch} a discontinued distribution downloaded from ${url}")
        $opensuse_url = "http://ftp5.gwdg.de/pub/opensuse/discontinued/distribution"
      }
      '12.3','13.1','13.2':{
        warning("OpenSUSE ${release} will be downloaded from ${url}")
        $opensuse_url = "http://download.opensuse.org/distribution"
      }
      'openSUSE-stable','openSUSE-current':{
        warning("OpenSUSE ${release} isn't currently functional")
      }
    }
      notice($opensuse_url)
    $autofile        = 'autoyast'
    $linux_installer = 'yast'
    $pxekernel       = 'linux'
    $initrd          = undef
    $target_initrd   = "${rel_number}.gz"
    $_dot_bootsplash      = '.jpg'
    $url             = "${opensuse_url}/${release}/repo/oss/boot/${p_arch}/loader"
    $inst_repo       = "${opensuse_url}/${release}/repo/oss/boot/${p_arch}/loader"
    $update_repo     = "${opensuse_url}/${release}/repo/non-oss/suse"
    $splash_url      = "${opensuse_url}/${release}/repo/oss/boot/${p_arch}/loader/back.jpg"
    $boot_iso_name   = "openSUSE-${release}-net-${p_arch}.iso"
    $boot_iso_url    = "${opensuse_url}/${release}/iso"
  }
 
  if ($distro == /(centos|fedora|oraclelinux)/) and ( $release >= '7.0' ) and ( $p_arch == 'i386'){
    fail("${distro} ${release} does not provide support for processor architecture i386")
  }
  
  # Begin tests for dealing with OracleLinux Repos
  if ( $distro == 'oraclelinux' ) {
    case $rel_major {
      '6':{
        $_U = 'U'
      }
      '7':{
        $_U = 'u'
      }
    }
    notice($_U)
    case $release {
      '7.1','7.2','7.3':{
        warning("There are currently no ${p_arch}-boot.iso on mirror so switching to Server ISO for ${name}")
        $boot_iso_name = "OracleLinux-R${rel_major}-U${rel_minor}-Server-${p_arch}-dvd.iso"
        $boot_iso_url    = "http://mirrors.kernel.org/oracle/OL${rel_major}/${_U}${rel_minor}/${p_arch}/${boot_iso_name}"
      }
      default:{
        warning("Oracle Linux ${release} is using the default name for the final boot.iso")
        $boot_iso_url    = "http://mirrors.kernel.org/oracle/OL${rel_major}/${_U}${rel_minor}/${p_arch}/${p_arch}-boot.iso"
      }
    }
    $autofile        = 'kickstart'
    $linux_installer = 'anaconda'
    $pxekernel       = 'vmlinuz'
    $initrd          = '.img'
    $target_initrd   = "${rel_number}${initrd}"
    $_dot_bootsplash      = '.png'
    $url             = 'ISO Required instead of URL'
    $inst_repo       = "http://mirrors.kernel.org/oracle/OL${rel_major}/${rel_minor}/base/${p_arch}/"
    $update_repo     = "http://mirrors.kernel.org/oracle/OL${rel_major}/${rel_minor}/base/${p_arch}/"
    $splashurl       = "http://mirrors.kernel.org/oracle/OL${rel_major}/${rel_minor}/base/${p_arch}/"
  }
  if ( $distro == 'redhat' ) {
    $autofile        = 'kickstart'
    $linux_installer = 'anaconda'
    $pxekernel       = 'vmlinuz'
    $initrd          = '.img'
    $target_initrd   = "${rel_number}${initrd}"
    $_dot_bootsplash      = '.jpg'
    $url             = 'ISO Required instead of URL'
    $inst_repo       = 'Install ISO Required'
    $update_repo     = 'Update ISO or Mirror Required'
    $splashurl       = 'ISO Required for Splash'
    $boot_iso_url  = 'No mini.iso or boot.iso to download'
  }
  if ( $distro == 'sles' ) {
    $autofile        = 'autoyast'
    $linux_installer = 'yast'
    $pxekernel       = 'linux'
    $initrd          = undef
    $target_initrd   = "${rel_number}.gz"
    $_dot_bootsplash      = '.jpg'
    $url             = 'ISO Required instead of URL'
    $inst_repo       = 'Install ISO Required'
    $update_repo     = 'Update ISO or Mirror Required'
    $splashurl       = 'ISO Required for Splash'
    $boot_iso_url  = 'No mini.iso or boot.iso to download'
  }
  if ( $distro == 'sled' ) {
    $autofile        = 'autoyast'
    $linux_installer = 'yast'
    $pxekernel       = 'linux'
    $initrd          = undef
    $target_initrd   = "${rel_number}.gz"
    $_dot_bootsplash      = '.jpg'
    $url             = 'ISO Required instead of URL'
    $inst_repo       = 'Install ISO Required'
    $update_repo     = 'Update ISO or Mirror Required'
    $splashurl       = 'ISO Required for Splash'
    $boot_iso_url  = 'No mini.iso or boot.iso to download'
  }
  if ( $distro == 'windows' ) {
    $autofile        = 'unattend.xml'
  }


  if ( $distro == 'ubuntu' ) {
    $rel_name = $release ? {
      /(11.04)/     => 'natty',
      /(11.10)/     => 'oneric',
      /(12.04)/     => 'precise',
      /(12.10)/     => 'quantal',
      /(13.04)/     => 'raring',
      /(13.10)/     => 'saucy',
      /(14.04)/     => 'trusty',
      /(14.10)/     => 'utopic',
      /(15.04)/     => 'vivid',
      /(15.10)/     => 'wily',
      /(16.04)/     => 'xenial',
      /(16.10)/     => 'yakkety',
      /(17.04)/     => 'zesty',
      default       => "${name} is not an Ubuntu release",
    }
    $autofile        = 'preseed'
    $linux_installer = 'd-i'
    $pxekernel       = 'linux'
    $initrd          = '.gz'
    $target_initrd   = "${rel_number}${initrd}"
    $_dot_bootsplash      = '.png'
    $url             = "http://archive.ubuntu.com/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}"
    $inst_repo       = "http://archive.ubuntu.com/${distro}/dists/${rel_name}"
    $update_repo     = "http://archive.ubuntu.com/${distro}/dists/${rel_name}"
    $splashurl       = "http://archive.ubuntu.com/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}/boot-screens/splash${_dot_bootsplash}"
    $boot_iso_url    = 'No mini.iso or boot.iso to download'
  }

  if ( $distro == 'debian' ) {
    $rel_name = $release ? {
      /(oldstable)/ => 'squeeze',
      /(stable)/    => 'wheezy',
      /(testing)/   => 'jessie',
      /(unstable)/  => 'sid',
      default       => "${name} is not an Debian release",
    }
    $autofile        = 'preseed'
    $linux_installer = 'd-i'
    $pxekernel       = 'linux'
    $initrd          = '.gz'
    $target_initrd   = "${rel_number}${initrd}"
    $_dot_bootsplash      = '.png'
    $url             = "http://ftp.debian.org/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}"
    $inst_repo       = "http://ftp.debian.org/${distro}/dists/${rel_name}"
    $update_repo     = "http://ftp.debian.org/${distro}/dists/${rel_name}"
    $splashurl       = "http://ftp.debian.org/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}/boot-screens/splash${_dot_bootsplash}"
    $boot_iso_url    = 'No mini.iso or boot.iso to download'
  }
  if ( $distro == 'kali' ) {
    $autofile        = 'preseed'
    $linux_installer = 'd-i'
    $pxekernel       = 'linux'
    $initrd          = '.gz'
    $target_initrd   = "${rel_number}${initrd}"
    $_dot_bootsplash      = '.png'
    $url             = "http://http.kali.org/kali/dists/kali-rolling/main/installer-${p_arch}/current/images/netboot/debian-installer/${p_arch}"
    $inst_repo       = 'http://http.kali.org/kali/dists/kali-rolling'
    $update_repo     = 'http://http.kali.org/kali/dists/kali-rolling'
    $splashurl       = "http://http.kali.org/kali/dists/kali-rolling/main/installer-${p_arch}/current/images/netboot/debian-installer/${p_arch}/boot-screens/splash${_dot_bootsplash}"
    $boot_iso_url    = 'No mini.iso or boot.iso to download'
  }

  $puppetlabs_repo = $distro ? {
    /(ubuntu|debian)/                                    => "http://apt.puppet.com/dists/${rel_name}",
    /(fedora)/                                           => "http://yum.puppet.com/fedora/f${rel_number}/products/${p_arch}",
    /(redhat|centos|scientificlinux|oraclelinux)/        => "http://yum.puppet.com/el/${rel_major}/products/${p_arch}",
    default                                              => 'No PuppetLabs Repo',
  }
  notice(puppetlabs_repo)

# Retrieve installation kernel file if supported
  case $url {
    'ISO Required instead of URL':{
      if $boot_iso_name {
        warning("A specific boot_iso_name: ${boot_iso_name} exists for ${name}" )
        $final_boot_iso_name = $boot_iso_name 
      } else {
        $final_boot_iso_name = "${release}-${p_arch}-boot.iso" 
      } 
      notice($final_boot_iso_name) 
      if ! defined (Staging::File["${name}-boot.iso"]){
        staging::file{"${name}-boot.iso":
          source  => $boot_iso_url,
          target  => "/srv/quartermaster/${distro}/ISO/${final_boot_iso_name}",
          require =>[
            Tftp::File["${distro}/${p_arch}"],
            File["/srv/quartermaster/${distro}/ISO"],
          ],
        }
      }
    }
    'No URL Specified':{
      warning("No URL is specified for ${name}")
    }
    default:{
    # Retrieve installation kernel file if supported
      if ! defined (Staging::File["${rel_number}-${name}"]){
        staging::file{"${rel_number}-${name}":
          source  => "${url}/${pxekernel}",
          target  => "/srv/quartermaster/tftpboot/${distro}/${p_arch}/${rel_number}",
          require => Tftp::File["${distro}/${p_arch}"],
        }
      }
      # Retrieve initrd file if supported
      if ! defined (Staging::File["${target_initrd}-${name}"]){
        staging::file{"${target_initrd}-${name}":
          source  => "${url}/initrd${initrd}",
          target  => "/srv/quartermaster/tftpboot/${distro}/${p_arch}/${target_initrd}",
          require =>  Tftp::File["${distro}/${p_arch}"],
        }
      }
 #     if ! defined (Staging::File["dot_bootsplash-${name}"]){
 #       staging::file{"dot_bootsplash-${name}":
 #         source  => $splashurl,
 #         target  => "/srv/quartermaster/tftpboot/${distro}/graphics/${name}${_dot_bootsplash}",
 #         require =>  Tftp::File["${distro}/graphics"],
 #       }
 #     }
    }
  }

#  if ! defined (Staging::File["_dot_bootsplash-${name}"]){
#    staging::file{"_dot_bootsplash-${name}":
#      source  => $splashurl,
#      target  => "/srv/quartermaster/tftpboot/${distro}/graphics/${name}${_dot_bootsplash}",
#      require =>  Tftp::File["${distro}/graphics"],
#    }
#  }

# Distro Specific TFTP Folders

  if ! defined (Tftp::File[$distro]){
    tftp::file { $distro:
      ensure  => directory,
    }
  }


  if ! defined (Tftp::File["${distro}/menu"]){
    tftp::file { "${distro}/menu":
      ensure  => directory,
    }
  }

  if ! defined (Tftp::File["${distro}/graphics"]){
    tftp::file { "${distro}/graphics":
      ensure  => directory,
    }
  }

  if ! defined (Tftp::File["${distro}/${p_arch}"]){
    tftp::file { "${distro}/${p_arch}":
      ensure  => directory,
    }
  }

# Distro Specific TFTP Graphics.conf

if $linux_installer == !('No Supported Linux Installer') {
  tftp::file { "${distro}/menu/${name}.graphics.conf":
    content => template("quartermaster/pxemenu/${linux_installer}.graphics.erb"),
    require => Tftp::File["${distro}/menu"],
  }
}
# Begin Creating Distro Specific HTTP Folders

  if ! defined (File["/srv/quartermaster/${distro}"]) {
    file { "/srv/quartermaster/${distro}":
      ensure  => directory,
      require => File[ '/srv/quartermaster' ],
    }
  }

  if ! defined (File["/srv/quartermaster/${distro}/${autofile}"]) {
    file { "/srv/quartermaster/${distro}/${autofile}":
      ensure  => directory,
      require => File[ "/srv/quartermaster/${distro}" ],
    }
  }

  if ! defined (File["/srv/quartermaster/${distro}/${p_arch}"]) {
    file { "/srv/quartermaster/${distro}/${p_arch}":
      ensure  => directory,
      require => File[ "/srv/quartermaster/${distro}" ],
    }
  }

  if ! defined (File["/srv/quartermaster/${distro}/ISO"]) {
    file { "/srv/quartermaster/${distro}/ISO":
      ensure  => directory,
      require => File[ "/srv/quartermaster/${distro}" ],
    }
  }
  if ! defined (File["/srv/quartermaster/${distro}/mnt"]) {
    file { "/srv/quartermaster/${distro}/mnt":
      ensure  => directory,
      require => File[ "/srv/quartermaster/${distro}" ],
    }
  }
  if ! defined (Concat["/srv/quartermaster/${distro}/.README.html"]) {
     concat{ "/srv/quartermaster/${distro}/.README.html":
      owner   => 'nginx',
      group   => 'nginx',
      mode    => '0644',
      require => File[ "/srv/quartermaster/${distro}" ],
#      content => template('quartermaster/README.html.erb'),
    }
  }
  if ! defined (Concat::Fragment["${distro}.default_README_header"]) {
    concat::fragment { "${distro}.default_README_header":
      target => "/srv/quartermaster/${distro}/.README.html",
      content => "<html>
<head><title> <%= @distro %> <%= @release%> <%=@p_arch%></title></head>
<body>
<h1>Operating System: <%= @distro %> </h1>
<h2>>Platform Release: <h2>",
      order   => 01,
    }
  }
  if ! defined (Concat::Fragment["${distro}.default_README_release_body.${name}"]) {
    concat::fragment { "${distro}.default_README_release_body.${name}":
      target => "/srv/quartermaster/${distro}/.README.html",
      content => "<li><b>* <i>${distro}-${release}</i> *</b></li>",
      order   => 02,
    }
  }
  if ! defined (Concat::Fragment["${distro}.default_README_footer"]) {
    concat::fragment { "${distro}.default_README_footer":
      target => "/srv/quartermaster/${distro}/.README.html",
      content => template('quartermaster/README.html.footer.erb'),
      order   => 03,
    }
  }
  if ! defined (Concat["/srv/quartermaster/${distro}/${p_arch}/.README.html"]) {
     concat{ "/srv/quartermaster/${distro}/${p_arch}/.README.html":
      owner   => 'nginx',
      group   => 'nginx',
      mode    => '0644',
      require => File[ "/srv/quartermaster/${distro}/${p_arch}" ],
#      content => template('quartermaster/README.html.erb'),
    }
  }
  if ! defined (Concat::Fragment["${distro}.default_${p_arch}_README_header"]) {
    concat::fragment { "${distro}.default_${p_arch}_README_header":
      target => "/srv/quartermaster/${distro}/${p_arch}/.README.html",
      content => template('quartermaster/README.html.header.erb'),
      order   => 01,
    }
  }
  if ! defined (Concat::Fragment["${distro}.default_README_p_arch_body"]) {
    concat::fragment { "${distro}.default_README_p_arch_body":
      target => "/srv/quartermaster/${distro}/${p_arch}/.README.html",
      content => "<h3>Processor Arch: ${p_arch}</h3>",
      order   => 02,
    }
  }
  if ! defined (Concat::Fragment["${distro}.default_${p_arch}_README_body.${name}"]) {
    concat::fragment { "${distro}.default_${p_arch}_README_body.${name}":
      target => "/srv/quartermaster/${distro}/${p_arch}/.README.html",
      content => template('quartermaster/README.html.body.erb'),
      order   => 03,
    }
  }
  if ! defined (Concat::Fragment["${distro}.default_${p_arch}_README_footer"]) {
    concat::fragment { "${distro}.default_${p_arch}_README_footer":
      target => "/srv/quartermaster/${distro}/${p_arch}/.README.html",
      content => template('quartermaster/README.html.footer.erb'),
      order   => 04,
    }
  }


# Kickstart/Preseed File
  file { "${name}.${autofile}":
    ensure  => file,
    path    => "/srv/quartermaster/${distro}/${autofile}/${name}.${autofile}",
    content => template("quartermaster/autoinst/${autofile}.erb"),
    require => File[ "/srv/quartermaster/${distro}/${autofile}" ],
  }

  if ! defined (Concat::Fragment["${distro}.default_menu_entry"]) {
    concat::fragment { "${distro}.default_menu_entry":
      target  => "/srv/quartermaster/tftpboot/pxelinux/pxelinux.cfg/default",
      content => template('quartermaster/pxemenu/default.erb'),
      order   => 02,
    }
  }

  if ! defined (Concat["/srv/quartermaster/tftpboot/menu/${distro}.menu"]) {
    concat { "/srv/quartermaster/tftpboot/menu/${distro}.menu":
    }
  }
  if ! defined (Concat::Fragment["${distro}.submenu_header"]) {
    concat::fragment {"${distro}.submenu_header":
      target  => "/srv/quartermaster/tftpboot/menu/${distro}.menu",
      content => template('quartermaster/pxemenu/header2.erb'),
      order   => 01,
    }
  }
#  if $linux_installer == !('No Supported Linux Installer') {
  if ! defined (Concat::Fragment["${distro}${name}.menu_item"]) {
    concat::fragment {"${distro}.${name}.menu_item":
      target  => "/srv/quartermaster/tftpboot/menu/${distro}.menu",
      content => template("quartermaster/pxemenu/${linux_installer}.erb"),
    }
  }
#}

#  if $linux_installer == !('No Supported Linux Installer') {
    tftp::file { "${distro}/menu/${name}.menu":
      content => template("quartermaster/pxemenu/${linux_installer}.erb"),
    }
#  }
}