To build:

`make`

To generate docker image:

```
PASS="yourpass"
DOCKER_REGISTRY=registrylpj8163 ./build-push-insurance.sh
```

To Run with logging enabled:

`docker run -p 8081:8081 jsturtevant/insurance:1.0 --log`