# song of the day 
Hunted - Steve Jablonsky


# Pre-Req

bash delete.sh
kubectl apply -f test1.yaml
minikube addons enable ingress

Verify ingress controller is running:

kubectl get pods -n kube-system

nginx-ingress-controller-5984b97644-rnkrg


##OSX Error

If you are getting the following error, you might have to use another minikube in a different environment. Luckily you can run the demo in the following link[1] 

minikube addons enable ingress

❌  Exiting due to MK_USAGE: Due to networking limitations of driver docker on darwin, ingress addon is not supported.
Alternatively to use this addon you can use a vm-based driver:

        'minikube start --vm=true'

# Ingress and stress

So usually a load balancer sits in front of web pages and is the front facing address. For example if you go to example.com, its a front facing load balancer were there are 5 web servers sitting behind it

Client -> Load Balancer(example.com) -> Web-Page 

Now lets expand this using kubernetes

Client -> Ingress -> Service -> Pod

So the client hits the front facing website which then hits the service, which the service finds a pod to direct the traffic to. 

NOTE: Advanced - Obviously there is more to this ingress thing, but we are keeping this simple as we dont want to go into redirects and TLS at the moment. 

With the below example in mind, we first need to work with pods then work backwards to ingress. 

Run the following deployment:

    kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0


    get pods --show-labels
    NAME                   READY   STATUS    RESTARTS   AGE    LABELS
    web-79d88c97d6-dgtb8   1/1     Running   0          103s   app=web,pod-template-hash=79d88c97d6

Now we have to create a service. Hmmmmmm whats the manifest to use??????

Well there's no manifest to use this time. You can easily "expose" the deployment which in turn creates a service for you. This can be done with the following command:

    kubectl expose deployment web --type=NodePort --port=8080
    kubectl get service web
    NAME   TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
    web    NodePort   10.97.10.30   <none>        8080:30336/TCP   6s

Let's look at the service:

    minikube service web --url
    http://192.168.49.2:30336

    curl http://192.168.49.2:30336
    Hello, world!
    Version: 1.0.0
    Hostname: web-79d88c97d6-dgtb8

As you can easily see, we are able to see the service being used and able to ping 

Let's create the ingress resource:

    kubectl apply -f https://k8s.io/examples/service/networking/example-ingress.yaml
    kubectl get ingress # this can take a couple of minutes 

I am able to see that my ingress resource is created and is exposing to the outside world. 

    kubectl get ingress
    NAME              CLASS    HOSTS              ADDRESS        PORTS   AGE
    example-ingress   <none>   hello-world.info   192.168.49.2   80      6m44s

I was able to curl the public facing ip address as seen below:

    curl -IkL http://86.75.30.9/ 
    Date: Sun, 21 Feb 2021 06:25:16 GMT
    Server: Apache/2.4.46 () PHP/5.4.16
    Upgrade: h2,h2c
    Connection: Upgrade
    Last-Modified: Mon, 24 Aug 2020 18:53:13 GMT
    ETag: "e2e-5ada1234579"
    Accept-Ranges: bytes
    Content-Length: 3630
    Content-Type: text/html; charset=UTF-8


You have to have an ingress-controller running for ingress to work. Otherwise it wont work. There are TONS of ingress controllers as seen in the following link[2] 


[1] https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/
[2] https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/