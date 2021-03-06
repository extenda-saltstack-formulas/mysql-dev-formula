{% set mysql_repo = pillar.mysql.community.get('repo', 'mysql57-community') %}
{% set mysql_version = pillar.mysql.community.get('version', 'mysql-community-server.x86_64') %}
{% set mysql_init = pillar.mysql.community.get('init', 'mysqld --initialize-insecure --explicit_defaults_for_timestamp --user=mysql') %}

{% if grains['os_family'] == 'RedHat' %}
  {% if grains['osmajorrelease']|int == 5 %}
  {% set rpm_source = "http://repo.mysql.com/mysql57-community-release-el5.rpm" %}
  {% elif grains['osmajorrelease']|int == 6 %}
  {% set rpm_source = "http://repo.mysql.com/mysql57-community-release-el6.rpm" %}
  {% elif grains['osmajorrelease']|int == 7 %}
  {% set rpm_source = "http://repo.mysql.com/mysql57-community-release-el7.rpm" %}
  {% endif %}
{% endif %}

{% set mysql57_community_release = salt['pillar.get']('mysql:release', false) %}
# A lookup table for MySQL Repo GPG keys & RPM URLs for various RedHat releases
  {% set pkg = {
    'key': 'http://repo.mysql.com/RPM-GPG-KEY-mysql',
    'key_hash': 'md5=472a4a4867adfd31a68e8c9bbfacc23d',
    'rpm': rpm_source
 } %}


install_pubkey_mysql:
  file.managed:
    - name: /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
    - source: {{ salt['pillar.get']('mysql:pubkey', pkg.key) }}
    - source_hash:  {{ salt['pillar.get']('mysql:pubkey_hash', pkg.key_hash) }}

mysql57_community_release:
  pkg.installed:
    - sources:
      - mysql57-community-release: {{ salt['pillar.get']('mysql:repo_rpm', pkg.rpm) }}
    - require:
      - file: install_pubkey_mysql

set_pubkey_mysql:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/mysql-community.repo
    - pattern: '^gpgkey=.*'
    - repl: 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql'
    - require:
      - pkg: mysql57_community_release

set_gpg_mysql:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/mysql-community.repo
    - pattern: 'gpgcheck=.*'
    - repl: 'gpgcheck=1'
    - require:
      - pkg: mysql57_community_release

{% if mysql_repo != 'mysql57-community' %}
mysql57-community:
  pkgrepo.managed:
    - enable: False

{{ mysql_repo }}:
  pkgrepo.managed:
    - enable: True
{% endif %}

mysql-community-server.x86_64:
    pkg.installed:
        - version: {{ mysql_version }}

mysql-remove-old:
  cmd.run:
    - name: 'rm -f /var/log/mysqld.log'

/var/log/mysql:
  file.directory:
    - user: mysql
    - group: mysql
    - dir_mode: 644
    - makedirs: True

mysql-init:
  cmd.run:
    - name: {{  mysql_init }}
    - unless: 'mysqlshow -u root -h localhost mysql'

/etc/my.cnf:
  file.managed:
    - source: salt://files/my.cnf
    - template: jinja
    - mode: 644

mysqld:
  service.running:
    - enable: True
