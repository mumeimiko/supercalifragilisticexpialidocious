1. kubectl run busybox --image=busybox --restart=Never -- /bin/sh -c 'echo hello;sleep 3600'
8a. kubectl run custom-nginx --image=nginx --port=8080
8b. or check file 8.yaml
9. kubectl run numba9 --image=busybox --restart=Never -- /bin/sh -c 'date'
10. kubectl run numba10 --image=busybox --restart=Never -- /bin/sh -c 'hostname; whoami'
