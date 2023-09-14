# Unbound

## Installation

```bash
$ sudo apt-get install unbound
# Extended errors are supported from version 1.16.0
$  unbound -V
Version 1.16.2
...
```

Update the configuration file `/etc/unbound/unbound.conf` to listen on `X.X.X.X` interface, accept queries from a single machine only (`Y.Y.Y.Y`), and support extended errors:

```bash
server:
        interface: X.X.X.X
        access-control: Y.Y.Y.Y allow
        ede: yes
        serve-expired: yes
        ede-serve-expired: yes
        val-log-level: 2
        module-config: "respip validator iterator"
```

Save the resolver's IP and username in `.env` under `RESOLVER_UNBOUND_IP` and `RESOLVER_UNBOUND_USERNAME`.
