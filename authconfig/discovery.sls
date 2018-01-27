{% from "authconfig/map.jinja" import authconfig with context %}

srvlookup_extract-dirs:
  file.directory:
    - name: {{ authconfig.discovery.tmpdir }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require_in:
      - srvlookup_package_install

{%- if authconfig.discovery.hashsum %}
   # Check local archive using hashstring for older Salt.
   # (see https://github.com/saltstack/salt/pull/41914).
  {%- if grains['saltversioninfo'] <= [2016, 11, 6] %}
srvlookup_archive_hash:
   module.run:
     - name: file.check_hash
     - path: salt://authconfig/files/{{ authconfig.discovery.archive_name }}
     - file_hash: {{ authconfig.discovery.hashsum }}
     - require_in:
       - srvlookup_package_install
  {%- endif %}
{%- endif %}

srvlookup_package_install:
  archive.extracted:
    - name: {{ authconfig.discovery.tmpdir }}
    - source: salt://authconfig/files/{{ authconfig.discovery.archive_name }}
    - archive_format: {{ authconfig.discovery.archive_type }}
    - enforce_toplevel: False
       {%- if authconfig.discovery.hashsum and grains['saltversioninfo'] > [2016, 11, 6] %}
    - source_hash: {{ authconfig.discovery.hashsum }}
       {%- endif %}
    - trim_output: 5
    - if_missing: {{ authconfig.discovery.tmpdir }}/{{ authconfig.discovery.archive_name }}

add_dc_discovery_script:
  file.managed:
    - name: /var/tmp/dclocator.py
    - source: salt://authconfig/files/dclocator.py
    - mode: 754
    - require:
      - srvlookup_package_install
    - require_in:
      - run_dc_discovery

{% set servers = salt['cmd.shell']('"source" + ' ' +  authconfig.discovery.tmpdir + "/bin/activate" + ' ' + "&& python /var/tmp/dclocator.py" + ' ' + authconfig.domain') %}

check_vars:
  cmd.run:
{% if servers %}
    - name: echo {{ servers }}
{% else %}
    - name: echo 'not set'
{% endif %}

