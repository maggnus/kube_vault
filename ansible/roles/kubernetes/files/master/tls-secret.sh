#!/bin/bash

CERT_HOST=${CERT_HOST:-"localhost"}
CERT_KEY=${KEY_FILE:-"/tmp/tls.key"}
CERT_CRT=${CERT_FILE:-"/tmp/tls.crt"}

KUBE_NAMESPACE=${KUBE_NAMESPACE:-"default"}
CERT_NAME=${CERT_NAME:-"tls-key"}

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${CERT_KEY} -out ${CERT_CRT} -subj "/CN=${CERT_HOST}/O=${CERT_HOST}"

kubectl create secret tls ${CERT_NAME} -n ${KUBE_NAMESPACE} --key ${CERT_KEY} --cert ${CERT_CRT}
