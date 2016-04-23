# Make Certs for Project proto-2016

* ca.crt - self-signed root ca cert
* site.crt - star cert for all sites
* chain.crt - chain cert for kube ingress
* rev_chain.crt
* dhparam.pem
* idprpxy-somdev.crt - dev certs for idpproxy
* idprpxy-somsvc.crt - prod certs for idpproxy

Note: chain certs is required for kube ingress if the CA is not a common root CA.

## Make Certs

Verify certs specs in all the cnf files, and

````
$ make

````

## To Cleanup

```
$ make clean
```

