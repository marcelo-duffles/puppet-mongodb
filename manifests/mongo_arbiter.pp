# == Class: mongo_arbiter
#
# Manage mongodb arbiter instance.
#

class mongo_arbiter (
  $servicename     = 'mongod-arbiter',
  $hasstatus       = true,
  $config          = '/etc/mongod-arbiter.conf',
  $dbpath          = '/var/lib/mongo',
  $logpath         = '/var/log/mongo/mongod-arbiter.log',
  $pidfilepath     = '/var/lib/mongo/mongod-arbiter.pid',
  $logappend       = true,
  $mongofork       = true,
  $port            = '27018',
  $oplogsize       = 8,
  $replset         = 'DEFAULT'
) {
  
  Class['mongodb'] -> Class['mongo_arbiter']
  
  file { $config:
    content => template("${module_name}/mongod.conf.erb"),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }
  
  file { $dbpath :
    ensure => 'directory',
    mode    => '0755',
    owner   => 'mongod',
    group   => 'mongod',
  }
  ->
  file { "/etc/init.d/${servicename}":
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/mongod.erb")
  } 
  ->
  service { $servicename:
    ensure    => running,
    enable    => true,
    hasstatus => $hasstatus, 
    subscribe => File[$config],
  }
}
