# Fluentd Dockerfile which can be used as logging agent with ES backend for a Kubernetes Cluster

This image with have the following plugins:

1. fluent-plugin-elasticsearch 
2. fluent-plugin-concat
3. fluent-plugin-kubernetes
4. fluent-plugin-kubernetes_metadata_filter

Modify the dockerfile is you need to add more plugins. 


Setup:

Build the image: 

1. docker build -t `<your-repo>/fluentd:1.0` .  
2. docker push `<your-repo>/fluentd:1.0` 

