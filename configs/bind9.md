# BIND9

## Installation

```bash
$ sudo add-apt-repository ppa:isc/bind-dev
$ sudo apt update
$ sudo apt-get install bind9
$ named -v
BIND 9.19.9-2+ubuntu22.04.1+isc+1-Ubuntu (Development Release) <id:>
```

Configure `/etc/bind/named.conf.options` and update the `acl` statement to specify which hosts can reach this resolver:

```bash
acl closed-resolver { X.X.X.X/32;};

options {
    directory "/var/cache/bind";
    allow-query { closed-resolver; };
   	dnssec-validation auto;
    listen-on-v6 { any; };
    stale-cache-enable yes;
    stale-answer-enable yes;
};
```

Restart:

```bash
$ sudo service named restart
```

Save the resolver's IP and username in `.env` under `RESOLVER_BIND_IP` and `RESOLVER_BIND_USERNAME`.
