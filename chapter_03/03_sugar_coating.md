# song of the day 
One Thing Right - Marshmello, Kane Brown 

# Pre-req

run the cleanup script

    bash delete.sh

# Manifests

Lets run the following cycle

1. Run pod
    - kubectl run test1 --image=nginx
2. Check on the pod
    - kubectl get pods
3. Kill the pod!!!!!!!
    - kubectl delete pods test1

Now lets play with manifests

A pod manifest basically gives the configuration to use with a pod such as how much ram/cpu to give a pod or which image. As we were manually running the command to create the pod, this takes a bit longer typing up and can be a bit hard to have in one line

So lets look at a manifest:

    apiVersion: v1
    kind: Pod
    metadata:
      name: myapp 
      labels: 
        name: myapp
    spec:
    containers:
    - name: myapp
        image: nginx #image the container will use
        imagePullPolicy: IfNotPresent
        resources:
        limits:
            memory: "128Mi"
            cpu: "500m"
        ports: # ports you are exposing on the pod 
        - containerPort: 80

So the above manifest lists the following:

    apiVersion: v1
    kind: Pod #resource you want to create
    metadata:
      name: myapp # this is the name you see when you run kubectl get pods 
      labels:  # labels you want to attach to pod 
        name: myapp 
    spec:
    containers:
    - name: myapp
        image: nginx #image the container will use
        imagePullPolicy: IfNotPresent # you can ignore this right now
        resources:
        limits: #how much resource the pod can use up to
            memory: "128Mi" 
            cpu: "500m"
        ports:
        - containerPort: 80 #port to have open on the container

Lets runs it

## Exercise 1
Lets run the following cycle

1. Run pod
    - kubectl apply -f pod_01.yaml
2. Check on the pod
    - kubectl get pods
3. Kill the pod!!!!!!!
    - kubectl delete -f pod_01.yaml

With manifests, you can easily delete the deployment just by stating the manifest that created it 

# Limits and Requests

Obviously we don't want to give a pod all the resources available on the node. So in order to set a minimum value and a maximum value of resources for a pod, you would need to set the limites and requests for the pod in the manifest

Example 

    apiVersion: v1
    kind: Pod
    metadata:
      name: myapp
      labels:
        name: myapp
    spec:
      containers:
      - name: test5
        image: nginx
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            memory: "256Mi"
            cpu: "256m"
          requests:
            memory: "128Mi"
            cpu: "128m"      
        ports:
          - containerPort: 80

Requests is the resources set aside on the node to run the pod. For example if the pod running nginx runs about 64Mi in CPU/Memory, this is fine, however if we know there is workloads that make this go above 128mi normally, we would set this to minimum 128mi set aside for usage with the pod

However say a hacker hits the website which causes resources to spike, if you don't have a limit set, the pod can exentially use up all your resources. Or if you never expect the container to use more then 256mi, then you would set a limits value.

# Creating manifests 

Being quite honest, I don’t remember how to create a manifest. Its a lot to remember. However in the test, you have the Kubernetes site to look this up for any resource you want to create. However this can be quite time consuming

There is a way that you can create a simple template and then edit the file itself by running the following command:

    kubectl run busybox --image=busybox --dry-run -o yaml --restart=Never > test1.yaml

It should look like this:

    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        run: busybox
      name: busybox
    spec:
      containers:
      - image: busybox
        name: busybox
        resources: {}
      dnsPolicy: ClusterFirst
      restartPolicy: Never
    status: {}

# Exercises

Take a look at file test_exercises.md for exercises.