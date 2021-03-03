# Song of the day 
Tron Legacy (End Titles) - Daft Punk

# Pre-Req

bash delete.sh

# Replica Sets

A ReplicaSet's purpose is to maintain a stable set of replica Pods running at any given time. As such, it is often used to guarantee the availability of a specified number of identical Pods

Run the following command

    kubectl apply -f test1.yaml

    kubectl get pods

Yay!!!!!!!! we ran some pods.......... ok........ So whats up Doc?

Well we have seen deployment very often in the previous chapters and also saw manifests like test1.yaml. However did you notice the the following between a pod manifest and a deployment manifest?

- Deployment (File: test1.yaml)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server-1
spec:
  selector:
    matchLabels:
      tier: frontend
  replicas: 3
... (truncated)
    spec:
      containers:
      - name: web-app
        image: nginx:1.16-alpine
       
- Pod (test2.yaml)
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx

When you are creating a pod with a pod manifest(or run), you are creating ONE pod. thats it nothing more.

However with a deployment you are setting a replicaset in which it states how many pods to run. As you can see above where it says replicas, this is how many pods you want to run. 

Deployment is an object which can own ReplicaSets and update them and their Pods via declarative, server-side rolling updates. While ReplicaSets can be used independently, today they're mainly used by Deployments as a mechanism to orchestrate Pod creation, deletion and updates. When you use Deployments you don't have to worry about managing the ReplicaSets that they create. Deployments own and manage their ReplicaSets. As such, it is recommended to use Deployments when you want ReplicaSets.

Lets take another look at the pods

Notice that the naming convention is a bit different than when you are running a single pod?

    kubectl get pods
    NAME                           READY   STATUS    RESTARTS   AGE
    web-server-1-5d49f66f6-kd746   1/1     Running   0          12s
    web-server-1-5d49f66f6-ssc2x   1/1     Running   0          12s
    web-server-1-5d49f66f6-wcddd   1/1     Running   0          12s

    Name: web-server-1
    ReplicaSet: web-server-1-5d49f66f6
    Pods Uniqueness: kd746 

Run the following command:

- kubectl get deployments web-server-1 -o json | grep ReplicaSet
    - "message": "ReplicaSet \"web-server-1-5d49f66f6\" has successfully progressed.",

- kubectl describe deployments web-server
    - NewReplicaSet:   web-server-1-5d49f66f6 (3/3 replicas created)

So as you can see a deployment creates a replicaset for you. Lets take a look at it

    kubectl get replicaset 
    NAME                     DESIRED   CURRENT   READY   AGE
    web-server-1-5d49f66f6   3         3         3       6m45s

When running a describe on the replicaset you can see the events for creation of the pods:

    Events:
    Type    Reason            Age   From                   Message
    ----    ------            ----  ----                   -------
    Normal  SuccessfulCreate  11m   replicaset-controller  Created pod: web-server-1-5d49f66f6-ssc2x
    Normal  SuccessfulCreate  11m   replicaset-controller  Created pod: web-server-1-5d49f66f6-kd746
    Normal  SuccessfulCreate  11m   replicaset-controller  Created pod: web-server-1-5d49f66f6-wcddd

Let's take a look at a replica manifest, take a look at test1.yaml. Hmmm the file you pointed to is a deployment file and not a replica file..... Take a look at test3.yaml

If you compare both test1.yaml and test3.yaml, this would be the only difference:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server-1

apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: web-server-2

This is because replicaset is similar to deployment manifests, except for kind, which is the kind of deployment you are declaring in the manifest. 

NOTE: I know this hasn't been mentioned but kind reflects the resource you are trying to create. 

So lets run test3.yaml

kubectl apply -f test3.yaml

You should now see

    - 3 new pods launched with web-server-2
        - notice it doesnt have a "middle" compared to the deployment replicaset
    - a deployment was not used
    - there are now 2 replicasets 

What if you want to scale up the replicas?

you can run kubectl scale replicasets web-server-2 --replicas=4

    kubectl get rs
    NAME                     DESIRED   CURRENT   READY   AGE
    web-server-1-5d49f66f6   3         3         3       5h30m
    web-server-2             3         3         3       5h7m

    kubectl scale replicasets web-server-2 --replicas=4
    replicaset.apps/web-server-2 scaled

    kubectl get rs
    NAME                     DESIRED   CURRENT   READY   AGE
    web-server-1-5d49f66f6   3         3         3       5h30m
    web-server-2             4         4         4       5h7m


Takeaways 


Exercises

# Excersise 1

Create a pod and then have it join replicaset 
