#!/bin/bash
kubectl delete pods --all
kubectl delete job --all
kubectl delete deployments --all
kubectl run pod1 --image=nginx --labels="Name=webpage,function=frontend,env=prod"
kubectl run pod2 --image=redis --labels="Name=database,function=backend,env=prod"
kubectl run pod3 --image=nginx --labels="Name=webpage,function=frontend,env=stage"
kubectl run pod4 --image=redis --labels="Name=database,function=backend,env=stage"