#!/bin/bash

CERT_PATH=/usr/share/taskd/pki

function die {
    echo "$@" >&2
    exit 1
}

if [ ! -f $TASKDDATA/ca.cert.pem ]; then
    echo -e "First time setup\n================"

    taskd init || die "Failed to init taskd"
    taskd config --force log $TASKDDATA/taskd.log
    taskd config --force pid.file /tmp/taskd.pid

    echo -e "Generating CA and server certificates\n====================================="
    echo -e "BITS=4096
EXPIRATION_DAYS=${CERT_EXPIRATION:-365}
ORGANIZATION=\"${CERT_ORGANIZATION:-Organization}\"
CN=${CERT_CN:-localhost}
COUNTRY=${CERT_COUNTRY:-SE}
STATE=\"${CERT_STATE:-Västra Götaland}\"
LOCALITY=\"${CERT_LOCALITY:-Göteborg}\"" > $CERT_PATH/vars

    cd $CERT_PATH
    ./generate || die "Failed to generate CA and server certificates"
    cp client.cert.pem $TASKDDATA
    cp client.key.pem  $TASKDDATA
    cp server.cert.pem $TASKDDATA
    cp server.key.pem  $TASKDDATA
    cp server.crl.pem  $TASKDDATA
    cp ca.cert.pem     $TASKDDATA
    cp ca.key.pem     $TASKDDATA

    cd $TASKDDATA
    taskd config --force client.cert $TASKDDATA/client.cert.pem
    taskd config --force client.key $TASKDDATA/client.key.pem
    taskd config --force server.cert $TASKDDATA/server.cert.pem
    taskd config --force server.key $TASKDDATA/server.key.pem
    taskd config --force server.crl $TASKDDATA/server.crl.pem
    taskd config --force ca.cert $TASKDDATA/ca.cert.pem

    echo -e "First time setup done\n====================="
fi

echo "Updating server address"
taskd config --force server ${SERVER:-localhost}:${PORT:-53589}

echo "Running $@"
exec tini -- $@
