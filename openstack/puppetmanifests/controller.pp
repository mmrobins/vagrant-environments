#stage { initial_apt_update: before => Stage[apt_cacher_server], }
stage { apt_cacher_server:  before => Stage[sync_apt_cache],    }
stage { sync_apt_cache:     before => Stage[apt_cacher_client], }
stage { apt_cacher_client:  before => Stage[main],              }
class {
  "apt-cacher-ng::server": stage => apt_cacher_server;
  "sync-apt-cache":        stage => sync_apt_cache;
  "apt-cacher-ng::client": stage => apt_cacher_client;
  #"initial-apt-update":    stage => intial_apt_update;
}
include 'apt-cacher-ng::server'
include 'sync-apt-cache'
include 'apt-cacher-ng::client'
#include 'initial-apt-get-update'

class initial-apt-update {
  exec { 'init apt-get update' :
    command => 'apt-get update',
    path => '/usr/bin:/bin',
  }
}

# sync cache both ways for reuse
class sync-apt-cache {
  Exec { path => '/usr/bin:/bin' }
  exec { 'sync out of vm' : command => 'rsync -oar /var/cache/apt-cacher-ng/* /vagrant/apt-cacher-ng' }
  exec { 'sync into vm'   : command => 'rsync -oar /vagrant/apt-cacher-ng/* /var/cache/apt-cacher-ng' }
  exec { 'chown -R apt-cacher-ng:apt-cacher-ng /var/cache/apt-cacher-ng' : require => Exec['sync into vm'] }
}

## since the cache directory is owned by vagrant
# but this doesn't work
#group { 'vagrant' :
#  ensure => present,
#}
#user { 'apt-cacher-ng' :
#  groups => ['vagrant'],
#  require => [ Group['vagrant'], Package['apt-cacher-ng'] ],
#}
include 'development-niceties'
include 'openstack-nova'
