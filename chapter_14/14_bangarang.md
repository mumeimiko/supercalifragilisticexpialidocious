# Song of the day 

First of the Year(Equinox) - Skrillex

## Chapter UNKNOWN

# Pre-Req

# Roles and Cluster Roles 

Users need access to the cluster, plain and simple. Whether they are newly joined to the MasterMind of the cluster, everyone needs a role to use to gain access to the cluster. Whether its read only to Controlling every aspect of the cluster(which is still a bad idea)

In this lesson we are going to over Roles and Cluster roles. 

Let's work with basic scenarios and a solution to the scenario. 

## Lets create a user

Simple enough, we want a user to have access to look at pods. So lets create a role!

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]

Thats the role!!

Lets break it down a bit:

### API Groups 

    kubectl api-resources
    NAME                              SHORTNAMES   APIGROUP                       NAMESPACED   KIND
    mutatingwebhookconfigurations                  admissionregistration.k8s.io   false        MutatingWebhookConfiguration
    validatingwebhookconfigurations                admissionregistration.k8s.io   false        ValidatingWebhookConfiguration
    customresourcedefinitions         crd,crds     apiextensions.k8s.io           false        CustomResourceDefinition
    apiservices                                    apiregistration.k8s.io         false        APIService
    controllerrevisions                            apps                           true         ControllerRevision
    daemonsets                        ds           apps                           true         DaemonSet
    deployments                       deploy       apps                           true         Deployment
    replicasets                       rs           apps                           true         ReplicaSet
    statefulsets                      sts          apps                           true         StatefulSet
    tokenreviews                                   authentication.k8s.io          false        TokenReview
    localsubjectaccessreviews                      authorization.k8s.io           true         LocalSubjectAccessReview
    selfsubjectaccessreviews                       authorization.k8s.io           false        SelfSubjectAccessReview
    selfsubjectrulesreviews                        authorization.k8s.io           false        SelfSubjectRulesReview
    subjectaccessreviews                           authorization.k8s.io           false        SubjectAccessReview
    horizontalpodautoscalers          hpa          autoscaling                    true         HorizontalPodAutoscaler
    cronjobs                          cj           batch                          true         CronJob
    jobs                                           batch                          true         Job
    certificatesigningrequests        csr          certificates.k8s.io            false        CertificateSigningRequest
    leases                                         coordination.k8s.io            true         Lease
    eniconfigs                                     crd.k8s.amazonaws.com          false        ENIConfig
    endpointslices                                 discovery.k8s.io               true         EndpointSlice
    events                            ev           events.k8s.io                  true         Event
    ingresses                         ing          extensions                     true         Ingress
    ingressclasses                                 networking.k8s.io              false        IngressClass
    ingresses                         ing          networking.k8s.io              true         Ingress
    networkpolicies                   netpol       networking.k8s.io              true         NetworkPolicy
    runtimeclasses                                 node.k8s.io                    false        RuntimeClass
    poddisruptionbudgets              pdb          policy                         true         PodDisruptionBudget
    podsecuritypolicies               psp          policy                         false        PodSecurityPolicy
    clusterrolebindings                            rbac.authorization.k8s.io      false        ClusterRoleBinding
    clusterroles                                   rbac.authorization.k8s.io      false        ClusterRole
    rolebindings                                   rbac.authorization.k8s.io      true         RoleBinding
    roles                                          rbac.authorization.k8s.io      true         Role
    priorityclasses                   pc           scheduling.k8s.io              false        PriorityClass
    csidrivers                                     storage.k8s.io                 false        CSIDriver
    csinodes                                       storage.k8s.io                 false        CSINode
    storageclasses                    sc           storage.k8s.io                 false        StorageClass
    volumeattachments                              storage.k8s.io                 false        VolumeAttachment
    securitygrouppolicies             sgp          vpcresources.k8s.aws           true         SecurityGroupPolicy

So if I wanted to restrict a user to only apiGroups with batch, i would list it as:

- apiGroups: ["batch"]

If I didn't want to restrict it or anything, I would have set it as follows:

- apiGroups: [""]

### Resources & Verbs 

Here's a small exerpt:

        kubectl api-resources -o wide
        NAME                              SHORTNAMES   APIGROUP                       NAMESPACED   KIND                             VERBS
        nodes                             no                                          false        Node                             [create delete deletecollection get list patch update watch]
        namespaces                        ns                                          false        Namespace                        [create delete get list patch update watch]
        pods                              po                                          true         Pod                              [create delete deletecollection get list patch update watch]
        deployments                       deploy       apps                           true         Deployment                       [create delete deletecollection get list patch update watch]
        replicasets                       rs           apps                           true         ReplicaSet                       [create delete deletecollection get list patch update watch]

