#/bin/bash
kubectl create namespace staging  > /dev/null 2>&1
cat  <<EOF | kubectl apply -f -
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: staging
  name: staging-role-user
rules:
- apiGroups: ["*"] # Ignoring this for the time being 
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: staging
subjects:
- kind: User
  name: mumei # "name" is case sensitive
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: miko # "name" is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role #this must be Role or ClusterRole
  name: staging-role-user # this must match the name of the Role or ClusterRole you want to bind to
  apiGroup: rbac.authorization.k8s.io
EOF
