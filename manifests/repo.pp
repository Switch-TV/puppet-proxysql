# @summary Manage the repos where the ProxySQL package might be.
#
# @api private
class proxysql::repo {
  assert_private()

  if $proxysql::manage_repo and !$proxysql::package_source {
    $repo = $proxysql::version ? {
      /^2\.2\./ => $proxysql::params::repo22,
      /^2\.1\./ => $proxysql::params::repo21,
      /^2\.0\./ => $proxysql::params::repo20,
      /^1\.4\./ => $proxysql::params::repo14,
      default   => fail("Unsupported `proxysql::version` ${proxysql::version}")
    }
    case $facts['os']['family'] {
      'Debian': {
        apt::source { 'proxysql_repo':
          * => $repo,
        }
        Class['apt::update'] -> Package[$proxysql::package_name]
      }
      'RedHat': {
        yumrepo { $repo['name']:
          * => $repo,
        }

        $purge_repos = $proxysql::version ? {
          /^2\.2\./ => [ $proxysql::params::repo14['name'], $proxysql::params::repo20['name'], $proxysql::params::repo21['name'] ],
          /^2\.1\./ => [ $proxysql::params::repo14['name'], $proxysql::params::repo20['name'], $proxysql::params::repo22['name'] ],
          /^2\.0\./ => [ $proxysql::params::repo14['name'], $proxysql::params::repo21['name'], $proxysql::params::repo22['name'] ],
          /^1\.4\./ => [ $proxysql::params::repo20['name'], $proxysql::params::repo21['name'], $proxysql::params::repo22['name'] ],
        }
        yumrepo { ['proxysql_repo'] + $purge_repos]:
          ensure => absent,
        }
      }
      default: {
        fail('This operatingsystem is not supported (yet).')
      }
    }
  }
}
