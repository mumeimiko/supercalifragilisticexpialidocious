
# Pre-Req

bash delete.sh

# Buzz buzz buzz buzz- To affinity and beyond


Node Affinity/Anti-Affinity is one way to set rules on which nodes are selected by the scheduler. This feature is a generalization of the nodeSelector feature which has been in Kubernetes since version 1.0. 

Required rules must be met for a pod to schedule on a particular node. If no node matches the criteria (plus all of the other normal criteria, such as having enough free resources for the pod’s resource request), then the pod won’t be scheduled. Required rules are specified in the requiredDuringSchedulingIgnoredDuringExecution field of nodeAffinity.

Let's assure before we begin that the nodes are properly labeled:

        kubectl get nodes -L env
        NAME           STATUS   ROLES    AGE     VERSION   ENV
        minikube       Ready    master   9m27s   v1.19.4   
        minikube-m02   Ready    <none>   6m13s   v1.19.4   

They are not...... so lets set a environmental label for each one

    kubectl label node minikube   env=prod
    kubectl label node minikube-m02  env=stage
    kubectl get nodes -L env
        NAME           STATUS   ROLES    AGE     VERSION   ENV
        minikube       Ready    master   9m27s   v1.19.4   prod
        minikube-m02   Ready    <none>   6m13s   v1.19.4   stage


# To affinity and beyond!!!

Node affinity is conceptually similar to nodeSelector -- it allows you to constrain which nodes your pod is eligible to be scheduled on, based on labels on the node.

There are currently two types of node affinity, called 

    - requiredDuringSchedulingIgnoredDuringExecution
    - preferredDuringSchedulingIgnoredDuringExecution

So how would you use these affinity?

- requiredDuringSchedulingIgnoredDuringExecution
    - ONLY to run the pod on nodes in the production environment. So for example my env=prod pods will only land on the minikube node if its available. If the scheduler is not able to launch a pod in the minikube node, it will not be able to launch the pod on the minikube node. AKA Hard Requirement

preferredDuringSchedulingIgnoredDuringExecution
    - TRY to run the pod on nodes in the production environment, if not you can run in staging. So if the scheduler determines that the pod is not able to land on the minikube node, it would then try another node, in this case minikube-m02. AKA Soft Requirement

      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: env
            operator: In
            values:
            - prod

      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: end
            operator: In
            values:
            - stage

Notice the following

requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:

preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    preference:

If you are missing the properties you will get the following error:

error: error validating "test1.yaml": error validating data: ValidationError(Pod.spec.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution): invalid type for io.k8s.api.core.v1.NodeAffinity.preferredDuringSchedulingIgnoredDuringExecution: got "map", expected "array"; if you choose to ignore these errors, turn validation off with --validate=false

Lets take a look at a manifest:

apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: env
            operator: In
            values:
            - prod
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: env
            operator: In
            values:
            - stage
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0

So in the manifest above, 

    - The scheduler will first try to launch on a node with env=prod label. 
    - The scheduler will to launch on a node with env=stage

Hmmmmm so which affinity is used.......

Run the following command:

    kubectl apply -f test1.yaml

Which pod did the node land in?

    kubectl get pods -o wide 

You should see that the pod landed in minikube  and not in minikube-m02.

Lets take a look at test2.yaml:

spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: end
            operator: In
            values:
            - prod
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: env
            operator: In
            values:
            - stage

Based on the above, the first affinity is mispelled and the second affinity is set properly. It should work right? 

Run the following command:

    kubectl apply -f test2.yaml
    kubectl get pods -o wide

Check the events for pod with-node-affinity-2, What do you see??

The events should be self explanitory

Now take a look at test3.yaml, the values are mispelled on purpose, however since we are using "preferred", it would still schedule the pod to launch on a node regardless of the mispelled values.

    kubectl apply -f test3.yaml

    - Did the pod launch?
    - Whats the status of the pod?
    - Is there a node the pod landed on?

Question: Is the following able to be used?

spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: env
            operator: In
            values:
            - prod
            - stage

Yes!!!!!! It would first try to find the first value, if not it would try the second value.

Try the following

    - Run test4.yaml as is.
    - Edit the file and mispell prod and run again. Where does the pod land on?
    - Edit the file and mispell stage and fix prod and run again. Where does the pod land on?

# Anti-Affinity

