#!/bin/bash
kubectl delete pods --all
kubectl delete configmaps --all 
kubectl apply -f config4.yaml 
kubectl apply -f test4.yaml
sleep 5
kubectl logs test-pod-4