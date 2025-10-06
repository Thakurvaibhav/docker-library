# Halyard Dockerfile which can be used to manage spinnaker installations

It is recommended to run this container as pod inside the kubernetes cluster and use persistent volume store to backup of configuration files. 

To test locally, 

`docker-compose up`

You can now attach to the container and run `hal version list` to check whether hal is working fine or not. 

For kubernetes installtion refer: 