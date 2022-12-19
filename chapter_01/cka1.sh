#!/bin/bash
kubectl run nginx --image=nginx:latest > /dev/null 2>&1
kubectl apply -f test1.yaml > /dev/null 2>&1
