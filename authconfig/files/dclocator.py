import socket
from sys import argv
from telnetlib import Telnet

import srvlookup

NAMES = ['ldap']


def get_ip(hostname):
    return socket.gethostbyname(hostname)


def ldap_ping(ip):
    try:
        Telnet(ip, 389, 5)
    except:
        return False
    return True


def main():
    domain = argv[1]
    discovered = []
    servers = []

    for name in NAMES:
        for thing in srvlookup.lookup(name, domain=domain):
            if ldap_ping(get_ip(thing.host)):
                discovered.append(thing)

    servers.extend([srv.host for srv in discovered])
    servers = sorted(list(set(servers)))
    print(','.join(servers))


if __name__ == '__main__':
    main()
