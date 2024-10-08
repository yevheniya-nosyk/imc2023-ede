# Extended DNS Errors: Unlocking the Full Potential of DNS Troubleshooting

This repository contains all the instructions to reproduce our IMC-2023 paper on Extended DNS Errors. More information can be found on [project's website](https://extended-dns-errors.com).

## Installation

### Docker

Depending on your system, follow the [official guidelines](https://docs.docker.com/engine/install/) on Docker installation.

To avoid running Docker with sudo, add your user to the docker group:

```bash
sudo usermod -a -G docker <username>
```

### Packages

```bash
$ sudo apt-get install tshark screen git
```

### Environment Variables

Create a `.env` file in the root of this repository and gradually add variables there. The file is not tracked by git.

### Domains

Register one domain name that we'll use to set up misconfigured DNS zones and perform measurements. Save it under `DOMAIN` in `.env`.

### SSH Keys

Generate a key pair that will be used to connect to different servers involved in the project. Place it somewhere on your system and save the location under `SSH_KEY_PRIVATE` in `.env`.

```bash
$ ssh-keygen -f extended-errors -t rsa -b 4096
```

### Go

Install Go (visit https://go.dev/doc/install to get the latest version).

```bash
$ wget https://go.dev/dl/go1.18.3.linux-amd64.tar.gz
$ tar -xzf go1.18.3.linux-amd64.tar.gz
```

### zdns

Install `zdns` for the large-scale domain scan (ensure that it is at the latest version that supports EDE):

```bash
$ git clone https://github.com/zmap/zdns.git
$ cd zdns
$ go build
```

Save the path to zdns executable in `.env` file under `ZDNS_PATH`.

### Authoritative nameservers

We need two basic VPSes to set up authoritative nameservers for our domain and all its subdomains. Once rented, do the basic configuration (create a user, configure the firewall, install BIND9), and save the following information under `.env`: `NS_PARENT_IP`, `NS_CHILD_IP`, `NS_PARENT_USERNAME`, `NS_CHILD_USERNAME`.

### Recursive Resolvers

We set up recursive resolvers to test using Dockerfiles in `configs/resolvers` and images provided by `https://hub.docker.com/r/cznic/knot-resolver/`.

## Misconfiguration Testing

### Configure subdomains

The domains below contain various misconfigurations or corner cases that may trigger extended DNS errors:

- `valid`: The correctly configured control domain 
- `unsigned`: The domain name is not signed with DNSSEC 
- `allow-query-none`: Nameserver does not accept queries for the subdomain 
- `allow-query-localhost`: Nameserver only accepts queries from the localhost 
- `no-ds`: The subdomain is correctly signed but no `DS` record was published at the parent zone 
- `ds-bad-tag`: The key tag field of the `DS` record at the parent zone does not correspond to the `KSK DNSKEY` ID at the child zone 
- `ds-bad-key-algo`: The algorithm field of the `DS` record at the parent zone does not correspond to the `KSK DNSKEY` algorithm at the child zone 
- `ds-unassigned-key-algo`: The algorithm value of the `DS` record at the parent zone is unassigned (`100`) 
- `ds-reserved-key-algo`: The algorithm value of the `DS` record at the parent zone is reserved (`200`) 
- `ds-unassigned-digest-algo`: The digest algorithm value of the `DS` record at the parent zone is unassigned (`100`) 
- `ds-bogus-digest-value`: The digest  value of the `DS` record at the parent zone does not correspond to the `KSK DNSKEY` at the child zone 
- `rrsig-exp-all`: All the `RRSIG` records are expired 
- `rrsig-exp-a`: The `RRSIG` over `A` RRset is expired 
- `rrsig-not-yet-all`: All the `RRSIG` records are not yet valid 
- `rrsig-not-yet-a`: The `RRSIG` over `A` RRset is not yet valid 
- `rrsig-exp-before-all`: All the `RRSIG`s expired before the inception time 
- `rrsig-exp-before-a`: The `RRSIG` over `A` RRset expired before the inception time 
- `rrsig-no-all`: All the RRSIGs were removed from the zone file 
- `rrsig-no-a`: The `RRSIG` over `A` RRset was removed from the zone file
- `no-rrsig-ksk`: The `RRSIG` over `KSK DNSKEY` was removed from the zone file 
- `no-rrsig-dnskey`: All the `RRSIG`s over `DNSKEY` RRsets were removed from the zone file 
- `bad-nsec3-hash`: Hashed owner names were modified in all the `NSEC3` records 
- `bad-nsec3-next`: Next hashed owner names were modified in all the `NSEC3` records 
- `bad-nsec3param-salt`: The salt value of the `NSEC3PARAM` resource record is wrong 
- `bad-nsec3-rrsig`: `RRSIG`s over `NSEC3` RRsets are bogus 
- `nsec3-missing`: All the `NSEC3` records were removed from the zone file 
- `nsec3-rrsig-missing`: `RRSIG`s over `NSEC3` RRsets were removed from the zone file 
- `nsec3param-missing`: `NSEC3PARAM` resource record was removed from the zone file 
- `no-nsec3param-nsec3`: `NSEC3` and `NSEC3PARAM` resource records were removed from the zone file 
- `no-zsk`: The `ZSK DNSKEY` was removed from the zone file 
- `bad-zsk`: The `ZSK DNSKEY` resource record is wrong 
- `no-ksk`: The `KSK DNSKEY` was removed from the zone file 
- `bad-rrsig-ksk`: The `RRSIG` over `KSK DNSKEY` is wrong 
- `bad-ksk`: The `KSK DNSKEY` is wrong 
- `bad-rrsig-dnskey`: All the `RRSIG`s over `DNSKEY` RRsets are wrong 
- `no-dnskey-256`: The Zone Key Bit is set to `0` for the `ZSK DNSKEY` 
- `no-dnskey-257`: The Zone Key Bit is set to `0` for the `KSK DNSKEY` 
- `no-dnskey-256-257`: The Zone Key Bit is set to `0` for both the `KSK DNSKEY` and `ZSK DNSKEY` 
- `bad-zsk-algo`: The `ZSK DNSKEY` algorithm number is wrong 
- `unassigned-zsk-algo`: The `ZSK DNSKEY` algorithm number is unassigned (`100`) 
- `reserved-zsk-algo`: The `ZSK DNSKEY` algorithm number is reserved (`200`) 
- `ed448`: The zone is signed with ED448 algorithm 
- `dsa`: The zone is signed with DSA algorithm 
- `rsamd5`: The zone is signed with RSAMD5 algorithm 
- `v6-doc`: The `AAAA` glue record at the parent zone is from the documentation range 
- `v4-doc`: The `A` glue record at the parent zone is a documentation address 
- `nsec3-iter-1`: `NSEC3` iteration count is set to `1` 
- `nsec3-iter-51`: `NSEC3` iteration count is set to `51` 
- `nsec3-iter-101`: `NSEC3` iteration count is set to `101` 
- `nsec3-iter-151`: `NSEC3` iteration count is set to `151` 
- `nsec3-iter-200`: `NSEC3` iteration count is set to `200` 
- `not-auth`: Given nameservers are not authoritative for this domain

All the above subdomains are created using the script below. Add the desired `A` and `AAAA` records to `.env` under `A_RECORD`/`AAAA_RECORD`:

```bash
$ ./scripts/configure_zones.sh > configure_zones.out 2>&1
```

Check the output of the above script to see what should be added to your registrar's control panel (for the parent domain only).

The list of created subdomains is stored in `data/misconfigured_subdomains.txt` (updated manually).

### Test subdomains

We can now check how different resolvers handle the above misconfigured subdomains. The `configs/resolvers` directory provides 3 Dockerfiles for recursive resolver software (BIND 9.19.23, Unbound 1.20.0, PowerDNS Recursor 5.0.4) and we pull the Knot Resolver 5.7.3 image directly from DockerHub. Apart from those, we test Cloudflare (1.1.1.1), Google DNS (8.8.8.8), Quad9 (9.9.9.9), OpenDNS (208.67.222.222), and SIDN public resolver (194.0.5.3):

```bash
$ ./scripts/subdomains_test.sh
```

The output is written to `data/subdomains_test/YYYMMDD`.

## Domain scan

### Input list

Obtain a list of one domain name per line to scan, for example, Tranco 1 million.

### Scanning interfaces

To efficiently scan hundreds of millions domain names, we use a server with the whole /24 usable for our measurements. Add a comma-sepatared list of source IP addresses as `SCAN_SOURCE_IPS`. You can use the expession like below to dynamically generate those IPs:

```bash
SOURCE_IPS=$(for host in {2..254}; do echo 1.1.1.$host; done | tr '\n' ',' | sed '$ s/.$//')
```

### Scan

Run the scan of the whole domain name space to identify the most common misconfigurations:

```bash
$ ./scripts/domain_scan.sh <domain_input_file.txt>
```

Data is stored at `data/domain_scan/YYYYMMDD`.
