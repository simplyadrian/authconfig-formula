import re
import socket
from subprocess import check_output
from sys import argv
from telnetlib import Telnet

import srvlookup

NAMES = ['ldap']


def get_ip(hostname):
    return socket.gethostbyname(hostname)


def ldap_ping(ip):
    try:
        Telnet(ip, 389, 3)
    except:
        return False
    return True


def srv_lookup(domain):
    hosts = {}
    for name in NAMES:
        for thing in srvlookup.lookup(name, domain=domain):
            host_ip = get_ip(thing.host)
            if ldap_ping(host_ip):
                hosts[thing.host] = host_ip
    return hosts


def sort_pings(hosts):
    ping_times = {}
    for hostname, host_ip in hosts.items():
        res = check_output(['ping', '-c', '1', host_ip])
        match = re.search('time=\d+\.\d+', res, re.MULTILINE)
        if match:
            part = match.group()
            rtime = part.split('=').pop()
            ping_times[hostname] = float(rtime)
            # print('{}\t{}\t{}'.format(rtime, host_ip, hostname))
    return ping_times


def get_winners(pings, winner_count=2):
    winners = []
    for key, value in sorted(pings.items(), key=lambda (k, v): (v, k)):
        winners.append(key)
        if len(winners) == winner_count:
            return winners


def main():
    domain = argv[1]
    try:
        host_count = int(argv[2])
    except:
        host_count = 2
    hosts = srv_lookup(domain)
    host_pings = sort_pings(hosts)
    winners = get_winners(host_pings, host_count)
    print(','.join(winners))


if __name__ == '__main__':
    main()
