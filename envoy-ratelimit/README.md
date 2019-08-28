# Envoy Front Proxy and Lyft Global Ratelimiting integration


## Local Set-up

### Install Vegeta
```
brew update && brew install vegeta
```

### Start Local Test environment

```
docker-compose up
```

#### About the local set-up:

1. It configures 2 nginx servers serving on `9090` and `9091`. They have `GET` and `POST` enabled. 
```
$ curl localhost:9090/nginx_1/
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>This Is Nginx Server Number 1</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

```
```
$ curl localhost:9091/nginx_2/
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>This Is Nginx Server Number 2</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

```

2. Envoy proxy to intercept and relay requests to nginx servers. Envoy admin console can be reached at `localhost:9901`
3. Ratelimiting service to configure rate limits which can be used to envoy. 
4. Redis which is used by the Ratelimiting service.


## Testing

1. All the applicable actions for a particular path in a cluster are aggregated for the result. ( Logical `OR` of the limits)
2. We choose to enable/disable global vhost limits using `include_vh_rate_limits: true` flag. 
3. Scenario 1:\ 
    Case: `GET` request on `/nginx_1/` at 100 requests per second.\ 
    Expected Result: 10% requests successful. ( Logical `OR` of `"descriptor_value": "global"` , `"descriptor_value": "local"`  and `"descriptor_value": "get"` )\
    Command: `echo "GET http://localhost:10000/nginx_1/" | vegeta attack -rate=100 -duration=0 | vegeta report`\
    Actual Result\
    ```
    $ echo "GET http://localhost:10000/nginx_1/" | vegeta attack -rate=100 -duration=0 | vegeta report
    Requests      [total, rate, throughput]  1008, 100.12, 10.92
    Duration      [total, attack, wait]      10.071526192s, 10.06832056s, 3.205632ms
    Latencies     [mean, 50, 95, 99, max]    4.718253ms, 4.514212ms, 7.426103ms, 9.089064ms, 17.916071ms
    Bytes In      [total, mean]              68640, 68.10
    Bytes Out     [total, mean]              0, 0.00
    Success       [ratio]                    10.91%
    Status Codes  [code:count]               200:110  429:898  
    Error Set:                               429 Too Many Requests

    ```
4. Scenario 2:  `POST` request on `/nginx_1/` at 100 requests per second. 
   Expected Result: 50% requests successful. ( Logical `OR` of `"descriptor_value": "global"` and `"descriptor_value": "local"` )
   Command: `echo "POST http://localhost:10000/nginx_1/" | vegeta attack -rate=100 -duration=0 | vegeta report`
   Actual Result: 
   ```
    $ echo "POST http://localhost:10000/nginx_1/" | vegeta attack -rate=100 -duration=0 | vegeta report
    Requests      [total, rate, throughput]  4344, 100.02, 50.56
    Duration      [total, attack, wait]      43.434227783s, 43.429286664s, 4.941119ms
    Latencies     [mean, 50, 95, 99, max]    5.190485ms, 5.224978ms, 7.862512ms, 10.340628ms, 20.573212ms
    Bytes In      [total, mean]              1370304, 315.45
    Bytes Out     [total, mean]              0, 0.00
    Success       [ratio]                    50.55%
    Status Codes  [code:count]               200:2196  429:2148  
    Error Set:                               429 Too Many Requests

   ```
5. Scenario 3: `GET` request on `/nginx_2/` at 100 requests per second with `X-MyHeader: 123`
   Expected Result: 5% requests successful ( Logical `OR` of `"descriptor_value": "global"`, `"descriptor_value": "local"`, `"descriptor_value": "123"`, and `"descriptor_value": "path"`)
   Command: `echo "GET http://localhost:10000/nginx_2/" | vegeta attack -rate=100 -duration=0 -header "X-MyHeader: 123" | vegeta report`
   Actual Result: 
   ```
    $ echo "GET http://localhost:10000/nginx_2/" | vegeta attack -rate=100 -duration=0 -header "X-MyHeader: 123" | vegeta report
    Requests      [total, rate, throughput]  3861, 100.03, 5.18
    Duration      [total, attack, wait]      38.604406747s, 38.597776398s, 6.630349ms
    Latencies     [mean, 50, 95, 99, max]    4.96685ms, 4.673049ms, 7.683458ms, 9.713522ms, 16.875025ms
    Bytes In      [total, mean]              124800, 32.32
    Bytes Out     [total, mean]              0, 0.00
    Success       [ratio]                    5.18%
    Status Codes  [code:count]               200:200  429:3661  
    Error Set:                               429 Too Many Requests  
   ```
6. Scenario 4: `POST` request on `/nginx_2/` at 100 requests per second with `X-MyHeader: 456`
   Expected Result: 5% requests successful ( Logical `OR` of `"descriptor_value": "global"`, `"descriptor_value": "local"`, `"descriptor_value": "post"`, `"descriptor_value": "456"`, and `"descriptor_value": "path"`)
   Command: `echo "POST http://localhost:10000/nginx_2/" | vegeta attack -rate=100 -duration=0 -header "X-MyHeader: 456" | vegeta report`
   ACtual Result: 
   ```
    $ echo "POST http://localhost:10000/nginx_2/" | vegeta attack -rate=100 -duration=0 -header "X-MyHeader: 456" | vegeta report
    Requests      [total, rate, throughput]  2435, 100.04, 5.13
    Duration      [total, attack, wait]      24.346703709s, 24.339554311s, 7.149398ms
    Latencies     [mean, 50, 95, 99, max]    5.513994ms, 5.255698ms, 8.239173ms, 10.390515ms, 20.287931ms
    Bytes In      [total, mean]              78000, 32.03
    Bytes Out     [total, mean]              0, 0.00
    Success       [ratio]                    5.13%
    Status Codes  [code:count]               200:125  429:2310  
    Error Set:                               429 Too Many Requests

   ```
