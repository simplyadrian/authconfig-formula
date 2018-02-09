{% from "authconfig/map.jinja" import authconfig with context %}
{% from "authconfig/secrets.sls" import pass %}
{% do authconfig.update({ 'sssd_pass': pass }) %}

# Common files between the dists
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
    - watch_in:
      - service: sssd_service

{% if authconfig.ldap_authtok %}
hash_authconfig_bind_pass:
  cmd.run:
    - name: echo -n {{ authconfig.sssd_pass }} | sss_obfuscate -s -d {{ authconfig.domain }}
    - env:
      - PYTHONPATH: ${PYTHONPATH}:/usr/lib64/python2.7/site-packages
    - shell: {{ grains.shell if 'shell' in grains else '/bin/bash' }}
{% endif %}

sssd_service:
  service.running:
    - name: sssd
    - enable: True

copy_access_conf:
  file.managed:
    - name: /etc/security/access.conf
    - source: salt://authconfig/files/access.conf
    - template: jinja

sshd_service:
  service.running:
    - name: sshd
    - enable: True

copy_ssh_issue:
  file.managed:
    - name: /etc/ssh/issue
    - source: salt://authconfig/files/ssh_issue
    - require_in: /etc/ssh/sshd_config

fix_banner:
  file.line:
    - name: /etc/ssh/sshd_config
    - content: 'Banner /etc/ssh/issue'
    - match: '#Banner'
    - mode: replace
    - watch_in:
      - service: sshd_service

password_auth_yes_add:
  file.line:
    - name: /etc/ssh/sshd_config
    - content: 'PasswordAuthentication yes'
    - match: '#?PasswordAuthentication[ no]?'
    - mode: replace
    - watch_in:
      - service: sshd_service

gss_api_auth_yes_add:
  file.line:
    - name: /etc/ssh/sshd_config
    - content: 'GSSAPIAuthentication yes'
    - match: '#?GSSAPIAuthentication[ no]?'
    - mode: replace
    - watch_in:
      - service: sshd_service

gss_api_delegate_creds_yes_add:
  file.line:
    - name: /etc/ssh/sshd_config
    - content: 'GSSAPIDelegateCredentials yes'
    - match: '#?GSSAPIDelegateCredentials[ no]?'
    - mode: replace
    - watch_in:
      - service: sshd_service

restart_authconfig:
  service.running:
    - name: sssd
    - watch:
      - file: /etc/nsswitch.conf
      - file: /etc/sssd/sssd.conf

cleanup_discovery:
  file.absent:
    - name:
      - /var/tmp/dclocator.py
      - /var/tmp/srvlookup
