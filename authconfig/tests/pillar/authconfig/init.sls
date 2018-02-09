authconfig:
  basedn: CN=Users,DC=ad,DC=global,DC=somedomain,DC=net
  bind_user: cn=Administrator,CN=Users,dn=ad,dn=global,dn=somedomain,dn=net
  computer_ou: OU=Linux,OU=ITManagedServers,DC=ad,DC=global,DC=somedomain,DC=net
  domain: ad.global.somedomain.net
  krb_dc_host: globalad.corp.somedomain.net
  krb_dc_port: 88
  realm: AD.GLOBAL.SOMEDOMAIN.NET
  sssd_pass: password
  sssd_name: Administrator
  servers:
    - ad.somedomain.net
