{% from "authconfig/map.jinja" import authconfig with context %}
{% from "authconfig/secrets.sls" import pass %}
{% do authconfig.update({ 'sssd_pass': pass }) %}

{% if (( grains['virtual'] != 'bhyve' and 'virtual_subtype' not in grains ) or
       ( grains.get('virtual_subtype') != 'Docker')) %}
update_hosts:
  file.line:
    - name: /etc/hosts
    - mode: insert
    - content: authconfig.get('authconfig:domain', '{0} {1} {2}.{3}'.format(grains['ip_interfaces:eth0'], grains['host'], grains['host'], authconfig.domain ))
    - location: end
{% endif %}

copy_krb5_conf:
  file.managed:
    - name: /etc/krb5.conf
    - source: salt://authconfig/files/krb5.conf
    - template: jinja

copy_sssd_conf:
  file.managed:
    - name: /etc/sssd/sssd.conf
    - source: salt://authconfig/files/sssd.conf
    - template: jinja
    - mode: 0600
{% if grains['virtual'] != 'bhyve' %}
    - watch_in:
      - service: sssd_service
{% endif %}

{% if authconfig.ldap_authtok %}
hash_authconfig_bind_pass:
  cmd.run:
    - name: echo -n {{ authconfig.sssd_pass }} | sss_obfuscate -s -d {{ authconfig.domain }}
    - env:
      - PYTHONPATH: ${PYTHONPATH}:/usr/lib64/python2.7/site-packages
    - shell: {{ grains.shell if 'shell' in grains else '/bin/bash' }}
{% endif %}

{% if grains['virtual'] != 'bhyve' %}
sssd_service:
  service.running:
    - name: sssd
    - enable: True
{% endif %}

copy_access_conf:
  file.managed:
    - name: /etc/security/access.conf
    - source: salt://authconfig/files/access.conf
    - template: jinja

{% if grains['virtual'] != 'bhyve' %}
sshd_service:
  service.running:
    - name: sshd
    - enable: True
{% endif %}

copy_ssh_issue:
  file.managed:
    - name: /etc/ssh/issue
    - source: salt://authconfig/files/ssh_issue
    - require_in: /etc/ssh/sshd_config

fix_banner:
  file.replace:
    - name: /etc/ssh/sshd_config
    - repl: 'Banner /etc/ssh/issue\n'
    - pattern: |
        ^#Banner.*
{% if grains['virtual'] != 'bhyve' %}
    - watch_in:
      - service: sshd_service
{% endif %}

password_auth_yes_add:
  file.replace:
    - name: /etc/ssh/sshd_config
    - repl: 'PasswordAuthentication yes\n'
    - pattern: |
        ^#PasswordAuthentication.*
{% if grains['virtual'] != 'bhyve' %}
    - watch_in:
      - service: sshd_service
{% endif %}

{% if grains['virtual'] != 'bhyve' %}
restart_authconfig:
  service.running:
    - name: sssd
    - watch:
      - file: /etc/nsswitch.conf
      - file: /etc/sssd/sssd.conf
{% endif %}

cleanup_discovery:
  file.absent:
    - name: /var/tmp/dclocator.py

cleanup_discovery_virtual_env:
  file.absent:
    - name: /var/tmp/srvlookup
