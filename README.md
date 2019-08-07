# Docker-swarm for LIAAD tools

Example of Docker-Swarm deployment using Compute Engine from Google Cloud Platform

## Installation
It's a simple architecture with one manager and two workers.

First using docker-machine, create all nodes :

```bash
docker-machine create swarm-manager -d google --google-project <your_project>
docker-machine create swarm-worker-1 -d google --google-project <your_project>
docker-machine create swarm-worker-2 -d google --google-project <your_project>
```
To see how to connect your Docker Client to the Docker Engine running on these virtual machines run :
```bash
docker-machine env <node_name>
```
Initialize the swarm on the manager node : 
```bash
eval $(docker-machine env swarm-manager);
docker swarm init;
```
Add both workers to the swarm :
```bash
eval $(docker-machine env swarm-worker-1);
docker swarm join --token <token> <manager_ip>:2377;
eval $(docker-machine env swarm-worker-2);
docker swarm join --token <token> <manager_ip>:2377;
```
Create a docker network from the node manager :
```bash
docker network create -d overlay my_network
```
