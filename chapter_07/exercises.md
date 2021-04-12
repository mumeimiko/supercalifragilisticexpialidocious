1a. Imperative: create a pod named $POD_NAME with image $IMAGE.
1b. Imperative: Create a service to expose this pod on port 80 via imperative command.
   Does this work? If not fix it

2a. Declarative: Create a new pod called tico using the nginx image
2b. Declarative: Create a service named puravida with a ClusterIP that uses port 8888 and redirects to containers port


4a. Create a deployment named deku with image nginx with 4 replicas. 
4b. Create a service that is using ClusterIP that points to the deku pods  

5a. Create a deployment named allmight with image nginx with 3 replicas.
5b. Create a service that is using ClusterIP that is open on port 8888 and points to the correct port on the pods in allmight 

6a. Create a deployment name academia with the following criteria.
      -  Container_1 
        Image: nginx
      - Container_2
        Image: redis
6b. Create a service named oneforall that is using ClusterIP that is open on port 8080 that targets the port for container_1

7a. We are going to create a deployment named onepiece with image nginx with 3 replicas. However we will add a liveness probe to check the containers port being open. 
7b. Create a service named zoro with NodePort set to 30007

8a.Create a deployment named test1 with image nginx with 3 replicas. 
8b. Create a service that is using Type Load balancer ClusterIP that points to the test1 pods 

kubectl expose pod redis --port=6379 --name redis-service --type-ClusterIP



