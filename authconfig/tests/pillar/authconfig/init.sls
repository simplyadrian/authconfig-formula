authconfig:
  basedn: DN=ad,DN=somedomain,DN=net
  bind_user: cn=Administrator,CN=Users,dn=ad,dn=somedomain,dn=net
  computer_ou: something
  domain: test
  krb_dc_host: globalad.corp.adobe.com
  realm: ad.somedomain.net
  servers:
    - ad.somedomain.net
