# rinha-backend-bash

Versão Bash da [rinha do backend](https://github.com/zanfranceschi/rinha-de-backend-2023-q3) 

## Requisitos

* Bash 
* [Docker](https://docs.docker.com/get-docker/)
* [curl](https://curl.se/download.html)
* [Gatling](https://gatling.io/open-source/), a performance testing tool
* _Maizena_

## Usage

```bash
$ make help

Usage: make <target>
  help                       Prints available commands
  start.dev                  Start the rinha in Dev
  start.prod                 Start the rinha in Prod
  docker.stats               Show docker stats
  health.check               Check the stack is healthy
  stress.it                  Run stress tests
  docker.build               Build the docker image
  docker.push                Push the docker image
```

## Stack

* Bash
* PostgreSQL
* NGINX
