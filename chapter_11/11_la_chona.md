# Song of the day 

True Survivor - Kung Fury

# Pre-Req

bash delele.sh

# Don't look now I just took flight

A DaemonSet ensures that all (or some) Nodes run a copy of a Pod. As nodes are added to the cluster, Pods are added to them. As nodes are removed from the cluster, those Pods are garbage collected. Deleting a DaemonSet will clean up the Pods it created.

tl:dr a pod you always want running on any node that launches. For example a log collector.

By default, daemonset will create a pod in everynode unless otherwise stated in node selector. These pods are ignored by the kubernetes scheduler.

In file test1.yaml, this is running a fluentd, which collects logs for such things as elastisearch and such. 

so go ahead and run the manifest. 

Now check kubectl get pods.

TIP: your not gonna see it, unless you know the way........

Use the force.... or just add -A to kubectl get pods

As mentioned earlier, the pods are going to launch on all the nodes 

fluentd-elasticsearch-49m8l        1/1     Running   0          95s   172.17.0.2     minikube-m02   <none>           <none>
fluentd-elasticsearch-vtsr9        1/1     Running   0          95s   172.17.0.3     minikube       <none>           <none>

As far as the node selector, thats kinda already known in previous chapters. 

What are daemonsets used in all kubernetes clusters?

kubectl get ds -A

# Initcontainers In it to quit it


When a pod is first created, the first container to be created is the initcontainer. Now when you don't include this initcontainer, it skips this and coes to containers. So for example, you need to assure that the database is up and running, you would run a initcontainer that would assure that you are able to reach the database by running a command. When that command is complete and there are no errors, the other containers will run.

For example, in the manifest below, we run a quick nslookup for amazon.com. When the conatiner is able to look up the dns name, nginx will then run


apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  initContainers:
  - name: busybox
    image: busybox
    imagePullPolicy: IfNotPresent
    command: ['sh', '-c', 'until nslookup amazon.com; do echo waiting for amazon.com; sleep 2; done;']
