# Song of the day 

Da Funk - Daft Punk

ConfigMaps

A ConfigMap is an API object used to store non-confidential data in key-value pairs. Pods can consume ConfigMaps as environment variables, command-line arguments, or as configuration files in a volume.

NON-CONFI-DEN-TIAL!!!!!!!!!!

A ConfigMap is not designed to hold large chunks of data. The data stored in a ConfigMap cannot exceed 1 MiB. If you need to store settings that are larger than this limit, you may want to consider mounting a volume or use a separate database or file service.

The name of a ConfigMap must be a valid DNS subdomain name.

Each key under the data or the binaryData field must consist of alphanumeric characters, -, _ or .. The keys stored in data must not overlap with the keys in the binaryData field.

There are four different ways that you can use a ConfigMap to configure a container inside a Pod:

    Inside a container command and args
    Environment variables for a container
    Add a file in read-only volume, for the application to read
    Write code to run inside the Pod that uses the Kubernetes API to read a ConfigMap

# Create the configmap

## Exercise 1
Lets create a key=value pair in a configmap and pass this as a variable on a pod

    kubectl create configmap config1 --from-literal=mumei=miko

    bash recreate_01.sh 
    
    #Output from the logs of the pod 

    whats up? This is the command ran inside the container

    Bellow you will see the current variables in a pod

    ===================================

    KUBERNETES_PORT=tcp://10.100.0.1:443
    KUBERNETES_SERVICE_PORT=443
    HOSTNAME=test-pod
    SHLVL=1
    HOME=/root
    KUBERNETES_PORT_443_TCP_ADDR=10.100.0.1
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    KUBERNETES_PORT_443_TCP_PORT=443
    KUBERNETES_PORT_443_TCP_PROTO=tcp
    SPECIAL_LEVEL_KEY=miko
    KUBERNETES_SERVICE_PORT_HTTPS=443
    KUBERNETES_PORT_443_TCP=tcp://10.100.0.1:443
    PWD=/
    KUBERNETES_SERVICE_HOST=10.100.0.1

    ===================================

    Now this is the variable we created in configmap being displayed

    SPECIAL_LEVEL_KEY is miko

Ok so what happened?

As mentioned, when we created a configmap, we created config1 and within this configmap, we declared they key=value pair has mumei=miko.

Now what we then did was when we create a pod to use this mumei=miko key pair as an environmental variable for the pod. This was done via the following:

      env:
        # Define the environment variable
        - name: SPECIAL_LEVEL_KEY # This is the variable thats going to be declared in the container
          valueFrom:
            configMapKeyRef:
              # The ConfigMap containing the value you want to assign to SPECIAL_LEVEL_KEY
              name: config1
              # Specifying the key from config associated with the value AKA mumei=SPECIAL_LEVEL_KEY=miko
              key: mumei

So we tell the pod to grab the variables from config and set the value for SPECIAL_LEVEL_KEY from key: mumei, which is miko. So essentially\: mumei=SPECIAL_LEVEL_KEY=miko

## Exercise 2

What about using multiple key=value pairs with with a container? In the above example we declared the Environmental Variable and then mapped it to a key from config1. This is confusing.  

Wouldnt it be much better if we can just simply provide the following key value pairs below as is without manually declaring the key/environmental variable?

    mumei=miko
    pokemon=blue
    mtg=bwcontrol
    stonks=gme 

Lets do it!!!!

    apiVersion: v1     #File config2.yaml
    kind: ConfigMap
    metadata:
    name: special-config
    namespace: default
    data:
    mumei: miko
    pokemon: blue
    mtg: bwcontrol
    stonks: gme 
    song: meant_to_be

Now after running recreate_02.sh I can see that test-pod-2 contains the variables 

    bash recreate.sh  

    Bellow you will see the current variables in a pod

    ===================================

    mtg=bwcontrol
    song=meant_to_be
    pokemon=blue
    stonks=gme
    mumei=miko
    ===================================

    Now this is the variables we created in configmap being displayed within the pod;

    mumei is miko
    pokemon is blue
    mtg is bwcontrol
    stonks is gme
    song is meant_to_be

## Exercise 3

Now that we have manually created the config maps, can you imagine trying to automate these values into a configmap manifest?

You would have to create custom scripts to input scripts for automation. 

What if we can just simply provide a file to create the values for a configmap...........

Well you CAN!!!!!!!!!!!!!

If you take a look at file config3.txt, you will see key=value pairs. Lets create a a config map named countrymusic with the config3.txt file. 

config3.txt 

    #list of songs and their artists
    achy_breaky_heart=billy.ray.cyrus
    meant.to.be=bebe.rexha
    ring_of_fire=johnny.cash
    need_you_now: lady_a
    love_story: taylor_shift

