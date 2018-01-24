{% from "authconfig/map.jinja" import authconfig with context %}

discovery-extract-dirs:
  file.directory:
    - name: {{ authconfig.discovery.tmpdir }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require_in:
      - discovery-package-install

{%- if authconfig.discovery.hashsum %}
   # Check local archive using hashstring for older Salt.
   # (see https://github.com/saltstack/salt/pull/41914).
  {%- if grains['saltversioninfo'] <= [2016, 11, 6] %}
discovery-check-archive-hash:
   module.run:
     - name: file.check_hash
     - path: salt://authconfig/files/{{ authconfig.discovery.archive_name }}
     - file_hash: {{ authconfig.discovery.hashsum }}
     - require_in:
       - archive: discovery-package-install
  {%- endif %}
{%- endif %}

discovery-package-install:
  archive.extracted:
    - name: {{ authconfig.discovery.tmpdir }}
    - source: salt://authconfig/files/{{ authconfig.discovery.archive_name }}
    - archive_format: {{ authconfig.discovery.archive_type }}
    - enforce_toplevel: False
       {%- if authconfig.discovery.hashsum and grains['saltversioninfo'] > [2016, 11, 6] %}
    - source_hash: {{ authconfig.discovery.hashsum }}
       {%- endif %}
    - if_missing: {{ authconfig.discovery.tmpdir }}/{{ authconfig.discovery.archive_name }}

#run-discovery:
#  cmd.run:
# TODO:
#   - name: source /var/tmp/python-ad/bin/activate && python /run_something.py
#   - set return values to authconfig.servers key and update before common state runs.
