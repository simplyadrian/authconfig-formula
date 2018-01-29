{% from "authconfig/map.jinja" import authconfig with context %}
{% from "authconfig/krbdchost.sls" import url %}
{% from "authconfig/secrets.sls" import pass %}
{% from "authconfig/secrets.sls" import name %}

{% set run_opts= '--krb5realm=' + authconfig.domain  + ' ' + '--disablekrb5kdcdns' + ' ' + '--disablekrb5realmdns' + ' ' + '--krb5kdc=' + url + ' ' + '--krb5adminserver=' + authconfig.domain + ' ' + '--update' %}
{% do authconfig.update({'opts': run_opts}) %}
{% do authconfig.update({'sssd_pass': pass}) %}
{% do authconfig.update({'sssd_name': name}) %}

{% set runit = true %}

{% if authconfig.sssd_pass is none %}
  {% set runit = false %}
  fail_if_no_sssd_pass:
    cmd.run:
      - name: echo 'authconfig.sssd_pass is not set'
{% endif %}

{% if authconfig.sssd_name is none %}
  {% set runit = false %}
  fail_if_no_sssd_name:
    cmd.run:
      - name: echo 'authconfig.sssd_name is not set'
{% endif %}


{% if runit %}
install_prereqs:
  pkg.installed:
    - pkgs: {{ authconfig.packages }}

join_domain:
  cmd.run:
    - name: echo -n {{ authconfig.sssd_pass }} | adcli join --stdin-password --domain-ou={{ authconfig.computer_ou }} --login-user={{ authconfig.sssd_name }} {{ authconfig.domain }}
    - creates: /etc/krb5.keytab

restart_authconfig:
  service.running:
    - name: sssd
    - watch:
        - file: /etc/nsswitch.conf

run_authconfig:
  cmd.run:
    - name: /usr/sbin/authconfig {{ authconfig.opts }}
    - creates: /var/lib/authconfig/backup-configured

nsswitch_passwd:
  file.replace:
    - name: /etc/nsswitch.conf
    - repl: 'passwd:     files sss'
    - pattern: |
        ^passwd: .*

nsswitch_shadow:
  file.replace:
    - name: /etc/nsswitch.conf
    - repl: 'shadow:     files sss'
    - pattern: |
        ^shadow: .*

nsswitch_group:
  file.replace:
    - name: /etc/nsswitch.conf
    - repl: 'group:     files sss'
    - pattern: |
        ^group: .*
{% endif %}
