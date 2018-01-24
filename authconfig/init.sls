{% from "authconfig/map.jinja" import authconfig with context %}

include:
  {% if grains['os_family'] == 'RedHat' %}
  - authconfig/redhat
  {% elif grains['os_family'] == 'Debian' %}
  - authconfig/ubuntu
  {% endif %}
  - authconfig/discovery
  - authconfig/common
