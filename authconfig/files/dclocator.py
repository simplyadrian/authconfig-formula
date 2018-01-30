from sys import argv
import srvlookup

names = ['ldap', 'kerberos']
domain = argv[1]
servers = []

for name in names:
    discovered = srvlookup.lookup(name, domain=domain)
    servers.extend([srv.host for srv in discovered])

servers = sorted(list(set(servers)))
print(','.join(servers))
