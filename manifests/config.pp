# == Class: kibana::configure
#
# This class configures kibana.  It should not be directly called.
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
#
# === Copyright
#
# Copyright 2013 EvenUp.
#
class kibana::config (
  $es_host            = '',
  $es_port            = 9200,
  $modules            = [ 'histogram','map','table','filtering','timepicker',
                        'text','fields','hits','dashcontrol','column',
                        'derivequeries','trends','bettermap','query','terms' ],
  $logstash_logging = false,
  $webserver_type   = 'apache',
  $default_board    = 'default.json',
  $application_root = '/var/www/html/kibana',
) {

  $es_real = $es_host ? {
    ''      => "http://'+window.location.hostname+':${es_port}",
    default => "http://${es_host}:${es_port}"
  }

  file { "${application_root}/config.js":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('kibana/config.js'),
    require => Package["${kibana::webserver_type}"],
  }

  case $webserver_type {
    apache: { include kibana::server::apache }
    nginx: { include kibana::server::nginx }
    default: { include kibana::server::apache }
  }

  if $default_board != 'default.json' {
    file { "${application_root}/app/dashboards/default.json":
      ensure  => link,
      target  => "/var/www/html/kibana/app/dashboards/${default_board}",
      force   => true,
    }
  }

}
