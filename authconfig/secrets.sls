{% from "authconfig/map.jinja" import authconfig with context %}

{% set pass = authconfig.sssd_pass %}
{% if authconfig.sdb_sssd_pass %}
  {% set pass = salt['sdb.get'](authconfig.sdb_sssd_pass) %}
{% endif %}

{% set name = authconfig.sssd_name %}
{% if authconfig.sdb_sssd_name %}
  {% set name = salt['sdb.get'](authconfig.sdb_sssd_name) %}
{% endif %}

{% if pass is none %}
  {{ salt.test.exception("pass is not set.. The authconfig.sssd_pass or authconfig.sdb_sssd_pass pillar must be set") }}
{% endif %}

{% if name is none %}
  {{ salt.test.exception("name is not set.. The authconfig.sssd_name or authconfig.sdb_sssd_name pillar must be set") }}
{% endif %}
