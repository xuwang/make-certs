CWD := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CA_CERT := ca.crt
SITE_CERT := site.crt
CHAIN_CERT := chain.crt
REV_CHAIN_CERT := rev-chain.crt
DHPARAM := dhparam.pem
EMAIL := certs@example.com
OU := IT
DEVDOMAIN := dev.example.com
SVCDOMAIN := service.example.com

all: ca site dhparam $(DEVDOMAIN).cert $(SVCDOMAIN).cert
	chmod 600 *.key

clean:
	rm -f *.pem *.csr *.srl *.key *.crt

ca: | $(CA_CERT)

site: | $(SITE_CERT)


dhparam: | $(DHPARAM)


$(CA_CERT): 
	echo "creating ca.key and ca.crt ..."
	openssl req -x509 -new -nodes -days 9999 -config ca.cnf -out ca.crt
	chmod 600 ca.key

$(SITE_CERT): | $(CA_CERT)
	echo "creating the site-key.pem and site.csr...."
	openssl req -new -out site.csr -config site.cnf
	echo "signing site.csr..."
	openssl x509 -req -days 9999 -in site.csr \
		-CA ca.crt -CAkey ca.key -CAcreateserial \
		-extensions v3_req -out ${SITE_CERT} -extfile site.cnf
	echo "site.pem is generated:"
	openssl x509 -text -noout -in ${SITE_CERT}
	chmod 600 site.key

$(CHAIN_CERT): | $(SITE_CERT)
	echo "creating the chain.pem...."
	cat $(SITE_CERT) $(CA_CERT) > $(CHAIN_CERT)
	cat $(CA_CERT) $(SITE_CERT)> $(REV_CHAIN_CERT)

$(DEVDOMAIN).cert:
	sed "s/OU/$OU/;s/FQDN/${DEVDOMAIN}/g;s/EMAIL/${EMAIL}/" cert.cnf.tmpl > /tmp/cert.cnf
	openssl req -x509 -new -nodes -days 3650 -config /tmp/cert.cnf -out ${DEVDOMAIN}.crt
	chmod 600 ${DEVDOMAIN}.key

$(SVCDOMAIN).cert:
	sed "s/OU/$OU/;s/FQDN/${SVCDOMAIN}/g;s/EMAIL/${EMAIL}/" cert.cnf.tmpl > /tmp/cert.cnf
	openssl req -x509 -new -nodes -days 3650 -config /tmp/cert.cnf -out ${SVCDOMAIN}.crt
	chmod 600 ${SVCDOMAIN}.key
	
$(DHPARAM):
	#see https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
	echo "generating dhparam.pem/2048 for strengthening the server security ..."
	openssl dhparam -out dhparam.pem 2048
	chmod 600 dhparam.pem

help: 
	@echo "make [ all | clean | ca | site ]"

.PHONY: all clean ca site idpproxy-somdev idpproxy-somsvc postfix-somdev postfix-somsvc help
