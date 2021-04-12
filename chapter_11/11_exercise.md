1. Create a daemonset called waffle with the following label watermelon:margarita. 
  - Name: waffle
  - Label: watermelon:margarita
  - Image: quay.io/fluentd_elasticsearch/fluentd:v2.5.2
2. Create a pod named bts with an init container that should be able to do a nslookup on google.com
