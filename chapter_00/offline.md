you can use minikube offline!!!! however you must do the following

1.  Download images

minikube cache add <image>

all the image are downloaded in ~/.minikube/cache/images

You can also download image to this directory

2.  Running minikube 

by default, minikube will run cache images

minikube start 

3. Run pods with imagepullpolicy flag

Depending on your usage, you will need to run either of the following:

    minikube stop
    minikube start --nodes 3 -p nodes


kubectl run nginx --image=nginx --image-pull-policy=IfNotPresent

or with a template file, use the property

apiVersion: v1
kind: Pod
metadata:
  name: myapp
  labels:
    name: myapp
spec:
  containers:
  - name: myapp
    image: nginx
    imagePullPolicy: IfNotPresent
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
    ports:
      - containerPort: 80





