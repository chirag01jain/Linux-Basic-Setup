#### Tools for testing Load balancer connectivity

##### 1) Install Apache bench for load testing and benchmarking LB performance:
```
1) Deploy a Ubuntu 18.04 server
2) apt-get update
3) apt-get install apache2-utils
4) ab -V
```

Example:

##### Send 5000 requests (-n) with the concurrency (-c) of 5K :: 

> ab -n 5000 -c 500 http://dl.cjain.biz/

#### 2) Install seige ::  HTTP load test utility supported on UNIX

Example: Test with 500 concurrent requests for 5 seconds.
> siege -q -t 5S -c 500 http://dl.cjain.biz/

