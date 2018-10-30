# Nginx and VTS-Exporter Docker Files and Kubernetes Deployment

VTS-Exporter is extremely use if you want to monitoring you nginx deployments. It provide stats in prometheus format which can be scraped and also in html.  

Setup:

Build the image: 

1. docker build -t `<your-repo>/nginx-vts:1.0` .  
2. docker push `<your-repo>/nginx-vts:1.0` 
3. docker run -it -p 80:80 `<your-repo>/nginx-vts:1.0` 


Test:

1. Dashboard: `http://localhost/status`
2. Prometheus Format Metrics: `http://localhost/status/format/prometheus`
3. Json Format Metrics: `http://localhost/status/json`


Deeploy to k8's

1. kubectl apply -f `nginx.yaml` (you change change the docker image to `<your-repo>/nginx-vts:1.0` )


Once deployed the metrics (`nginx_vts_*`) should be available in prometheus.  