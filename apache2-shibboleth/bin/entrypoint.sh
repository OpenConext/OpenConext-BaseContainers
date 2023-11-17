#!/bin/sh
envsubst </etc/shibboleth/shibboleth2.xml.dist >/etc/shibboleth/shibboleth2.xml
envsubst </etc/shibboleth/localLogout.html.dist >/etc/shibboleth/localLogout.html
"$@"
