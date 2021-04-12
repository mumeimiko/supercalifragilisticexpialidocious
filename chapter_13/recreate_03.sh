#!/bin/bash
kubectl delete pods --all
kubectl delete configmaps --all 
kubectl create configmap countrymusic --from-file=config3.txt
kubectl apply -f test3.yaml
sleep 5
kubectl logs test-pod-3