# Extended DNS Errors: Unlocking the Full Potential of DNS Troubleshooting

This repository contains all the instructions to reproduce our IMC-2023 paper on Extended DNS Errors. More information can be found on (project's website)[https://extended-dns-errors.com].

## Prerequisites

### Python

Create the virutal environment and install the requirements:

```bash
$ python3 -m virtualenv -p python3 .venv
$ source .venv/bin/activate
$ pip3 install -r requirements.txt
```

### Environment Variables

Create a `.env` file in the root of this repository and gradually add variables there. The file is not tracked by git.

### Domain Name

Register one domain name that we'll use to set up misconfigured DNS zones and perform measurements. Save it under `DOMAIN` variable in `.env`.

### SSH Keys

Generate a key pair that will be used to connect to different servers involved in the project. Place it somewhere on your system and save the location under `SSH_KEY_PRIVATE` in `.env`:

```bash
$ ssh-keygen -f extended-errors -t rsa -b 4096
``` 

### Go

Install Go (visit https://go.dev/doc/install to get the latest version):

### zdns

Install `zdns` for the large-scale scan (ensure that it is at the latest version that supports printing EDE codes in results):

```bash
$ git clone https://github.com/zmap/zdns.git
$ cd zdns
$ go build
```

Save the path to zdns executable in `.env` file under `ZDNS_PATH`.

### zdns threads

Specify how many zdns thread should be used to run the scans inside `ZDNS_THREADS`. This value will depend on the number of source IP addresses used, your network bandwidth, your system etc. Please discuss with your local network administrator prior to launching any large-scale measurement. 

### Scanning interfaces

Add one IP address or a comma-sepatared list of source IPs that we will scan from as `SCAN_SOURCE_IPS`. If using multiple addresses, you can generate the list dynamically:

```bash
SCAN_SOURCE_IPS=$(for host in {2..254}; do echo 1.1.1.$host; done | tr '\n' ',' | sed '$ s/.$//')
```

### Virtual Private Servers

#### Authoritative nameservers

We need 2 basic VPSes to set up authoritative nameservers for our domain and all its subdomains. Once rented, do the basic configuration of your choice (create a user, configure the firewall), and save the following information inside `.env`: `NS_PARENT_IP`, `NS_CHILD_IP`, `NS_PARENT_USERNAME`, `NS_CHILD_USERNAME`. We will configure the nameservers later.

#### Recursive resolvers

We need another 4 VPSes to set up 4 recursive resolver software (BIND9, Unbound, PowerDNS Recursor, Knot Resolver). Follow the installation and configuration instructions in `configs/`. Please note that we used Ubuntu 22.04 and the latest packaged versions did not yet support Extended DNS Errors.

### Public DNS Resolvers

Apart from 4 pieces of software installed, we will also test 3 big public DNS resolver providers that support Extended DNS Errors as of May 2023. Store their IPs inside `.env` as `RESOLVER_CLOUDFLARE`, `RESOLVER_QUAD9`, and `RESOLVER_OPENDNS`.

### Resolver for the Domain Scan

Choose one EDE-compliant resolver that will be used for a large-scale domain scan and save it under `RESOLVER_DOMAIN_SCAN`.

### Domain list

Provide a path to the list of domain names to be scanned with the `RESOLVER_DOMAIN_SCAN` and save the path under `DOMAIN_LIST`.

## Triggering Extended DNS Errors

### Create Subdomains

The domains below contain various misconfigurations and corner cases that may trigger extended DNS errors:

- `valid`: The correctly configured control domain 
- `unsigned`: The domain name is not signed with DNSSEC 
- `allow-query-none`: Nameserver does not accept queries for the subdomain 
- `allow-query-localhost`: Nameserver only accepts queries from the localhost 
- `no-ds`: The subdomain is correctly signed but no `DS` record was published at the parent zone 
- `ds-bad-tag`: The key tag field of the `DS` record at the parent zone does not correspond to the `KSK DNSKEY` ID at the child zone 
- `ds-bad-key-algo`: The algorithm field of the `DS` record at the parent zone does not correspond to the `KSK DNSKEY` algorithm at the child zone 
- `ds-unassigned-key-algo`: The algorithm value of the `DS` record at the parent zone is unassigned (`100` ) 
- `ds-reserved-key-algo`: The algorithm value of the `DS` record at the parent zone is reserved (`200`) 
- `ds-unassigned-digest-algo`: The digest algorithm value of the `DS` record at the parent zone is unassigned (`100` ) 
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
- `no-nsec3param-nsec3`: `NSEC3` and `NSECPARAM` resource records were removed from the zone file 
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
- `v6-mapped`: The `AAAA` glue record at the parent zone is an IPv6-mapped IPv4 address
- `v6-unspecified`: The `AAAA` glue record at the parent zone is an unspecified address
- `v4-hex`: The `AAAA` glue record at the parent zone is an IPv4 address in hex form
- `v6-link-local`: The `AAAA` glue record at the parent zone is a link local address
- `v6-localhost`: The `AAAA` glue record at the parent zone is a localhost 
- `v6-mapped-dep`: The `AAAA` glue record at the parent zone is a deprecated IPv6-mapped IPv4 address 
- `v6-doc`: The `AAAA` glue record at the parent zone is from the documentation range 
- `v6-unique-local`: The `AAAA` glue record at the parent zone is from a unique local address 
- `v6-nat64`: The `AAAA` glue record at the parent zone is used for NAT64 
- `v6-multicast`: `AAAA` The glue record at the parent zone is from a multicast range 
- `v4-private-10`: The `A` glue record at the parent zone is a private address 
- `v4-private-172`: The `A` glue record at the parent zone is a private address 
- `v4-private-192`: The `A` glue record at the parent zone is a private address 
- `v4-this-host`: The `A` glue record at the parent zone is a `0.0.0.0` 
- `v4-loopback`: The `A` glue record at the parent zone is a loopback address 
- `v4-link-local`: The `A` glue record at the parent zone is a  link-local address 
- `v4-doc`: The `A` glue record at the parent zone is a documentation address 
- `v4-reserved`: The `A` glue record at the parent zone is a reserved address 

All the above subdomains are created using the script below. Zone files will contain `A` and `AAAA` record so please add them to `.env` under `A_RECORD`/`AAAA_RECORD`:

```bash
$ ./scripts/configure_zones.sh > configure_zones.out 2>&1
```

Check the output of the above script to see what should be added to your registrar's control panel (for the parent domain only).

The domain names below are signed with very old algorithms or require other settings that are not supported in the newer versions of `dnssec-signzone` software. Please install some older version of `dnssec-signzone` (this project was tested with version `9.11.5-P4-5.1+deb10u8-Debian`) and create the following subdomains. You can then update the child and parent nameservers:

- `dsa`: The zone is signed with DSA algorithm 
- `nsec3-iter-200`: `NSEC3` iteration count is set to `200` 
- `rsamd5`: The zone is signed with RSAMD5 algorithm 

The list of created subdomains is stored in `data/misconfigured_subdomains.txt` (updated manually).

### Test Resolvers

The script below will request 4 resolver software installed and 3 public resolvers supporting EDE to resolve all our test domains:

```bash
$ ./scripts/resolver_scan.sh
```

The results are written to `data/resolver_scan/YYYYMMDD/output.json`.

## Domain Scan

The script below runs a large-scale scan of domain names using an EDE-compliant recursive resolver:

```bash
$ ./scripts/domain_scan.sh
```