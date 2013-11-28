#
# == Class: derby
#
# This is the main derby class
#
#
# === Parameters
#
# [*source_url*]
#   Url from where to download Derby zip
#   Default: 'http://www.eu.apache.org/dist/db/derby/db-derby-10.9.1.0/db-derby-10.9.1.0-bin.zip'
#
# [*install_dir*]
#   Directory where to install derby
#   Default: '/opt/derby'
#
# [*template_init*]
#   Optional custom template to use for init script
#   Default: 'derby/derby.init.erb'
#
# [*user*]
#   User the derby service will run as
#   Default: 'derby'
#
# [*java_home*]
#   Optional java_home
#   Default: '' (System's one is used)
#
# [*source*]
#   Sets the content of source parameter for main configuration file
#   If defined, derby main config file will have the param: source => $source
#
# [*source_dir*]
#   If defined, the whole derby configuration directory content is retrieved
#   recursively from the specified source
#   (source => $source_dir , recurse => true)
#
# [*source_dir_purge*]
#   If set to true (default false) the existing configuration directory is
#   mirrored with the content retrieved from source_dir
#   (source => $source_dir , recurse => true , purge => true)
#
# [*template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, derby main config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#
# [*service_autorestart*]
#   Automatically restarts the derby service when there is a change in
#   configuration files. Default: true, Set to false if you don't want to
#   automatically restart the service.
#
# [*absent*]
#   Set to true to remove all the resources installed by the module
#   Default: false
#
# [*disable*]
#   Set to 'true' to disable service(s) managed by module. Default: false
#
# [*disableboot*]
#   Set to 'true' to disable service(s) at boot, without checks if it's running
#   Use this when the service is managed by a tool like a cluster software
#   Default: false
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet. Default: false
#
# [*noops*]
#   Set noop metaparameter to true for all the resources managed by the module.
#   Basically you can run a dryrun for this specific module if you set
#   this to true. Default: false
#
class derby (
  $source_url          = 'http://archive.apache.org/dist/db/derby/db-derby-10.9.1.0/db-derby-10.9.1.0-bin.zip',
  $install_dir         = '/opt/derby',
  $template_init       = 'derby/derby.init.erb',
  $user                = 'derby',
  $java_home           = '',
  $source              = '',
  $source_dir          = '',
  $source_dir_purge    = '',
  $template            = '',
  $service_autorestart = true,
  $options             = '',
  $absent              = false,
  $disable             = false,
  $disableboot         = false,
  $audit_only          = false,
  $noops               = false
  ) {

  #################################################
  ### Definition of modules' internal variables ###
  #################################################

  $service            = 'derby'
  $config_file        = ''
  $config_dir         = ''
  $config_file_mode   = '0644'
  $config_file_owner  = 'derby'
  $config_file_group  = 'derby'
  $created_dir        = url_parse($source_url, filedir)
  $homedir            = "${install_dir}/${created_dir}"

  # Variables that apply parameters behaviours
  $manage_service_enable = $derby::disableboot ? {
    true    => false,
    default => $derby::disable ? {
      true    => false,
      default => $derby::absent ? {
        true    => false,
        default => true,
      },
    },
  }

  $manage_service_ensure = $derby::disable ? {
    true    => 'stopped',
    default =>  $derby::absent ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  $manage_service_autorestart = $derby::service_autorestart ? {
    true    => Service[derby],
    default => undef,
  }

  $manage_file = $derby::absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_audit = $derby::audit_only ? {
    true    => 'all',
    default => undef,
  }

  $manage_file_replace = $derby::audit_only ? {
    true    => false,
    default => true,
  }

  $manage_file_source = $derby::source ? {
    ''        => undef,
    default   => $derby::source,
  }

  $manage_file_content = $derby::template ? {
    ''        => undef,
    default   => template($derby::template),
  }

  #######################################
  ### Resourced managed by the module ###
  #######################################

  # Installation
  require derby::install

  # Service
  service { $derby::service:
    ensure     => $derby::manage_service_ensure,
    enable     => $derby::manage_service_enable,
    require    => Class['derby::install'],
    noop       => $derby::noops,
  }

  # Configuration File
  if $derby::source or $derby::template {
    file { 'derby.conf':
      ensure  => $derby::manage_file,
      path    => $derby::config_file,
      mode    => $derby::config_file_mode,
      owner   => $derby::config_file_owner,
      group   => $derby::config_file_group,
      require => Class['derby::install'],
      notify  => $derby::manage_service_autorestart,
      source  => $derby::manage_file_source,
      content => $derby::manage_file_content,
      replace => $derby::manage_file_replace,
      audit   => $derby::manage_audit,
      noop    => $derby::noops,
    }
  }

  # Configuration Directory
  if $derby::source_dir != '' {
    file { 'derby.dir':
      ensure  => directory,
      path    => $derby::config_dir,
      require => Class['derby::install'],
      notify  => $derby::manage_service_autorestart,
      source  => $derby::source_dir,
      recurse => true,
      purge   => $derby::source_dir_purge,
      force   => $derby::source_dir_purge,
      replace => $derby::manage_file_replace,
      audit   => $derby::manage_audit,
      noop    => $derby::noops,
    }
  }

}


