
class mongo(
  $enable_10gen             = true,
  $primary_server           = "localhost:27017",
  $secondary_server         = "",
  $arbiter_server           = "",
  $port                     = 27017,
  $logdir                   = '/var/log/mongo',
  $data_retention_in_months = 2,
  $dbpath                   = '/var/lib/mongo',
  $config                   = '/etc/mongod.conf',,
  $replset                  = 'DEFAULT',
  $script_dir               = '/usr/local/sbin',
) {

  $log_path                 = "${logdir}/mongod.log"
  $arbiter_log_path         = "${logdir}/mongod-arbiter.log"
  $purge_log_path           = "${logdir}/mongodb_purge.log"

  
  # This is ugly, but works
  $postrotate1 = "killall -SIGUSR1 mongod && find ${logdir}/"
  $postrotate2 = ' -type f -regex ".*\.\(log.[0-9].*-[0-9].*\)" -exec rm {} \;'
  $postrotate  = "${postrotate1}${postrotate2}"
  
  class {'mongodb':
    enable_10gen  => $enable_10gen,
    hasstatus     => $hasstatus,
    logpath       => $logpath,
    pidfilepath   => $pidfilepath,
    dbpath        => $dbpath,
    config        => $config,
    replset       => $replset,
  }
  ->
  logrotate::rule { 'mongodb':
    path          => "${logdir}/mongod*",
    rotate        => 7,
    missingok     => true,
    compress      => true,
    delaycompress => true,
    ifempty       => false,
    create        => true,
    create_mode   => 0640,
    create_owner  => 'mongod',
    create_group  => 'mongod',
    size          => '100M',
    sharedscripts => true,
    postrotate    => $postrotate,
  }
  ->
  class {'mongo_purge':
    purge_log_path           => $purge_log_path,
    data_retention_in_months => $data_retention_in_months,
    script_dir		     => $script_dir,
  } 

  if $is_primary {
    file { 'mongodb_initiate_replica_set.sh':
      require => Class['mongodb'],
      path    => "${script_dir}/mongodb_initiate_replica_set.sh",
      mode    => '0700',
      content => template("${module_name}/mongodb_initiate_replica_set.sh.erb"),
    }
    ~>
    exec { 'mongodb-initiate-replica-set':
      command     => "${script_dir}/mongodb_initiate_replica_set.sh",
      refreshonly => true,
    }
  } else {
    # secondary server needs an arbiter installed in the same machine
    class {'mongo_arbiter':
      replset => $replset,      
    } 
  }
}

