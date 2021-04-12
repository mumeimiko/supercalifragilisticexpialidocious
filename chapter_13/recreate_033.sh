#!/bin/bash
kubectl delete pods --all
kubectl delete configmaps --all 
kubectl create configmap countrymusic --from-env-file config33.txt
kubectl apply -f test33.yaml
sleep 5
kubectl logs test-pod-33