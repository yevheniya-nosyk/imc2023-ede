# PowerDNS Recursor

## Installation

Create the file `/etc/apt/sources.list.d/pdns.list` with this content:

```bash
deb [arch=amd64] http://repo.powerdns.com/ubuntu jammy-rec-48 main
```

Create the file `/etc/apt/preferences.d/pdns` with this content:

```bash
Package: pdns-*
Pin: origin repo.powerdns.com
Pin-Priority: 600
```

Install:

```bash
$ curl https://repo.powerdns.com/FD380FBB-pub.asc | sudo apt-key add -
$ sudo apt-get update
$ sudo apt-get install pdns-recursor
# Extended errors are supported from version 4.5.0
$ pdns_recursor --version
Feb 20 13:27:02 PowerDNS Recursor 4.8.2 (C) 2001-2022 PowerDNS.COM BV
```

Update the configuration file `/etc/powerdns/recursor.conf` to listen on `X.X.X.X` interface, accept queries from a specific IP only (`Y.Y.Y.Y`), and enable DNSSEC validation:

```bash
...
allow-from=Y.Y.Y.Y
...
local-address=X.X.X.X
...
dnssec=validate
...
extended-resolution-errors=yes
...
serve-stale-extensions=120
```

Restart:

```bash
$ sudo service pdns-recursor restart
```

Save the resolver's IP and username in `.env` under `RESOLVER_PDNS_IP` and `RESOLVER_PDNS_USERNAME`.
