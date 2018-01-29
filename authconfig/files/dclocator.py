from sys import argv
import srvlookup

name = 'ldap'
domain = argv[1]

discovered = srvlookup.lookup(name, domain=domain)
servers = [srv.host for srv in discovered]

print(servers)
