#!/bin/bash
printf "Please select service to deploy on k8s:\n"
select d in */; do
    test -n "$d" && break
    echo ">>> Invalid Selection"
done
if [ ${d%/} == 'fluent-bit' ]; then
    exit 1
fi
if [ -e $d/Dockerfile ]; then
    helm uninstall nestjs-microservices 
    helm install nestjs-microservices helm --values helm/${d%/}-values.yaml 
    export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services nestjs-microservices)
    export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
    echo "Microservice is deployed at " http://$NODE_IP:$NODE_PORT/
fi
