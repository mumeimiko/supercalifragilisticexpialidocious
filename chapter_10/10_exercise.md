kubectl run webapp --replicas=3 --image=kodekloud/webapp-color
kubectl create deploy webapp --image=kodekloud/webapp-color --replicas=3

1. Create the following deployments and pod:
1a. Deployment_1
  - Name: webpage
  - Image: nginxdemos/hello:plain-text
  - Replicas: 2
  - Labels:
    - app: webpage
    - tier: frontend
  - Annotation:
    kubernetes.io/change-cause: "v1 - Creation - Frontend Webpage"
1a. Deployment_2
  - Name: database
  - Image: redis
  - Labels
    - app: db
    - tier: backend
  - Replicas: 2
  - Annotation:
    kubernetes.io/change-cause: "v1 - Creation - Backend Database"
1c. Create a pod named testunit with the image of your choice that you can exec into to run some tests with. If you don't know which one to use, take a look at 10_answers.md.

2. Do the following to the deployments:
  a. Increase webpage pods to 6
  b. Increase database pods to 3

3a. Create a service named aizawa that points to the webpage pods using port 8888 as a ClusterIP. You are doing to use the following labels for the service to select: tier: frontend 

3b. Run the following command agaisnt the service to make sure everything is working:
  - kubectl exec -it  testunit -- curl aizawa:8888

4a. Add the following label and update the change-cause annotation to the webpage deployment
  - hello:world
  - v2 - Update - Adding hello tag

4b. Run the following command agaisnt the service to make sure everything is working:
  - kubectl exec -it  testunit -- curl aizawa:8888

5. Do the following on the webpage deployment:
  - Remove label; tier:frontend
  - Add the following annotation v3 - Removal - Removing tier:frontend Label

6. Troubleshoot - Something is broken, fix it without editing anything with the deployment. 
  - Hint - Ludacris - Rollout

7. Update webpage to have 6 replicas with a rollingupdate strategy of 50% for maxUnavailable

8. You have to update the redis image to the latest redis image. Along with this you notice the connections to redis have been slow and you need to increase the replicas for the deployment. However since we are live in production, we need to bring down the databases slowly. Also if we have issues with the image, we need to have the ability to rollback. So lets update the database deployment to have the following:
  - Replicas: 4
  - v2 - Update - Meet new requirements
  - Image: redis:latest
  - Strategy: Rollingupdate | Max Unavailable - 1 pod at a time
  