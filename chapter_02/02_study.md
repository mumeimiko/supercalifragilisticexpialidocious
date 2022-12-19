# Song of the Day

Danza Kaduro - Don Omar


# Chapter 2 - Topo Chico

In this lesson we will take a look at the following:

- Kubernetes objects 
- Creating and running pods and namespaces 
- Interacting with pods via ssh, exec and proxy 

We will cover some Materials from Chapter 4 and Chapter 5

- Debugging, the right way 
- Labeling pods

# Pre-req 

Make sure you have minikube running, if not run the following command:

minikube start
kubectl delete pods --all 
kubectl delete deployments --all



# Create a namespace 

Lets create a namespace for us to launch pods into. 

    kubectl create namespace tinytim

Now lets create a pod inside tinytim namespace 

Lets create a pod named hearts

- Namespace: tinytim
- Pod Name: hearts
- Image: nginx

kubectl run <pod_name> --image=<image_name> -n <namespace>

    kubectl run hearts --image=nginx -n tinytim

### Note: this will be deprecated, once deprecated, will update later

Let's take a look at the pods:

    kubectl get pods
    NAME                     READY   STATUS    RESTARTS   AGE
    nginx-598b589c46-7f6p5   1/1     Running   0          17m

Hmmmm where the pod hearts?

    kubectl get pods -A
    NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
    default       nginx-598b589c46-7f6p5             1/1     Running   0          19m
    tinytim       hearts-6ffd5d4558-hvsh9            1/1     Running   0          103s

Remember by default you are stuck with the default namespace, so whenever you run certain commands, you are stuck in default unless you say a different namespace such as:


    kubectl get pods -n tinytim
    NAME                      READY   STATUS    RESTARTS   AGE
    hearts-6ffd5d4558-hvsh9   1/1     Running   0          3m25s

Lets look at common Kubectl commands with pods 

- Get pods from all namespaces
  - kubectl get pods -A
- Get pods from the namespace kube-system 
  - kubectl get pods -n kube-system
- See which nodes the pods are located in
  - kubectl get pods -n kube-system -o wide

These are just some commands to look at the pods only. These commands are the commands you would normally run first, however its the first step to troubleshooting issues with pods or to see whats going on with your pods.

Whats the best command to use for troubleshooting pods?

kubectl get pods -A

Huh? why this command? 

This is because when you run get pods, you can easily see the status of a pod in all namespaces

Here are a few of the statuses of the pods

- Pending	
  - The Pod has been accepted by the Kubernetes cluster, but one or more of the containers has not been set up and made ready to run. This includes time a Pod spends waiting to be scheduled as well as the time spent downloading container images over the network.
- Running
  - The Pod has been bound to a node, and all of the containers have been created. At least one container is still running, or is in the process of starting or restarting.
- Succeeded	
  - All containers in the Pod have terminated in success, and will not be restarted.
- Failed	
  - All containers in the Pod have terminated, and at least one container has terminated in failure. That is, the container either exited with non-zero status or was terminated by the system.
- Unknown	
  - For some reason the state of the Pod could not be obtained. This phase typically occurs due to an error in communicating with the node where the Pod should be running.

In all honesty, I put these in three catagories

- Ok
  - usually seeing running and succedded means that the pod scheduler was able to put the pod on a node and was able to get it running
- Something broke
  Usually seeing pending and failed indicates something just broke. this can be a manifest or a node having issues. These are the common error prone status to worry about
- I dont know
  Unknown. Anything can usually happen here, but this indicates you would likely need to dive deep such as looking at the node docker logs to see exactly what happend. Think of low level troubleshooting compared to pending/failed 

Run the following command and wait 30 seconds

    kubectl apply -f test1.yaml

Now look at the pods, is nginx running?

Run the following command to further inspect the pod

    kubectl describe pods nginx 

Whats going on?

As you can see in events, the pod is not able to be schedules. TL:DR there's no pods that meet the criteria. i'll explain this a bit later

Lets delete all the pods

     bash delete.sh

# Lets have some fun

run this command

    kubectl run amazon --image=amazonlinux

    kubectl get pods

Yay its running but no...... Crashloopbackoff.......

Ok why?

Theres a couple of reasons why such as :

  - The application inside the container keeps crashing
  - Some type of parameters of the pod or container have been configured incorrectly
  - An error has been made when deploying Kubernetes

You have to understand that not all pods run right away or have built in commands to keep it running

