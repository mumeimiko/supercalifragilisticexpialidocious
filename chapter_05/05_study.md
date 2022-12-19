# Pre-Req

bash delete.sh

# Labels

Labeling, If you are familiar with AWS, its the same as tagging on resources.

Think of it like this, when you are looking Bugs Bunny, you notice the following parameters:

- Name: Bugs Bunny
- Species: Bunny
- Hair Color: Grey 
- Height: 3'5"

This is essentially what labeling is, its a key:value format for a pod/node/resources. 

For example, if I have a pod that is front end and one is backend, then you would label the following

- pod 1
    - Name: webpage 
    - Function: frontend

- pod 2
    - Name: database
    - Function: backend

Lets create pods with tags

    kubectl run pod1 --image=nginx --labels="Name=webpage,Function=backend"

Lets look at the labels

    kubectl get pods --show-labels
    NAME                    READY   STATUS    RESTARTS   AGE   LABELS
    pod1-5899db9c45-qf4z7   1/1     Running   0          35s   Function=backend,Name=webpage,pod-template-hash=5899db9c45

Lets now create pod 2 from above

    kubectl run pod2 --image=nginx --labels="Name=database,function=backend"

    kubectl get pods --show-labels
    NAME                    READY   STATUS    RESTARTS   AGE     LABELS
    pod1-5899db9c45-qf4z7   1/1     Running   0          3m31s   Function=backend,Name=webpage,pod-template-hash=5899db9c45
    pod2-6d5bc74bcb-nwdbk   1/1     Running   0          23s     Name=database,function=backend,pod-template-hash=6d5bc74bcb

Now understand that when we run "kubectl run" it generally creates a deployment for you.

lets look at the label for the deployments

    kubectl get deployments --show-labels
    NAME   READY   UP-TO-DATE   AVAILABLE   AGE     LABELS
    pod1   1/1     1            1           4m54s   Function=backend,Name=webpage
    pod2   1/1     1            1           106s    Name=database,function=backend

Lets now label a running pod

    kubectl label pod pod1-5899db9c45-qf4z7 env=prod
    kubectl get pods --show-labels
    NAME                    READY   STATUS    RESTARTS   AGE     LABELS
    pod1-5899db9c45-qf4z7   1/1     Running   0          8m22s   Function=backend,Name=webpage,env=prod,pod-template-hash=5899db9c45
    pod2-6d5bc74bcb-nwdbk   1/1     Running   0          5m14s   Name=database,function=backend,pod-template-hash=6d5bc74bcb

Remember, we updated the pod and not the deployment that controls the pod itself. So if I were to delete all pods, I would see that the label I added env=prod will be delete and not recreated for pod1.

    kubectl delete pods pod1-5899db9c45-qf4z7
    kubectl get pods --show-labels
    NAME                    READY   STATUS    RESTARTS   AGE    LABELS
    pod1-5899db9c45-n7ctl   1/1     Running   0          16s    Function=backend,Name=webpage,pod-template-hash=5899db9c45
    pod2-6d5bc74bcb-nwdbk   1/1     Running   0          7m1s   Name=database,function=backend,pod-template-hash=6d5bc74bcb

As you can see, the label is now deleted. 

Now run the following commands:

    bash delete.sh
    bash env_01.sh

Now if I want to see the values of a key in my pods/deployments, such as I want to see the function of my pods I would run the following command:

    kubectl get pods -L function
    NAME                    READY   STATUS    RESTARTS   AGE   FUNCTION
    pod1-84d5f8dc5f-n2tfh   1/1     Running   0          16s   frontend
    pod2-7ddd846ffd-svs2g   1/1     Running   0          15s   backend
    pod3-74599d8b54-xb8pz   1/1     Running   0          15s   frontend
    pod4-6b8c67d9b8-cnn25   1/1     Running   0          15s   backend

Now try looking at env, Name 
    kubectl get pods -L env
    kubectl get pods -L Name

Now what if we only want to see pods in production, then you would use a selector. Remember the -L flag just adds the labels to the get request and doesn't query anything

    kubectl get pods --selector="env=prod"

To assure the labels are correct, add the show labels flag 

    kubectl get pods --selector="env=prod" --show-labels
    NAME                    READY   STATUS    RESTARTS   AGE     LABELS
    pod1-84d5f8dc5f-n2tfh   1/1     Running   0          2m52s   Name=webpage,env=prod,function=frontend,pod-template-hash=84d5f8dc5f
    pod2-7ddd846ffd-svs2g   1/1     Running   0          2m51s   Name=database,env=prod,function=backend,pod-template-hash=7ddd846ffd

NOTE: ALL LABELS, NAMES, SONGS, POKEMON ARE CASE SENSITIVE!!!!!!!!

Lets get more specific, lets try to find pods that are production and are frontend machines 

    kubectl get pods --selector="env=prod,function=frontend" --show-labels
    NAME                    READY   STATUS    RESTARTS   AGE    LABELS
    pod1-84d5f8dc5f-n2tfh   1/1     Running   0          5m8s   Name=webpage,env=prod,function=frontend,pod-template-hash=84d5f8dc5f

As you can see, this was very similar to above when you ran run with multiple labels.

Remember, selector follows operator values:

    - key=value  key is set to value
    - key!=value key is not set to value
    - key in (value1, value2)   key is one of value1 or value2
    - key not in (value1, value2) key is not one of value1 or value2
    - key key is set
    - !key key is not set

Lets see pods not running in production:

    kubectl get pods --selector="env!=prod" --show-labels

# Pods - Manifest Labels 

Now that we played with labels, lets play with manifests!!

Check this one out!

