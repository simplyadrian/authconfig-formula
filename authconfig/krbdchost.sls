{% from "authconfig/map.jinja" import authconfig with context %}

{% if grains['os_family'] == 'RedHat'  %}
  {% set url = salt['grains.filter_by']({
    '7': authconfig.get('authconfig:krb_dc_host', '{0}:{1}'.format(authconfig.krb_dc_host, 88)),
    '6': authconfig.get('authconfig:krb_dc_host)'),
  }, grain='osmajorrelease', default='7' )
  %}
{% else %}
  {% set url = authconfig.krb_dc_host %}
{% endif %}
