{% from "authconfig/map.jinja" import authconfig with context %}

python_ad_extract-dirs:
  file.directory:
    - name: {{ authconfig.discovery.tmpdir }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require_in:
      - python-ad-package-install

{%- if authconfig.discovery.hashsum %}
   # Check local archive using hashstring for older Salt.
   # (see https://github.com/saltstack/salt/pull/41914).
  {%- if grains['saltversioninfo'] <= [2016, 11, 6] %}
python_ad_archive_hash:
   module.run:
     - name: file.check_hash
     - path: salt://authconfig/files/{{ authconfig.discovery.archive_name }}
     - file_hash: {{ authconfig.discovery.hashsum }}
     - require_in:
       - python_ad_package_install
  {%- endif %}
{%- endif %}

python_ad_package_install:
  archive.extracted:
    - name: {{ authconfig.discovery.tmpdir }}
    - source: salt://authconfig/files/{{ authconfig.discovery.archive_name }}
    - archive_format: {{ authconfig.discovery.archive_type }}
    - enforce_toplevel: False
       {%- if authconfig.discovery.hashsum and grains['saltversioninfo'] > [2016, 11, 6] %}
    - source_hash: {{ authconfig.discovery.hashsum }}
       {%- endif %}
    - if_missing: {{ authconfig.discovery.tmpdir }}/{{ authconfig.discovery.archive_name }}
    - require_in:
      - add_dc_discovery_script

add_dc_discovery_script:
  file.managed:
    - name: /var/tmp/discovery.py
    - source: salt://authconfig/files/dclocator.py
    - mode: 754
    - require_in:
      - run_dc_discovery

run_dc_discovery:
  cmd.run:
    - name: source /var/tmp/python-ad/bin/activate && python /var/tmp/dclocator.py {{ authconfig.domain }}

refresh_pillar_data:
  cmd.run:
    - name: salt-call --local saltutil.refresh_pillar
    - onchanges:
      - file: /srv/pillar/authconfig/init.sls
    - require:
      - run_dc_discovery
