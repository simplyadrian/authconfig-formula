{% from "authconfig/map.jinja" import authconfig with context %}
{% from "authconfig/krbdchost.sls" import url %}
{% from "authconfig/secrets.sls" import pass %}
{% from "authconfig/secrets.sls" import name %}

{% do authconfig.update({'sssd_pass': pass}) %}
{% do authconfig.update({'sssd_name': name}) %}

{% set vm_flag = False %}
{% if ((grains['virtual'] != 'bhyve' and 'virtual_subtype' not in grains) or
       (grains.get('virtual_subtype') and grains.get('virtual_subtype') != 'Docker')) %}
  {% set vm_flag = True %}
{% endif %}

install_prereqs:
  pkg.installed:
    - pkgs: {{ authconfig.packages }}
      refresh: True

join_domain:
  cmd.run:
    - name: echo -n {{ authconfig.sssd_pass }} | adcli join --stdin-password --domain-ou={{ authconfig.computer_ou }} --login-user={{ authconfig.sssd_name }} {{ authconfig.domain }}
    - creates: /etc/krb5.keytab

copy_ntp_conf:
  file.managed:
    - name: /etc/ntp.conf
    - source: salt://authconfig/files/ntp.conf
    - template: jinja

{% if vm_flag %}
ntp_service:
  service.running:
    - name: ntp
    - enable: True
    - watch:
      - file: /etc/ntp.conf
{% endif %}

copy_nsswitch_conf:
  file.managed:
        - name: /etc/nsswitch.conf
        - source: salt://authconfig/files/nsswitch.conf
        - template: jinja

nsswitch_passwd:
  file.replace:
    - name: /etc/nsswitch.conf
    - repl: 'passwd:         compat sss\n'
    - pattern: |
        ^passwd: .*

nsswitch_group:
  file.replace:
    - name: /etc/nsswitch.conf
    - repl: 'group:          compat sss\n'
    - pattern: |
        ^group: .*

nsswitch_netgroup:
  file.replace:
    - name: /etc/nsswitch.conf
    - repl: 'netgroup:       nis sss\n'
    - pattern: |
        ^netgroup: .*

copy_mkhomedir:
  file.managed:
    - name: /usr/share/pam-configs/mkhomedir
    - source: salt://authconfig/files/mkhomedir.j2
    - user: root
    - group: root
    - mode: 0644

copy_pam_configs:
  file.managed:
    - name: /usr/share/pam-configs/access
    - source: salt://authconfig/files/pam_config_access.j2
    - user: root
    - group: root
    - mode: 0644

pam_auth_update:
  cmd.run:
    - name: /usr/sbin/pam-auth-update --package

copy_samba_conf:
  file.managed:
    - name: /etc/samba/smb.conf
    - source: salt://authconfig/files/smb.conf
    - template: jinja

{% if vm_flag %}
samba_service:
  service.running:
    - name: smb
    - enable: True
    - watch:
      - file: /etc/samba/smb.conf
{% endif %}

{% if vm_flag %}
nmbd_service:
  service.running:
    - name: nmbd
    - enable: True
    - watch:
      - file: /etc/samba/smb.conf
{% endif %}
