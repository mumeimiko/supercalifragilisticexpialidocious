#!/bin/bash 
kubectl delete pods --all
kubectl delete job --all
kubectl delete deployments --all
kubectl delete services example-service