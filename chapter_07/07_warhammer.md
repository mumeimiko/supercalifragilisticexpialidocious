# song of the day 
Porcelain - Moby

# Chapter 7

# Pre-Req

bash delete.sh

# Extreme Ways 

Service is an abstraction which defines a logical set of Pods and a policy by which to access them (sometimes this pattern is called a micro-service). The set of Pods targeted by a Service is usually determined by a selector.

For example, consider a stateless image-processing backend which is running with 3 replicas. Those replicas are fungible—frontends do not care which backend they use. While the actual Pods that compose the backend set may change, the frontend clients should not need to be aware of that, nor should they need to keep track of the set of backends themselves.

The Service abstraction enables this decoupling.

So has we previously saw, we have front end web pages, which we can bundle up under a service. 

Confused yet? Lets try this, lets look at the manifest for a service:

apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    tier: frontend
  ports:
    - protocol: TCP
      port: 8888
      targetPort: 80

This specification creates a new Service object named "my-service", which targets TCP port 80 on any Pod with the tier=frontend label.

Kubernetes assigns this Service an IP address (sometimes called the "cluster IP"), which is used by the Service proxies

Lets try the following:

    bash delete.sh
    kubectl apply -f test1.yaml
    kubectl apply -f test2.yaml 

Now lets take a look at the service we created:

    kubectl get services 
    NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP    11h
    my-service   ClusterIP   10.103.199.76   <none>        8888/TCP   7m48s

