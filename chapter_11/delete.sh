#!/bin/bash 
kubectl delete pods --all
kubectl delete job --all
kubectl delete deployments --all
kubectl delete replicasets --all
#kubectl run -it --generator=run-pod/v1 testunit --image=amazonlinux -- sh 