Now creating it: 

    kubectl create configmap countrymusic --from-file=config3.txt
    kubectl apply -f test3.yaml
    sleep 5
    kubectl logs test-pod-3

    achy_breaky_heart sung by
    meant.to.be sung by .to.be
    ring_of_fire sung by
    need_you_now sung by
    love_story sung by


Hmm, what went wrong??

Bash does not allow environment variables with non-alphanumeric characters in their names (aside from _)

So you would need to assure yourself that tha variables you are trying to create meet the basic requirements in bash. 

Lets try this again

    kubectl create configmap countrymusic --from-file=config3.txt
    kubectl apply -f test33.yaml
    sleep 5
    kubectl logs test-pod-33

    Now this is the variables we created in configmap being displayed within the pod

    achybreakyheart sung by billyraycyrus
    meanttobe sung by beberexha
    ringoffire sung by johnnycash
    needyounow sung by ladya
    lovestory sung by taylorshift


kubectl create -f https://kubernetes.io/examples/configmap/configmap-multikeys.yaml && kubectl create -f https://kubernetes.io/examples/pods/pod-configmap-volume.yaml

# Exercise Volume Mounts 

Now lets try volume mounts 


  kubectl apply -f config4.yaml
  kubectl apply -f test4.yaml



## Secrets - 

Lyrics
I hear the secrets that you keep
When you're talking in your sleep

Sorry had to include this lyrics from the weeknd


Kubernetes Secrets let you store and manage sensitive information, such as passwords, OAuth tokens, and ssh keys. Storing confidential information in a Secret is safer and more flexible than putting it verbatim in a Pod definition or in a container image


A Secret can be used with a Pod in three ways:

    As files in a volume mounted on one or more of its containers.
    As container environment variable.
    By the kubelet when pulling images for the Pod.

The name of a Secret object must be a valid DNS subdomain name. You can specify the data and/or the stringData field when creating a configuration file for a Secret. The data and the stringData fields are optional. The values for all keys in the data field have to be base64-encoded strings. If the conversion to base64 string is not desirable, you can choose to specify the stringData field instead, which accepts arbitrary strings as values.

The keys of data and stringData must consist of alphanumeric characters, -, _ or .. All key-value pairs in the stringData field are internally merged into the data field. If a key appears in both the data and the stringData field, the value specified in the stringData field takes precedence.

"Valid DNS subdomain name"

    contain at most 63 characters
    contain only lowercase alphanumeric characters or '-'
    start with an alphanumeric character
    end with an alphanumeric character


Lets create a super super secret!!!!!!!!

    apiVersion: v1
    kind: Secret
    metadata:
      name: secret-basic-auth
    type: kubernetes.io/basic-auth
    stringData:
      username: admin
      password: Supercalifragilisticexpialidocious

Now its your turn to create files and paste them. Run the above manifest. 

Lets check it out!

    kubectl apply -f file1.yaml
    kubectl describe secret secret-basic-auth

    Name:         secret-basic-auth
    Namespace:    default
    Labels:       <none>
    Annotations:  
    Type:         kubernetes.io/basic-auth

    Data
    ====
    password:  10 bytes
    username:  5 bytes

Notice how the data is not listed?

lets try adding the secrets to a pod and look at the values 
    kubectl apply -f test5.yaml
    kubectl get pods
    NAME                    READY   STATUS      RESTARTS   AGE
    nginx-76df748b9-cf5mb   1/1     Running     0          16h
    test-pod-5              0/1     Completed   0          20m
    kuebctl logs test-pod-5

    lrwxrwxrwx    1 root     root            15 Feb 26 05:52 password -> ..data/password
    lrwxrwxrwx    1 root     root            15 Feb 26 05:52 username -> ..data/username
    chocolate chip cookioe
    This is the username
    admin
    This is the password
    t0p-Secret

Now that we saw the file, can we add permissions to the file so that only the root user can have accesss to the username and password?
    kuebctl apply -f test6.yaml
    kubectl logs test-pod-6.yaml
    lrwxrwxrwx    1 root     root            15 Feb 26 06:18 password -> ..data/password
    lrwxrwxrwx    1 root     root            15 Feb 26 06:18 username -> ..data/username
    chocolate chip cookioe
    This is the username
    admin
    This is the password
    t0p-Secret
    total 8
    -r--------    1 root     root            10 Feb 26 06:18 password
    -r--------    1 root     root             5 Feb 26 06:18 username

By now you must be like "hmmmm can we use something else besides plain text?"

Yes!!!! However you just have the password or text encoded first. 

echo -n 'admin' | base64 

Something to do:

kubectl create secret docker-registry my-image-pull-secret \ --docker-username=<username> \
--docker-password=<password> \ --docker-email=<email-address>