So heres something to think about. Volcanoes, they look nice from afar but do you ever want to go inside one while its erupting? I wouldn't. How about diving a shark infested waters? There are places some of us would like to go see, however there are places that we know we don't want to see due to fears or trying to stay alive. This feeling of willing to go anywhere EXCEPT for certain places is similar to anti-affinity. These are places you don't want your pods to land on.

For example, if you are spinning up pods for a deployment, would you want them to land on mission critical nodes for the company?

I wouldn't but I would like the deployment to land on any nodes that are NOT associated with mission critical nodes. 

This is were anti-affinity comes into play. I want my pods to land on nodes that are NOT production. 

So it would look like this:

apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity-4
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: env
            operator: NotIn
            values:
            - prod
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0


OR


apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity-4
spec:
  affinity:
    nodeAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: env
            operator: n
            values:
            - prod
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0

As seen above, the pods I will launch, will not launch on pods labeled env=prod or in operational values env!=prod.

Run the following command:

    kubectl apply -f test5.yaml

Time to TROUBLESHOOT!!!!!!

See why its not working, you should have the pod landing in a non-prod node.

# Excersise 1 - Launching pods with affinity

Now, take a look at test6.yaml. Add affinity to the pods and make sure that pods land in their respective nodes, such as env=prod pods land in production nodes and staging pods land on staging pods 

# Exercise 2 - Random PODS!!!!!

After so, I want you to launch 3 pods with the following images:

    - httpd
    - amazonlinux
    - busybox

I want them to use the preferredDuringSchedulingIgnoredDuringExecution affinity.

Feel free to use whatever method, just make sure you include this affinity.

# Pod Affinity

As with node affinity, there are currently two types of pod affinity and anti-affinity, called requiredDuringSchedulingIgnoredDuringExecution and preferredDuringSchedulingIgnoredDuringExecution which denote "hard" vs. "soft" requirements

An example of requiredDuringSchedulingIgnoredDuringExecution affinity would be "co-locate the pods of service A and service B in the same zone, since they communicate a lot with each other"
 
