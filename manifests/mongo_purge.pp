class mongo_purge (
  $purge_log_path,
  $data_retention_in_months,
  $script_dir
) {

  File {
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
  }

  file { 'mongodb_occupation.js':
    path    => "${script_dir}/mongodb_occupation.js",
    mode    => '0600',
    source  => "puppet:///modules/${module_name}/mongodb_occupation.js"
  }
  ->
  file { 'mongodb_purge.js':
    path    => "${script_dir}/mongodb_purge.js",
    mode    => '0600',
    content => template("${module_name}/mongodb_purge.js.erb"),
  }
  ->  
  file { 'mongodb_purge.sh':
    path    => "${script_dir}/mongodb_purge.sh",
    mode    => '0700',
    content => template("${module_name}/mongodb_purge.sh.erb"),
  }
  ->
  cron { 'mongodb-purge':
    ensure  => 'present',
    command => "${script_dir}/mongodb_purge.sh",
    user    => 'root',
    hour    => 4,
    minute  => 0,
  }

  
}
