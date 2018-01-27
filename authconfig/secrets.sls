{% from "authconfig/map.jinja" import authconfig with context %}

{% set pass = authconfig.sssd_pass %}
{% if authconfig.get('sdb_sssd_pass') %}
  {% set pass = salt['sdb.get'](authconfig.sdb_sssd_pass) %}
{% endif %}

{% set name = authconfig.sssd_name %}
{% if authconfig.get('sdb_sssd_name') %}
  {% set name = salt['sdb.get'](authconfig.sdb_sssd_name) %}
{% endif %}
