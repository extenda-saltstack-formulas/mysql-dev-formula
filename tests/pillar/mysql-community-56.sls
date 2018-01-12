mysql:
  community:
    enabled: true
    repo: 'mysql56-community'
    version: '5.6.28-2.el7'
    init: 'mysql_install_db --explicit_defaults_for_timestamp --user=mysql'
    build: '01'
    development: true