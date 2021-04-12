#!/bin/bash
kubectl delete pods --all
kubectl apply -f test5.yaml
sleep 5
kubectl logs test-pod-5