The service was created and given an IP address, lets further look into the service:

    kubectl describe svc my-service
    Name:              my-service
    Namespace:         default
    Labels:            <none>
    Annotations:       kubectl.kubernetes.io/last-applied-configuration:
                        {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"name":"my-service","namespace":"default"},"spec":{"ports":[{"port":8888,...
    Selector:          tier=frontend
    Type:              ClusterIP
    IP:                10.103.199.76
    Port:              <unset>  8888/TCP
    TargetPort:        80/TCP
    Endpoints:         172.17.0.2:80,172.17.0.3:80
    Session Affinity:  None
    Events:            <none>

Hmmm notice the endpoints.... run a kubectl get pods -o wide, notice something? The service is pointing to the web-server pods. 

So lets try the following:

    kubectl run -i --tty aznlnx --image=amazonlinux -- sh 

You should now be inside a pod within the cluster. Now run the following curl command agaisn't one of the endpoints:

    curl 172.17.0.2
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style> .(truncated)</style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.</p>
    (truncated)
    </body>
    </html>

    or run the following:

    curl -IkL 172.17.0.2
    HTTP/1.1 200 OK
    Server: nginx/1.16.1

Now lets run it agaisnt the service, but remember that the service uses port 8888. 

    curl 10.103.199.76:8888

    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style> .(truncated)</style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.</p>
    (truncated)
    </body>
    </html>

The service was able to redirect the traffic to one of the pods as its suppose to do. 

Now lets try the folllowing:

# Exercise 

Update file test1.yaml and edit replica from 2 to 6 and run kubectl apply. Once its deployed check the service. Run kubectl describe svc my-service.

Does the endpoints increase or decrease or stay the same?


==================
==================

It should have increased. As you can tell these changes are quickly picked up by the service as the it constantly looks for pods with the tag tier=frontend, and since the pods we just launched has the tags, they are included in the service as seen below:

    kubectl get pods --selector="tier=frontend" -L tier -o wide
    NAME                          READY   STATUS    RESTARTS   AGE   IP           NODE           TIER
    web-server-85df7c4585-22fgc   1/1     Running   0          25m   172.17.0.4   minikube       frontend
    web-server-85df7c4585-2nt7p   1/1     Running   0          26m   172.17.0.3   minikube       frontend
    web-server-85df7c4585-fqjbj   1/1     Running   0          25m   172.17.0.3   minikube-m02   frontend
    web-server-85df7c4585-j7wch   1/1     Running   0          23m   172.17.0.4   minikube-m02   frontend
    web-server-85df7c4585-mnlz5   1/1     Running   0          26m   172.17.0.2   minikube-m02   frontend
    web-server-85df7c4585-pbths   1/1     Running   0          23m   172.17.0.5   minikube-m02   frontend

    kubectl get endpoints my-service # take a look at the endpoints for the service
     
    NAME         ENDPOINTS                                               AGE
    my-service   172.17.0.2:80,172.17.0.3:80,172.17.0.3:80 + 3 more...   5h42m

Hmmm it says theres a couple of endpoints but we cannnot see them.......

So run this custom command:

    kubectl get endpoints my-service -o=jsonpath='{.subsets[*].addresses[*].ip}' && echo ""

    72.17.0.2 172.17.0.3 172.17.0.3 172.17.0.4 172.17.0.4 172.17.0.5

or you can run a describe on the endpoints:

    kubectl describe endpoints my-service

    Addresses:          172.17.0.3,172.17.0.4,172.17.0.5,172.17.0.5,172.17.0.6,172.17.0.7


We can now see the 3+ ip addresses

Lets now exec into a pod and run a nslookup on the service name:

Note: the ip address was 10.103.199.76

    kubectl exec -it web-server-85df7c4585-22fgc -- sh
    nslookup my-service:

Whats the result:

    / # nslookup my-service
    nslookup: can't resolve '(null)': Name does not resolve

    Name:      my-service
    Address 1: 10.103.199.76 my-service.default.svc.cluster.local


Remember Kubernetes provides a DNS service exposed to Pods running in the cluster, which exposes the service. 

tl:dr

my-service.default.svc.cluster.local

    - my-service
        Name of the service
    - default
        Namespace the service is in
    - svc
        Recognises that this is a service
    - cluster.local
        Cluster domain name for the cluster. 

# Readiness probe 

readinessProbe: Indicates whether the container is ready to respond to requests. If the readiness probe fails, the endpoints controller removes the Pod's IP address from the endpoints of all Services that match the Pod. The default state of readiness before the initial delay is Failure. If a Container does not provide a readiness probe, the default state is Success.

Lets look at the properties

    readinessProbe:
      tcpSocket:
        port: 8080 
      initialDelaySeconds: 5
      periodSeconds: 10

or 

    readinessProbe:
      httpGet:
        path: /ready # Path to check 
        port: 8080 # Power to check
      periodSeconds: 2  # This check is done every 2 seconds as soon as the pod it up and running
      initialDelaySeconds: 0 # 0 seconds to wait to start checking the pod
      failureThreshold: 3 # if three checks fail in a row, then the pod is considered not ready
      successThreshold: 1 # if only one check passes, the pod is ready

tl:dr when the pod starts, the service will take a look at the pod and reach the path/port declared and if everything is good it passes its initial health check. 


Run the following command:

    bash delete.sh
    kubectl apply -f test3.yaml

You should see the following:

    kubectl get pods -w
    NAME                            READY   STATUS    RESTARTS   AGE
    web-server-2-54cf49967f-48hcz   0/1     Running   0          8s
    web-server-2-54cf49967f-gpqm8   0/1     Running   0          8s
    web-server-2-54cf49967f-mbnts   0/1     Running   0          8s
    web-server-2-54cf49967f-pr8mq   0/1     Running   0          8s
    web-server-2-54cf49967f-sj4ld   0/1     Running   0          8s
    web-server-2-54cf49967f-znm5m   0/1     Running   0          8s

Notice none are in a ready state?

If you take a look at the file test3.yaml, you can see that readinessProbe is set to port 8080, however nginx runs on port 80

NOTE: When you are running the -w flag, you are seeing statuses in real time

Now if you were to change the readiness probe to port 80 instead of 8080 what do you see?

Execesise:

Edit the file and change port 8080 to 80 and change the period seconds to 5

You should now see the pods go from 0/1 in ready to 1/1 meaning their are ready.

    web-server-2-58bf4cccc6-2v264   0/1     Running             0          4s
    web-server-2-58bf4cccc6-ntqv9   0/1     Running             0          5s
    web-server-2-58bf4cccc6-kqmx6   0/1     Running             0          5s
    web-server-2-58bf4cccc6-gp5zc   0/1     Running             0          5s
    web-server-2-58bf4cccc6-kjf4w   1/1     Running             0          7s
    web-server-2-58bf4cccc6-ntqv9   1/1     Running             0          9s
    web-server-2-58bf4cccc6-5b7pv   1/1     Running             0          9s
    web-server-2-58bf4cccc6-kqmx6   1/1     Running             0          10s
    web-server-2-58bf4cccc6-gp5zc   1/1     Running             0          10s
    web-server-2-58bf4cccc6-2v264   1/1     Running             0          12s

However after awhile you will see the following:

    web-server-2-58bf4cccc6-5b7pv   0/1     Running             1          47s
    web-server-2-58bf4cccc6-ntqv9   0/1     Running             1          49s
    web-server-2-58bf4cccc6-gp5zc   0/1     Running             1          50s
    web-server-2-58bf4cccc6-2v264   0/1     Running             1          50s
    web-server-2-58bf4cccc6-kjf4w   0/1     Running             1          51s
    web-server-2-58bf4cccc6-kqmx6   0/1     Running             1          53s

The pods became unready but then you see the pods becoming ready........ This is a endlessss loop. 

At the moment the following is occuring

    - readinessProbe
        - At the moment the pods are passing their readiness probe which is why we see the 1/1 under ready. 
    - livenessProbe
        - After the pods pass their readiness probe, the next probe is the livenessProbe test. This is where its currently failing!

# Liveness probe

The kubelet uses liveness probes to know when to restart a container. For example, liveness probes could catch a deadlock, where an application is running, but unable to make progress. Restarting a container in such a state can help to make the application more available despite bugs.

TL:DR 

Liveness probe is basically checking if the pod is in working order after passing its health check. If the nginx application crashes, it shoudl then fail its liveness check and thus the kubelet would detect the pod is bad and replace it with a pod.

This is whats current occuring. 

## exercise 

So in file test4.yaml, edit the mistake in livenessProbe

You should now see the following:

    kubectl get pods -w
    NAME                           READY   STATUS    RESTARTS   AGE
    web-server-2-5d49f66f6-28wh9   1/1     Running   0          29s
    web-server-2-5d49f66f6-8c2lr   1/1     Running   0          20s
    web-server-2-5d49f66f6-fmhnl   1/1     Running   0          18s
    web-server-2-5d49f66f6-ss7mg   1/1     Running   0          29s
    web-server-2-5d49f66f6-tmdm7   1/1     Running   0          29s
    web-server-2-5d49f66f6-x69vk   1/1     Running   0          21s

Pods are passing their readiness test and the liveness test.

# Advanced 

You can also do the following liveness checks on your pods:

    - Command based
    - HTTP path check

Command based is exactly what you think, a command is ran within the pod. if the command is ran and is not able to be successful, it would fail its liveness check

Check file test6.yaml for the example.

Http based is just like it sounds, where the service will check the path declared along with header options. Please check file test7.yaml for additional information on this


# SErvice Node port


Nodeport Range 30000-32767

As i mentioned earlier, with services we can use a central cluster ip address that services can communicate traffic to, but what it you want to access the webpage outside of the cluster?

See earlier when we were testing, we had to access to pod1 and basically curl the service ip address which redirected traffic to pod2.

 +------------------------------------------+
 |Node 1                                    |
 |                                          |
 |            +----------------+            |
 |            | Service        |            |
 |            | Port:8888      |            |
 |            | Target Port: 80|            |
 |            | IP: 10.1.1.50  |            |
 |            +-^-----------^--+            |
 |              |           |               |
 |              |           |               |
 |        +-----v---+   +---v----+          |
 |        | Pod1    |   |Pod2    |          |
 |        | Port 80 |   |Port 80 |          |
 |        |         |   |        |          |
 |        +---------+   +--------+          |
 |                                          |
 |                                          |
 |                                          |
 +------------------------------------------+

However how can we access this outside the cluster?

This is when nodeport comes into play. When you declare a nodeport, you are connecting the service to use a port on the node to expose the targeted pods in the cluster.
               +-------------+
               |  Node Port: |
+--------------+    30000    +-------------+
|Node 1        +----^--------+             |
|IP:                |                      |
|192.168.1.5 +------v---------+            |
|            | Service        |            |
|            |                |            |
|            | Target Port: 80|            |
|            | IP: 10.1.1.50  |            |
|            +-^-----------^--+            |
|              |           |               |
|              |           |               |
|        +-----v---+   +---v----+          |
|        | Pod1    |   |Pod2    |          |
|        | Port 80 |   |Port 80 |          |
|        |         |   |        |          |
|        +---------+   +--------+          |
|                                          |
|                                          |
|                                          |
+------------------------------------------+

So forexample, we have pods located in node 1 that currently has a service that is connected to pods 1 and 2. The service is then exposing these pods on the nodes port: 30000. So if i had node 2 with ip 192.168.1.6, if i were to run a curl on node 1 "curl 192.168.1.5:30000" this would then contact the service which would then redirect traffic to pods 1 and 2, thus having these pods exposed. 

When using a nodeport, you would need to declare the type and node port in the manifest:

apiVersion: v1 # test8.yaml
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  selector:
    tier: frontend
  ports:
    - protocol: TCP
      port: 80 #port on the service
      nodePort: 30000 # port on the node that will be used. 
      targetPort: 80 #target port the service will use agaisnt the pods

      


- References 

https://kubernetes.io/docs/concepts/services-networking/service/
https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/