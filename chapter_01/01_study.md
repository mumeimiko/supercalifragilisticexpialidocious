# Song of the Day

Video killed the Radio Star - The buggles 

# Pre Reqs

None

# Chapter 1 - So you broke production........

In this chapter, we are just going to play with pods on a running cluster. So before we start, please run the following command if you have not started your minikube cluster:

    minikube stop 
    minikube start

Pods are the smallest deployable units of computing that you can create and manage in Kubernetes

tl:dr pods are containers.

At the moment, you should be in the chapter_01 folder Please run pwd to see if you are are in the folder

Run the following command from chapter_01

    bash cka1.sh

What pods do you see running?

    kubectl get pods 

What one is the current status of the nginx* pod?

- Running 
- Completed 

Theses are some of the lifecycles statuses of the pods 

Are there any more pods?

Yes!!!!! Run the following command:

    kubectl get pods -A

    NAMESPACE     NAME                                     READY   STATUS      RESTARTS  
    default       hello-x5h2q                              0/1     Completed   0          
    default       nginx                                    1/1     Running     0          
    kube-system   coredns-74ff55c5b-tx2rd                  1/1     Running     0           
    kube-system   etcd-multinode-demo                      1/1     Running     0           
    kube-system   kindnet-4qbq7                            1/1     Running     0           
    kube-system   kindnet-nr68g                            1/1     Running     0           
    kube-system   kube-apiserver-multinode-demo            1/1     Running     0           
    kube-system   kube-controller-manager-multinode-demo   1/1     Running     0           
    kube-system   kube-proxy-jx9kt                         1/1     Running     0           
    kube-system   kube-proxy-qxht6                         1/1     Running     0           
    kube-system   kube-scheduler-multinode-demo            1/1     Running     0         

Why didn't we see these pods earlier?

This is because when we took a look at the pods, we looked at the default namespace instead of looking at ALL the namespaces.

Run the following command:

    kubectl get namespaces

    NAME              STATUS   AGE
    default           Active   2d6h
    kube-node-lease   Active   2d6h
    kube-public       Active   2d6h
    kube-system       Active   2d6h

In order for kubernetes to run, there has to be a workspace for pods to land on. Think of it like this: 

When you go to a grocery store, items are categorized in sections to keep things in order. For example Meats are in the meat aisle and vegetables are in the vegetable aisle.
 
As you saw in the above command, majority of the the pods are in kube-system namespace. Here's a quick snippet of what these pods are that help run a kubernetes cluster:

    - coredns: CoreDNS is a fast and flexible DNS server
    
    - etcd: etcd is a consistent and highly-available key value store used as Kubernetes' backing store for all cluster data
    
    - kindnet: CNI (Container Network Interface), a Cloud Native Computing Foundation project, consists of a specification and libraries for writing plugins to configure network interfaces in Linux containers, along with a number of supported plugins.
    
    - kube-apiserver: The Kubernetes API server validates and configures data for the api objects which include pods, services, replicationcontrollers, and others
    
    - kube-controller-manager: The Kubernetes controller manager is a daemon that embeds the core control loops shipped with Kubernetes.
    
    - kube-proxy: kube-proxy is a network proxy that runs on each node in your cluster, implementing part of the Kubernetes Service concept. kube-proxy maintains network rules on nodes.
    
    -kube-scheduler: control plane process which assigns Pods to Nodes

Right now the point of the lessons are just to get you working on kuberenetes and hands on experience. There's more to these components which I can go into depth in advanced lesson plans.


**AWS - EKS**
    
    
    Why is it when i run get pods for kube-system for EKS, it doesn't show the above pods?

    This is because EKS manages some of the control plane pods and allows only the nescessary pods to run on secondary nodes, such as the following:

    aws-node - Similar to CNI
    core-dns - Same as above 
    kube-proxy - same as above

Now run the following command:

    kubectl get pods -n kube-system -o wide

Take a look underneath Node, this is the node(location) in which the pods are running on. Notice that the following pods are running on each node:

kube-proxy
kindnet

### **Why is it that there are pods running on each node and some that are only running on certain nodes?**

You have to understand that there are pods that run in ALL nodes and some that only run on the Primary node such as the following:

### Primary

    coredns 
    etcd 
    kube-apiserver
    kube-controller-manager
    kube-scheduler 
    storage-provisioner 

### Default 

    kube-proxy
    kindnet(CNI) 

By default, kube-proxy and CNI run on each node. 

Let's clean up the environment

    kubectl delete pod nginx
    kubectl delete -f test1.yaml 

# Takeaway

- Take a look at running pods
- Look at namespaces associated with Kubernetes
- Pods nescessary to run a Kubernetes cluster