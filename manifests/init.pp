# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include cd4pe_tools
class cd4pe_tools (
  Boolean $cd4pe_class_manage = false,
  Hash    $cd4pe_class_params = {},

  Boolean $cd4pe_backup_manage        = false,
  String  $cd4pe_backup_script_path   = '/usr/local/bin/cd4pe_backup.sh',
  Hash    $cd4pe_backup_script_params = {},
  Hash    $cd4pe_backup_options       = {},
  String  $cd4pe_backup_cron          = '',
) {

  if $cd4pe_class_manage {
    if $cd4pe_class_params != {} {
      include cd4pe
    } else {
      class { 'cd4pe':
        * => $cd4pe_class_params,
      }
    }
  }

  if $cd4pe_backup_manage {
    $cd4pe_backup_options_defaults = {
      filename         => '/var/tmp/cd4pe_backup.tgz',
      work_dir         => '/var/tmp/cd4pe',
      backup_dir       => '/var/tmp/cd4pe_backups',
      cd4pe_hostname   => $::fqdn,
      backup_retention => '5',
    }
    $options = $cd4pe_backup_options_defaults + $cd4pe_backup_options


    $cd4pe_backup_script_params_defaults = {
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template('cd4pe_tools/cd4pe_backup.sh.erb'),
    }
    $script_params = $cd4pe_backup_script_params_defaults + $cd4pe_backup_script_params

    file { $cd4pe_backup_script_path:
      * => $script_params,
    }

    if $cd4pe_backup_cron != '' {
      file { '/etc/cron.d/cd4pe_tools_backup':
        ensure  => present,
        content => "${cd4pe_backup_cron} root $cd4pe_backup_path backup",
      }
    } else {
      file { '/etc/cron.d/cd4pe_tools_backup':
        ensure  => absent,
      }
    }
  }
}
