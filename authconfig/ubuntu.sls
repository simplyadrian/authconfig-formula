{% from "authconfig/map.jinja" import authconfig with context %}

authconfig_packages:
  pkg.installed:
    - pkgs: {{ authconfig.packages }}
      refresh: True


copy_nsswitch_conf:
  file.managed:
        - name: /etc/nsswitch.conf
        - source: salt://authconfig/files/nsswitch.conf
        - template: jinja

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