An example preferredDuringSchedulingIgnoredDuringExecution anti-affinity would be "spread the pods from this service across zones" (a hard requirement wouldn't make sense, since you probably have more pods than zones).

Pods affinity is a bit confusing im not gonna lie but you have to think of it like this:

You won the lottery and you have to move out of state and you have to bring your family members families. You are going to buy a house, however you have to think about the placement of the families. 
  - Do you want all the families in under one roof? 
  - Do you want the families to have their own house? 
  - how about all the families have their own house in the same street? 
  - Do you want your crazy auntie living in the same house as her nephew who just critized her potato salad with raisins? I wouldn't

Pod affinity is the same, you know you want launch front end facing web pages, but do they all need to be on the same node? Same as databases, do you really need all the data bases in one node? 

This is where pod affinity comes into play.

# Antiaffinity

Anti-affinity rules allow you to prevent pods of a particular service from scheduling on the same nodes as pods of another service that are known to interfere with the performance of the pods of the first service. Or, you could spread the pods of a service across nodes or availability zones to reduce correlated failures.

 affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - store
            topologyKey: "kubernetes.io/hostname"

Using the above in a deployment indicates that, "This pod will launch in a node with label "kubernetes.io/hostname" and will look for pods with app=store. If there is no pods with app=store, I will launch this pod on a node

# Affinity 

Using affinity rules, you could spread or pack pods within a service or relative to pods in other services. The pod is not scheduled unless there is a node with a pod that has the app:webs-store label. If there is no other pod with that label, the new pod remains in a pending state.

      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - web-store
            topologyKey: "kubernetes.io/hostname"


# Over all Picture

Think of it like this, 

A database doesn't need a webpage to run. It can run without a front end webpage, however the database needs to run on each node. So in this case, you would use anti-affinity to launch a data base on each node since antiaffinity doesn't allow multiple databases to land on nodes, 

Now a webpage usually needs a database to help run so this is when you would use affinity to search for pods with a specific key, such has tier=backend. You would use affinity requiredDuringSchedulingIgnoredDuringExecution to assure that there is a database running with key:value of tier:backend since the webpage needs a database running on a node prior to the pod launching. 

However since can have multiple webpages running on multiple nodes, you don't nescessarly need to use anti-affinity since you want to run multiple pods on multiple nodes.

# Excersise:

Create the following environment:

    - Launch 4 webpage servers on multiple nodes
    - Launch 2 database servers on each node.

Key Takeaways 

- Affinity is a great way to manage pods on nodes 
- There are two affinities used:
    - requiredDuringSchedulingIgnoredDuringExecution
        - Hard limit must be done or else it wont work
    - preferredDuringSchedulingIgnoredDuringExecution
        - EH try to follow the rules if not its fine
- Node affinity is the placement of nodes based on the node labels
- Pod Affinity is the placement of pods based on other pods in the nodes. 


# Taints and Tolerations

Taints = Node AKA House
Toleration = Pods AKA Person

Lets now get you more confused.........

Lets look at the following:

   +--------+   +--------+    +--------+    +----------+  +----------+
   | Kim    |   |  Javi  |    | Jon    |    | BadBunny |  |  Miko    |
   | Orange |   |  Blue  |    | Orange |    | N/A      |  |  Blue    |
   +--------+   +--------+    +--------+    +----------+  |  Orange  |
                                                          +----------+

      XXXXXX                   XXXXXX                XXXXXX
    XXXXXXXXXX               XXXXXXXXXX            XXXXXXXXXX
  XXXXXXXXXXXXXX           XXXXXXXXXXXXXX        XXXXXXXXXXXXXX
 XXXXXXXXXXXXXXXXX        XXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXX
|   Mikos House   |      |   Kims House   |     |  Trap House  |
|                 |      |                |     |              |
|   Key=Blue      |      |   Key=Orange   |     |    No Key    |
+-----------------+      +----------------+     +--------------+

Now in the above example the only people who can access Mikos house is Miko and Javi. The only people that can have access to Kims house is Kim, Jon, and Mike. However when we look at the trap house, everyone is allowed to access the house.

Going back to kubernetes, if a node has a taint, only pods that have the toleration are allowed to run on that node.

For example, the pods with the blue key can land on mikos house, and the pods with the orange key can land on kims house. 

However What happens to those that do not have a toleration declared? They will land on the next available node that does not have a taint, for example the trap house allows all pods to land on it. 

Lets look at the following;

+--------+   +--------+    +--------+    +----------+  +----------+
| Kim    |   |  Javi  |    | Jon    |    | BadBunny |  |  Miko    |
| Orange |   |  Blue  |    | Orange |    | N/A      |  |  Blue    |
+--------+   +--------+    +--------+    +----------+  |  Orange  |
                                                       +----------+

               XXXXXX                     XXXXXX
             XXXXXXXXXX                 XXXXXXXXXX
           XXXXXXXXXXXXXX             XXXXXXXXXXXXXX
          XXXXXXXXXXXXXXXXX          XXXXXXXXXXXXXXXXX
         XXXXXXXXXXXXXXXXXXX        XXXXXXXXXXXXXXXXXXX
         |   Mikos House   |         |  Trap House  |
         |                 |         |              |
         |   Key=Blue      |         |    No Key    |
         +-----------------+         +--------------+


If the pods were to be deployed where would they land?

First the pods with the blue toleration will land on mikos house

Mikos House = Javi, Miko

At this point when pods Kim and Jon are launched, since they don't have the right toleration for Mikos House, they will land in the trap house along with BadBunny.

Trap House = Kim, Jon, BadBunny 


You add a taint to a node using kubectl taint. For example,

kubectl taint nodes node1 key1=blue:NoSchedule

This places a taint on node node1. The taint has key key1, value blue, and taint effect NoSchedule. This means that no pod will be able to schedule onto node1 unless it has a matching toleration. 

Now there are multiple taint effects such as:

- NoSchedule - Pods will not be scheduled on the node
- PreferNoSchedule - system would try to prevent a pod to land on the node 
- NoExecute - All the pods on the node will be eliminated unless they have a toleration associated with the taint. 

So if we tainted the node1, we would declare the following for the pod.

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
  tolerations:
  - key: "key1"
    operator: "Equal"
    value: "blue"
    effect: "NoSchedule"


# LimitRange

This would set the limit default for all pods in the namespace


    apiVersion: v1
    kind: LimitRange
    metadata:
      name: mem-limit-range
    spec:
      limits:
      - default:
          memory: 512Mi
        defaultRequest:
          memory: 256Mi
        type: Container



At the moment I only allow my family into my house. We have a blue key that would allow you into my house. 


- References 
https://docs.openshift.com/container-platform/3.6/admin_guide/scheduling/pod_affinity.html
https://docs.okd.io/latest/nodes/scheduling/nodes-scheduler-pod-affinity.html
https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/