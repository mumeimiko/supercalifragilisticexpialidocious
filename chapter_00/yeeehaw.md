# Song of the day

Avicii - Levels


# So you wanna get certified......

Me too!!!!! However I myself am learning and trying to get a cert. So far all the training out there kinda sucks and go in depth to a point i get bored. i am a hands-on person who learns by doing and breaking stuff. So i am creating these lesson plans on my own outside of anything work related because i know i am not the only one who prefers to study like this.

before going forward please understand the following:

1. i dont edit my grammar or fix my typos. However all the commands i use are literally copy and pasted here to assure it works
2. K8s versions change ALOT!!!!!!!!! so some commands can become deprecated when running. I will try to note this but its not guaranteed
3. i haven't taken the test ATM.

# Installing minikube

Honestly, i would suggest to start working with minikube because

- you don't have to setup an EKS cluster and deal with the pre-requisites
- manually creating a kubernetes cluster when you are not familiar with kubernetes is a bit hard to understand(kinda)
- you can easily bring it up and tear it down on any machine local or remote


## Step 1 - Install minikube 

you can install minikube on any device, HOWEVER since you are beggining, i would suggest to install locally on your machine as you dont have to pay for resources on a cloud provider

NOTE - If you are going to create a cluster with large amount of nodes and pods, I would suggest to launch an EC2 instance that can support the capacity. But so far everything we do here can be done on a small machine

Use the following link to see the installation steps:

https://minikube.sigs.k8s.io/docs/start/


## Step 2 - Starting your cluster

You will have issues running "minikube start" if you have not installed a container "engine"

So go to this page and see which one you want to use

https://minikube.sigs.k8s.io/docs/drivers/

### Default - Docker 

Use the following link to install docker. Docker is the common container used

https://hub.docker.com/search?q=&type=edition&offering=community&sort=updated_at&order=desc

### Setup Minikube 

After you install docker you have to modify minikube to use docker. use the following page

https://minikube.sigs.k8s.io/docs/drivers/docker/

## Step 3 Start your cluster:

minikube config set driver docker

to start your cluster, run the following command:

minikube start 

If you want to start with multiple nodes, run the following command

minikube start --nodes 2 -p nodes --disk-size 10000mb --cpus 2 --memory 2gb

Note: this will launch a node that uses 10gb volume space that use 2 cpus and 2gb memory for each virtual node 

Make sure you run this has in later chapters (5 for example, you will need to have multiple nodes)

# Remote 
If you want to run on a remote machine in AWS, use the following cfn_template.json. This will create an instance that will install all the pre-requisites such that you all you have to do is ssh into the node and run minikube start.

# Bash installation

You can also run the following bash script (install.sh) to install minikube in your amazon linux 2 machine. 

This was fedora based so it will not work on debian based machines

# Lesson Plans

In the lessons plans, you will need to make sure you have access to the folder in the terminal so you can run commands with the appropriate lesson. 

# LINUX POWER!!!!

Keep in mind all the commands i am listing are run in Linux. You can also run this in MacOSX.

Sorry Windows. However you should still be able to run kubectl commands but its going to be a bit harder

However you can try to find substitutes such as:

    Linux     Windows
    grep    | Select-String -Pattern <regexPattern>
