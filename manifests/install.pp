#
# == Class derby::install
#
# This class installs derby
#
class derby::install {

  if !defined(User['derby']) {
    user { 'derby':
      ensure  => present,
      home    => $derby::install_dir,
    }
  }

  $filename = url_parse($derby::source_url, filename)
  $filenamenoext = url_parse($derby::source_url, filenamenoext)
  $target_dir = "${derby::install_dir}/${filenamenoext}"

  file { $derby::install_dir:
    ensure  => directory,
    owner   => 'derby',
    group   => 'derby',
    require => User['derby']
  }

  wget::fetch { 'derby':
    source         => $derby::source_url,
    destination    => "${derby::install_dir}/${filename}",
    require        => [ 
      User['derby'],
      File[$derby::install_dir]
    ]
  }

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec {'unpack derby':
    command        => "mkdir -p ${$target_dir} && unzip -o ${derby::install_dir}/${filename} -d ${derby::install_dir}",
    creates        => $target_dir,
    require        => Wget::Fetch['derby']
  }

  file { '/etc/init.d/derby':
    ensure  => $derby::manage_file,
    content => template ($derby::template_init),
    mode    => '0755',
  }

}


