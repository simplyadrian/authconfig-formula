from sys import argv
import ad

domain = argv[1]

locator = ad.core.locate.Locator()
servers = locator.locate(domain)

with open('/srv/pillar/authconfig/init.sls', 'a') as authconfig_conf:
    authconfig_conf.write("  servers:\n")
    for server in servers:
        authconfig_conf.write("    - {}\n".format(server))
