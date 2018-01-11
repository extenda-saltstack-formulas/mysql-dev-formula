mysql:
  community:
    enabled: true
    repo: 'mysql56-community'
    version: 'mysql-community-server-5.6.28-2.el7.x86_64'
    init: 'mysql_install_db --user=mysql'
    build: '01'
    development: true