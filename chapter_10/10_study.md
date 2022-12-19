# Song of the day 

Dirty Heads ft. Matisyahu - Dance All Night

# Pre-Req

bash delele.sh

# Don't look now I just took flight

So we have worked with deployments, and really haven't dove deep into deployments.  We understand that we can launch pods individually and we can use replicasets to help run multiple pods, which some can think this is enough to get by right?

Well what if you are running an older version of nginx or you have to push an update. 

    - Pod - If you are running pods and they are running your website, this can be a headache has you have to manually relaunch all the pods and assure they are all running and everything is in working order.

    - Replicasets - You can easily just delete and run a new set of pods, however you are down for awhile and you don't know how fast your website will be up

So this is when using deployments are in your best interest as its able to tackle such issues. but first lets play around with deployments.

# Deployment

Take a look at file test1.yaml.  In this file we had 4 pod manifests in one file. Each resource was an individual pod, were we had two environments prod and stage and each environment had a webpage and a database. 

Your first assignment is to create a file called test3.yaml that uses deployment instead of pod. Take a look at test2.yaml for how a deployment looks and recreate the same properties in a deployment based on test1.yaml

Note the following:
    - You will need to change names among other things
    - Assure that when you deploy you are running one pod in each deployment

You should have something similar to the following:

    kubectl get pods -w
    NAME                                READY   STATUS    RESTARTS   AGE
    db-prod-5fb64db5b9-4gcbd            1/1     Running   0          12s
    db-stage-6865c64b54-2rgtb           1/1     Running   0          12s
    web-page-prod-6f5cc8d6b5-kgkl9      1/1     Running   0          12s
    web-page-staging-85b8c9fd56-59kv4   1/1     Running   0          12s

# Situation 1
Say you show up to a new job and they asked you to increase the pods as there is going to be a sale occuring in 2 hours and the single front end pod is not enough for the high demand. How would you incease the pod count?

## Method 1 - 

You can update the test3.yaml file and edit the web-page-prod from 1 replica to 3

## Method 2
But since you are new, are you likely to have access to this file right away? Most likely no. So whats next?

If you have a running deployment, you can easily export the manifest and reapply it with new changes. 

- Lets first find the deployments
    - kubectl get deployments

            NAME               READY   UP-TO-DATE   AVAILABLE   AGE
            db-prod            1/1     1            1           8m33s
            db-stage           1/1     1            1           8m33s
            web-page-prod      1/1     1            1           8m33s
            web-page-staging   1/1     1            1           8m33s
- Then you can run the following command to export the manifest:
    - kubectl get deployments web-page-prod -o yaml --export > test4.yaml 

- Then take a look at file test4.yaml and edit the replica number from 1 to 3 and then apply the file and you should now see the following:

        kubectl get pods
        NAME                                READY   STATUS    RESTARTS   AGE
        db-prod-5fb64db5b9-4gcbd            1/1     Running   0          11m
        db-stage-6865c64b54-2rgtb           1/1     Running   0          11m
        web-page-prod-6f5cc8d6b5-kgkl9      1/1     Running   0          11m
        web-page-prod-6f5cc8d6b5-q4tjx      1/1     Running   0          46s
        web-page-prod-6f5cc8d6b5-qt7lx      1/1     Running   0          46s
        web-page-staging-85b8c9fd56-59kv4   1/1     Running   0          11m

## Method 3

Manually edit the deployment!

kubectl edit is a command to help you modify any configuration

Run the following command:

    kubectl edit deployments web-page-prod 

You will see something similar to test4.yaml but instead you are actually doing a live edit. The default editor is vi to please understand the very short vi lesson below:

### Super vi lesson

When working with vi, you don't automaticall start editing the file like you would in a textedit or notepad or nano. you have to enter a set of key configurations to get into a "mode"

Key
i - When you enter "i" you are in interactive mode which allows you to edit the file
esc - Allows you to escape interactive mode. You should see --insert-- at the bottom of the screen

Key Sequence
:q - This allows you exit vi (note this is a key combination so : and q have to be entered manually and then you execute by pressing the enter key)

:wq! - This allows you to exit v and also save the contents

Back to method 3, so you would do the following:

- Press the i key
- Look for the replicas property and change it to 1
- Once edited press "esc" and then type in the following characters ":wq!"
- Now run kubectl get pods

You should now only see 1 pod running for web-page-prod

## Method 4

Scale up the deployment to 3 pods

    kubectl scale deployments web-page-prod --replicas=3

# Updating deployments 

Think of the following:

When you make changes to template and apply it, is this considered a NEW deployment or an Updated deployment?

run bash delete.sh and then run test5.yaml. You will see that there is an annotation in web-page-prod with "v1 - Set replica number - 1". 

Now run "kubectl rollout history deployment web-page-prod"

You should see the following:

    kubectl rollout history deployment web-page-prod
    deployment.apps/web-page-prod 
    REVISION  CHANGE-CAUSE
    1         v1 - Set replica number - 1