apiVersion: v1
kind: Pod
metadata:
  name: label-demo
  labels:
    env: prod
    tier: frontend
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80

Lets run the manifest:

    bash delete.sh
    kubectl apply -f test1.yaml
    kubectl get pods --show-labels

Now take a look at manifest test2.yaml

When you have a manifest, you don't have to have one pod/resource, you can have multiple in one manifest file.

If you take a look, its the similar environment we saw ealier.

lets run it!

    bash delete.sh
    kubectl apply -f test2.yaml
    kubectl get pods --show-labels

Now do the following:

- Run a command that will list all front end pods
- Run a command that will list all production pods
- Run a command that will list all non-production pods that are front end pods. 

# Labeling Nodes

Labeling

Run the following command:

    kubectl get nodes

So far we have been working with one node, the minikube node. This works fine for what we are doing however, now we need to work with multiple nodes. So run the following command

minikube stop 
minikube start --nodes 3 -p nodes

NOTE: if you are having issues
    - Restart computer
    - run "minikube delete --all"
    - minikube delete -p nodes
    - run "minikube start --nodes 2 -p nodes --disk-size 10000mb --cpus 2 --memory 2gb --driver=docker"

    If that does work do the following:
    - ps aux | grep VBox
    - ps aux | grep minikube
    Find the processes and kill them

    - kill -9 <pid>
    

   minikube start --nodes 2 -p nodes --driver=docker --disk-size 10000mb --cpus 3 --memory 3gb

So after running lets make sure you have some nodes running

    kubectl get nodes 
    NAME        STATUS   ROLES    AGE    VERSION
    nodes       Ready    master   129m   v1.19.4
    nodes-m02   Ready    <none>   127m   v1.19.4

Now lets label two nodes
    kubectl label node nodes env=prod
    kubectl label node nodes-m02  env=stage

Labeling a node is the same as labeling a pod manually, so we can also run a similar command to see the labels of a node:

        kubectl get nodes --show-labels
        NAME        STATUS   ROLES    AGE    VERSION   LABELS
        nodes       Ready    master   139m   v1.19.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,env=prod,kubernetes.io/arch=amd64,kubernetes.io/hostname=nodes,kubernetes.io/os=linux,minikube.k8s.io/commit=23f40a012abb52eff365ff99a709501a61ac5876,minikube.k8s.io/name=nodes,minikube.k8s.io/updated_at=2021_02_19T00_43_28_0700,minikube.k8s.io/version=v1.15.1,node-role.kubernetes.io/master=
        nodes-m02   Ready    <none>   138m   v1.19.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,env=stage,kubernetes.io/arch=amd64,kubernetes.io/hostname=nodes-m02,kubernetes.io/os=linux

        kubectl get nodes -L env
        NAME        STATUS   ROLES    AGE    VERSION   ENV
        nodes       Ready    master   139m   v1.19.4   prod
        nodes-m02   Ready    <none>   137m   v1.19.4   stage

        kubectl get nodes --selector="env=prod"
        NAME    STATUS   ROLES    AGE    VERSION
        nodes   Ready    master   139m   v1.19.4

So why are we labeling?

We label the nodes so we can label as we see fit for our environments and also have the ability to declare which pods can land on which node. 

For example we have two nodes, node node-m02. mo2 is a newly launched machine and we want to run our staging environment in this new machine to see if its able to handle the production load as in our node n our prod node. 

So instead of running staging pods and productions pods on one node, we can declare within the pod/deployment manifest where these pods can land on. 

So in this example we want to launch pods in their dedicated environments. 

Remember the format from earlier?

apiVersion: v1
kind: Pod
metadata:
  name: pod1
  labels:
    env: prod
    tier: frontend
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80

Under Spec, we are going to add a nodeSelector, in this case we will need to add the field to file test3.yaml, so each pod would be associated with their respected environment for example:

apiVersion: v1
kind: Pod
metadata:
  name: pod1
  labels:
    env: prod
    tier: frontend
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
  nodeSelector:
    env: prod

Edit file test3.yaml to include this nodeSelector and match the pods with nodes based on the env variable.

NOTE: Yaml is very sensitive to tabs and spaces. Remember each indent is two spaces. So for example, the above pod manifest has the following spaces:

spec: # 0 Spaces
##containers: #2 Spaces 
##- name: nginx
####image: nginx:1.14.2 # 4 Spaces
####ports:
####- containerPort: 80
##nodeSelector: # 2 spaces
####env: prod # 4 Spaces

Once the file has been edited, run the following command:

    kubectl apply -f test3.yaml
    kubectl get pods -o wide
    NAME   READY   STATUS              RESTARTS   AGE   IP       NODE        NOMINATED NODE   READINESS GATES
    pod1   0/1     ContainerCreating   0          13s   <none>   nodes       <none>           <none>
    pod2   0/1     ContainerCreating   0          13s   <none>   nodes       <none>           <none>
    pod3   0/1     ContainerCreating   0          13s   <none>   nodes-m02   <none>           <none>
    pod4   0/1     ContainerCreating   0          13s   <none>   nodes-m02   <none>           <none>

As you can see above, the pods for production landed on Nodes nodes and staging landed on nodes-m02 

NOTE: if you had issues creating the file, please take alook at the test99.yaml file 

Annotations VS Labels

Im bringing this up as both act the same but are meant for two different things. 

With labels, this is a method in which kubernetes itself can identify with its own resources. For example we said to launch pods in nodes with labels env=prod. This is a label.

However, annotations, is when you want to add key=value pair to a resources in which is not used by kubernetes but used outside of kubernetes, such as python script reading the file manifests of a running deployment. 