In shorthand,

 - Name = Resources
 - Verbs = Verbs 

Lets take a look at the following:

    rules:
    apiGroups: [""] # Ignoring this for the time being 
    resources: ["pods"]
    verbs: ["get", "watch", "list"]

So the resources we have worked on have been with deployments, replicaset, configmaps, and pods. When you are working on creating a role, you have to understand the roles purpose. For example is this role only going to need access to look at the resources, create them or delete them?

#### Example 1

we want to provide read only access to pods, then we would create the rules below for the role

    rules:
    apiGroups: [""] # Ignoring this for the time being 
    resources: ["pods"]
    verbs: ["get", "watch", "list"]

#### Example 2

We want to create a role that can take a look at all resources as read only,

    rules:
    apiGroups: [""] # Ignoring this for the time being 
    resources: ["*"]
    verbs: ["get", "watch", "list"]


#### Example 3 - Hands ON

We need to create a rule that can take a look at all resources as read only EXCEPT for nodes. Please create this role:

    rules:
    apiGroups: ["*"] # Ignoring this for the time being 
    resources: ["*"]
    verbs: ["*"]

#### Examaple 4 

We need to create a rule set that does the following:
  
  - Read Access to all Resources
  - Give delete access to pods

Now this is a bit tricky, You can easily give read resources to everything, but adding the delete action to the user in the same rule not possible. What if we can seperate the rules.....


    rules:
    - apiGroups: [""] # Ignoring this for the time being 
    resources: ["*"]
    verbs: ["get", "watch", "list"]
    - apiGroups: [""] # Ignoring this for the time being 
    resources: ["pods"]
    verbs: ["delete"]

#### Example 5 - Hands on

Create a role that allows the following:

  - Read Access to all Resources
  - Give delete access to pods
  - Create Deployments 

Yay we created a role!!!!!!!!! 

## Real Life Examples 

But remmeber this, when you are creating a role, you are creating a role that is a baseline that can be used for multiple users or just one user. The point of the role is so you don't have to keep creating rule sets for users all over the company. 

For example, we have a company with a full on IT department. You don't want to create roles for every single person, so you create roles(rules) for users in certain departments for example:

### Testers

These people would need full access to the staging environment(Namespace=Staging), thus it makes sense to give them full access to the staging namespace as such:

    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
    namespace: staging
    name: staging-role-user
    rules:
    - apiGroups: ["*"] # Ignoring this for the time being 
    resources: ["*"]
    verbs: ["*"]

### Automation

Say we need a role for automation, as we might have a pipeline in which Testers use to push new configurations or contents into the cluster. So we need to give the ability to automation to create or edit current resources such as deployment, configmaps, and secrets. Thus we would create a role that does all this:

    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
    namespace: staging
    name: staging-role-automation
    rules:
    - apiGroups: ["*"] # Ignoring this for the time being 
    resources: ["deployment", "configmaps", "secrets"]
    verbs: ["create"]

# Role Binding

A role binding grants the permissions defined in a role to a user or set of users

Now that we created rules, we need to attach them to users. For example, we have mumei and miko that are part of the QA/Tester team. So we need to create a role and a rolebding to these users. 

So we need to create a role that does the following:

- Full access to the staging namespace 

        apiVersion: rbac.authorization.k8s.io/v1
        kind: Role
        metadata:
        namespace: staging
        name: staging-role-user
        rules:
        - apiGroups: ["*"] # Ignoring this for the time being 
        resources: ["*"]
        verbs: ["*"]

Simple huh?

Now lets create a rolebinding so the users can use this role as a reference. Not going so much in depth into this, but its pretty straight forward:

        apiVersion: rbac.authorization.k8s.io/v1
        kind: RoleBinding
        metadata:
        name: read-pods
        namespace: staging # namespace is reference
        subjects:
        # You can specify more than one "subject"
        - kind: User
        name: mumei # "name" is case sensitive
        apiGroup: rbac.authorization.k8s.io
        - kind: User
        name: miko # "name" is case sensitive
        apiGroup: rbac.authorization.k8s.io
        roleRef:
        # "roleRef" specifies the binding to a Role / ClusterRole
        kind: Role #this must be Role or ClusterRole
        name: staging-role-user  # this must match the name of the Role or ClusterRole you want to bind to
        apiGroup: rbac.authorization.k8s.io

