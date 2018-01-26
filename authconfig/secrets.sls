{% from "authconfig/map.jinja" import authconfig with context %}

{% if authconfig.sdb %}
  {% set pass = 'sdb://' + authconfig.sdb_location + '/password' %}
  {% set name = 'sdb://' + authconfig.sdb_location + '/username' %}
{% else %}
  {% set pass = authconfig.sssd_pass %}
  {% set name = authconfig.sssd_name %}
{% endif %}
