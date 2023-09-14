# knot

## Installation

```bash
$ wget https://secure.nic.cz/files/knot-resolver/knot-resolver-release.deb
$ dpkg -i knot-resolver-release.deb
$ apt update
$ apt install -y knot-resolver socat
$ kresd -V
Knot Resolver, version 5.6.0
# It is inactive at the beginning
$ sudo service kresd@1.service status
```

Edit the configuration file `/etc/knot-resolver/kresd.conf`. Specify the interface to listen on (`X.X.X.X`) and the access control list (`Y.Y.Y.Y`):

```bash
net.listen('X.X.X.X', 53, { kind = 'dns' })
...
modules.load('view')
-- whitelist queries identified by subnet
view:addr('Y.Y.Y.Y/32', policy.all(policy.PASS))
-- drop everything that hasn't matched
view:addr('0.0.0.0/0', policy.all(policy.DROP))

modules = {
        'hints > iterate',  -- Allow loading /etc/hosts or custom root hints
        'stats',            -- Track internal statistics
        'predict',          -- Prefetch expiring/frequent records
        'serve_stale < cache',
}

```

Restart:

```bash
$ sudo service kresd@1.service restart
```

Save the resolver's IP and username in `.env` under `RESOLVER_KNOT_IP` and `RESOLVER_KNOT_USERNAME`.
