authconfig:
  basedn: DN=ad,DN=somedomain,DN=net
  bind_user: cn=Administrator,CN=Users,dn=ad,dn=somedomain,dn=net
  computer_ou: something
  domain: somedomain.net
  krb_dc_host: globalad.corp.somedomain.net
  krb_dc_port: 88
  realm: ad.somedomain.net
  servers:
    - ad.somedomain.net
  sssd_pass: password
  sssd_name: Administrator
