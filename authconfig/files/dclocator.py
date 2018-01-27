from sys import argv
import srvlookup

name = 'ldap'
domain = argv[1]

discovered = srvlookup.lookup(name, domain=domain)
servers = [srv.host for srv in discovered]


with open('/srv/pillar/authconfig/init.sls', 'a') as authconfig_conf:
    authconfig_conf.write("  servers:\n")
    for server in servers:
        authconfig_conf.write("    - {}\n".format(server))