Now update test5.yaml and update the field to "v2 - Set replica number - 4" and update replicas to 4 and run test5.yaml. What do you see?

    kubectl rollout history deployment web-page-prod
    deployment.apps/web-page-prod 
    REVISION  CHANGE-CAUSE
    1         v2 - Set replica number - 4

Whenever you run an apply, you aren't nescessarly changing/updating the deployment

When i first started to play with this I was assuming that i would see the following:

    kubectl rollout history deployment web-page-prod
    deployment.apps/web-page-prod 
    REVISION  CHANGE-CAUSE
    1         v1 - Set replica number - 1
    2         v2 - Set replica number - 4

But as you can its not like that. HOWEVER there's a reason why. 

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-page-prod
  annotations:
    kubernetes.io/change-cause: "v3 - Set name to amazonlinux"
spec: 
  selector:
    matchLabels:
      tier: frontend
  replicas: 4 # everything above this will not cause a rollout
  template: # Everything under template that is changed will cause a rollout
    metadata:
      labels:
        env: prod
        tier: frontend
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80


A Deployment's rollout is triggered if and only if the Deployment's Pod template (that is, .spec.template) is changed, for example if the labels or container images of the template are updated. Other updates, such as scaling the Deployment, do not trigger a rollout.

Try the following

Add the label papi=champagne and edit the annotation to "v3 - Adding Drake to the house"

You should now see the following with kubectl rollout history deployment web-page-prod:

1         v2 - Set replica number - 1
2         v3 - Adding Drake to the house

Now lets change the image to amazonlinux and change the annotation to "v4 - Set image to amazonlinux" and run test5.yaml

I can see the image is changed:
    kubectl get rs -o wide
    NAME                          DESIRED   CURRENT   READY   AGE    CONTAINERS    IMAGES        SELECTOR
    web-page-prod-6788695687      1         1         0       30s    nginx         amazonlinux   pod-template-hash=6788695687,tier=frontend

    kubectl rollout history deployment web-page-prod
    1         v2 - Set replica number - 1
    2         v3 - Adding Drake to the house
    3         v4 - Set image to amazonlinux

Now lets say that the new image doesn't work for us so we want to rollback to a previous revision. We can do so by running the following command:

    kubectl rollout undo deployments kuard --to-revision=2

You should now see that the revision is now set to 4 and v3 is moved with it

    kubectl rollout history deployment web-page-prod
    1         v2 - Set replica number - 1
    3         v4 - Set image to amazonlinux
    4         v3 - Adding Drake to the house


# Update Strategies

Two types:

## Recreate

terminate the old version and release the new one. Basically if you have 5 pods and you have recreate set, it will kill all 5 pods and launch a new set of 5 pods. 

For example, the following will occur;
 Environment: 5 pods
 OldImage: nginx:1.1.1
 NewImage: nginx:1.2.1

Event 1: 
Delete All pods

Event 2: 
Create New Pods 

## RollingUpdate

Deployment creates a new replicaset and creates pods while deleting pods little by little from the old replicaset until the new replicaset is in working order. 

The Deployment controller stops the bad rollout automatically, and stops scaling up the new ReplicaSet. This depends on the rollingUpdate parameters (maxUnavailable specifically) that you have specified. Kubernetes by default sets the value to 25%.

For example, the following will occur;
 Environment: 5 pods
 OldImage: nginx:1.1.1
 NewImage: nginx:1.2.1

Event 1: 
Name     Ready    Status     Image
pod1     1/1      Running    nginx:1.1.1
pod2     1/1      Running    nginx:1.1.1
pod3     1/1      Running    nginx:1.1.1
pod4     1/1      Running    nginx:1.1.1
pod5     0/1      Deleting   nginx:1.1.1
pod6     0/1      Creating   nginx:1.2.1

Event 2:
pod1     1/1      Running    nginx:1.1.1
pod2     1/1      Running    nginx:1.1.1
pod3     1/1      Running    nginx:1.1.1
pod4     0/1      Deleting   nginx:1.1.1
pod6     1/1      Running    nginx:1.2.1
pod7     0/1      Creating   nginx:1.2.1     

etc etc.......
 

Event 2: 
Create New Pods 


Here's how it would look:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-page-prod
  annotations:
    kubernetes.io/change-cause: "v1 - Set replica number - 1"
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 50%
  selector:
    matchLabels:
      tier: frontend
  replicas: 1
  template:
.....

Not going to go into this has you can get heavily into how you redeploy things


StrategyType:    
When 
- Change the images
    - webpage to use httpd
    - database to use mysql
- Include readiness and liveness checks


## Exercise 1 

1. Create a deployment with the following:
  - Strategy: #DEPLOYMENT_STRATEGY
  - Pod Name: #POD_NAME
  - Image: #POD_IMAGE
  - Number of Replicas: #REPLICA_SET
2. Whats the replica set name?

## Exercise 2

1. Update the deployment to use the following:
  - Image: POD_Image 
2. Whats the new replicaset name?

## Exercise 3

1. Rollback the deployment 




KEY_TERMS