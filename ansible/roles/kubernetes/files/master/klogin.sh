#!/bin/bash

kubectl exec -it -n `kubectl get pods --all-namespaces | grep vault-vault | head -1 | awk '{print $1" "$2}'` sh