from sys import argv
import ad, pkgutil
package=ad.core

locator = ad.core.locate.Locator()
servers = locator.locate("{}".format(argv[1]))

with open('/srv/pillar/authconfig/init.sls','a') as authconfig_conf:
    authconfig_conf.write("  servers:\n")
    for server in servers:
        authconfig_conf.write("    - {}\n".format(server))
