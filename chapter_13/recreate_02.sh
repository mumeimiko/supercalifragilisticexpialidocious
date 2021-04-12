#!/bin/bash
kubectl delete pods --all
kubectl apply -f config2.yaml
kubectl apply -f test2.yaml
sleep 5
kubectl logs test-pod-2