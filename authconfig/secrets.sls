{% from "authconfig/map.jinja" import authconfig with context %}

{% if authconfig.sdb %}
  {% set pass = 'sdb://secrets/creds/sssd_pass' %}
  {% set name = 'sdb://secrets/creds/sssd_name' %}
{% else %}
  {% set pass = authconfig.sssd_pass %}
  {% set name = authconfig.sssd_name %}
{% endif %}