Lets now apply this to the cluster!

# POP UP QUIZ!!!!!!!!!!!!!!

Fix the issue after kubectl is ran :)

If you weren't able to create the role or are still having issues thats fine. Just run the following command:

 - bash recreate_01.sh 

## Test as User

Now lets create a simple environment 

 - kubectl run nginx --image=nginx -n staging

Now with kubernetes, you can authenticate as a user, but thats a different discussion. Wouldn't it be much easier if we can not authenticate as a user and just run something simple and clean without the hassle

 - kubectl get pods --as mumei -n staging
 - kubectl get pods --as miko -n staging
 - kubectl run test1 --image=redis -n staging --as miko
 - kubectl get pods -n staging --as miko 
 - kubectl delete deployments test1 -n staging --as mumei
 - kubectl get deployments -n staging --as mumei


Going back to rolebindings, after you create a binding, you cannot change the Role or ClusterRole that it refers to. If you try to change a binding's roleRef, you get a validation error. If you do want to change the roleRef for a binding, you need to remove the binding object and create a replacement.

For example, run test2.yaml 

    kubectl apply -f test2.yaml 
    role.rbac.authorization.k8s.io/staging-role-users created
    The RoleBinding "read-pods" is invalid: roleRef: Invalid value: rbac.RoleRef{APIGroup:"rbac.authorization.k8s.io", Kind:"Role", Name:"staging-role-users"}: cannot change roleRef

You will see that even though you added an 's' to the name and made the changes on both role and rolebinding, kubernetes will not allow you to do this action. However the role "users" is still created as its a new role but the old role binding will not change.

- kubectl get roles -n staging 
- kubectl get rolebindings -n staging 

        NAME        ROLE                     AGE
        read-pods   Role/staging-role-user   34m

# Cluster Roles and Cluster Role Binding 

Now that we see that roles are limited to namespaces, what if you have access to the whole cluster.......

For example, we have a staging group that has full access to a namespace. However they would also need access to the production environment but only to read only access along with other namespaces.

So imagine creating a role and role binding for each namespace, thats alot of work sorry.

So say we have a user that needs read only access to the entire cluster as they monitor all the pods and what not. We need to create a user for this.

        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRole
        metadata:
        # "namespace" omitted since ClusterRoles are not namespaced
        name: cluster-reader 
        rules:
        - apiGroups: ["*"]
        resources: ["*"]
        verbs: ["get", "watch", "list"]

Cluster roles are for the cluster and not stuck in one namespace. If you take a look at the meta-data, you would see that the namespace is now missing.

Now that we created a role, we gotta create a role binding for a user names yeti. So lets create a Clsuter Role Binding:
 

        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
        name: cluster-reader-bind
        subjects:
        - kind: User
        name: yeti # Name is case sensitive
        apiGroup: rbac.authorization.k8s.io
        - kind: User
        name: miko # Name is case sensitive
        apiGroup: rbac.authorization.k8s.io
        roleRef:
        kind: ClusterRole
        name: cluster-reader 
        apiGroup: rbac.authorization.k8s.io

#### Exercise 5 

- Create a pod named test-3 in the default namespace
- Create a Cluster Role named cluster-reader based on above
- Create a Cluster Role Binding named cluster-reader-bind based on above

Now lets run the following commands:

    kubectl get pods --as miko
    kubectl get pods --as yeti
    kubectl get pods --as mumei 

Which one of the users is not able to see the pods in the default namespace?


## Lets have some fun!!!!!!!!

There's a kubernetes dashboard in which we can gain access to see whats going on with out cluster. Take a look at the following link[1]                       

Let's create a dashboard!!!!!!!

run the following command:

- kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml


Then we gotta create a Service Account and Cluster Role Binding for this Service Acccount

NOTE: Service account is a role that can be used with the pods

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

Once the users are created, we can grab the token:

    kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}" && echo ""

NOTE: Be careful with the copy and paste!!! i noticed when i ran the original command with the && echo, my username became part of the token and copied part of the name into the token and wasn't able to authenticate. 

Advanced Example:

How can you grab the token from the user above?

Provide the 3 steps below that was done to achieve this:

You can decode file coded_01.txt for the answer 

[1] https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/



kubectl auth can-i create pods --as dev-user 
kubectl auth can-i delete nodes 