So now lets try this 

    bash delete.sh
    kubectl run amazon --image=amazonlinux -- sleep infinity
    kubectl get pods

Is the pod running or stuck in crashloopbackoff?

Nope, its running!!! This is because we passed the sleep infinity command 

Lets try something else now

Remember the first command we ran with amazonlinux that had a crashloopbackoff?

lets try the following:

    kubectl run test1 --restart=Never --image=amazonlinux --  echo "hello world"
    kubectl get pods

Hmmm its showing has completed but why? 

Because we provided a command to run without it attempting to restart and then it ran the echo command and exited right after. Lets see the logs:

kubectl logs test1 

We see the results of the actions that the pods executed 

Hmmmmmm what if we run without the --restart=Never?

Run the two commands below together:

    kubectl run test2  --image=amazonlinux --  echo "hello world" && kubectl get pods test2 -w 

You should see that test2 runs one time and is completed, but then it tries to run again and has issues and causes a crashloopbackoff as it doesnt have a command to process after the first try(need to confirm this)

Now lets try another:

    kubectl run test3 --image=amazonlinux  --restart=Never --  nslookup  amazon.com 

    kubectl get pods test3

Hmmm it didn't work but why?

run the following command to see what happened to your pod:

    kubectl describe pods test3


    Warning  Failed     7m17s  kubelet, nodes-m03  Error: failed to start container "test3": Error response from daemon: OCI runtime create failed: container_linux.go:370: starting container process caused: exec: "nslookup": executable file not found in $PATH: unknown

As you can see, not all containers have all the nescessary commands available. So lets try one that has it 

    kubectl run test4 --image=busybox --restart=Never --  nslookup amazon.com 
    kubectl get pods test4
    kubectl logs test4


#Interacting with pods 


# exec 

Lets "SSH" into a container

    kubectl run test5 --image=amazonlinux -- sleep infinity

Method One(The long way)
1. Locate a running pod
    - kubectl get pods
    test5-757d5d6b94-w4z2x   1/1     Running   0          6m20s
2. Exec into the pod with bash or sh or it
    - kubectl exec -it test5-757d5d6b94-w4z2x  -- /bin/bash 
    - kubectl exec -it test5-757d5d6b94-w4z2x  sh
    - kubectl exec -it test5-757d5d6b94-w4z2x

Method Two(Easy way)
1. Set variable
  - EXECPOD=$(kubectl get pods | grep test5 | awk '{print $1}')
2. kubectl exec -it $EXECPOD -- /bin/bash

NOTE: Do understand that this doesn't always work as all images may not have bash installed.

At this point you can do whatever you would like within the pod

sh-4.2# whoami
root

# port forwarding

Now it would be nice to see whats going on in a container. I wish we had some sort of port forwarding with the pods...........

ya we have something for that
 
lets try the following:

1. Run a simple container 
    - kubectl apply -f https://k8s.io/examples/service/access/hello-application.yaml
2. Expose the port 
    - kubectl expose deployment hello-world --type=NodePort --name=example-service
3. Run a port-forward 
    - kubectl port-forward svc/example-service 8080
4. On you local machine which is running minikube, go to the following address:
    - localhost:8080

You should now see the pods webpage!!

NOTE!!!!!!!!! This is only applies if you are running minikube on your local machine

If this machine is remote, then run the following command for step d

curl localhost:8080

You can also do the following:

    kubectl run test7 --image=nginx
    kubectl port-forward test7* 8888:80

Do note 8888:80 is Source:Destination AKA Localmachine -> pod 

Takeaway

- Create a pod
  kubectl run pod_name --image=container-image
- How to look at logs
  kubectl logs pod_name
- Look at the pods information
  kubectl describe pod_name
- how to ssh into a pod
  kubectl exec -it pod_name sh || kubectl exec -it pod_name /bin/bash
- how to run a command on a pod 
  kubectl exec -it pod_name -- ping -c 1 amazon.com
- Common pod statuses
  Ok Statuses:
    - Running
    - Completed
  Errors:
    - CrashLoopBackOff
    - ErrorPullImage/ImagePullBackOff
    - Pending
    - Failed
- Port Forwarding





Lets look at the pods logs 

kubectl run YOUR_POD_NAME -n YOUR_NAMESPACE --image SOME_PUBLIC_IMAGE:latest --command tailf /dev/null


    Delete the resources you created
    bash delete.sh  

