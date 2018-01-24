{% from "authconfig/map.jinja" import authconfig with context %}

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

hash_authconfig_bind_pass:
  cmd.run:
    - name: echo -n {{ authconfig.sssd_pass }} | sss_obfuscate -s -d {{ authconfig.domain }}
    - env:
        - PYTHONPATH: ${PYTHONPATH}:/usr/lib64/python2.7/site-packages
    - shell: {{ grains.shell if 'shell' in grains else '/bin/bash' }}

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
        - match: '#PasswordAuthentication'
        - mode: replace
        - watch_in:
            - service: sshd_service

password_auth_no_removal:
    file.line:
        - name: /etc/ssh/sshd_config
        - content: 'PasswordAuthentication no'
        - match: '#PasswordAuthentication'
        - mode: delete
        - watch_in:
            - service: sshd_service
