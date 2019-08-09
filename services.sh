docker service create --name contamehistorias --replicas 2 --publish target=8000 --network my_network 329719/contamehistorias;
docker service create --name pypampo --replicas 2 --publish target=8000 --network my_network 329719/pypampo;
docker service create --name flasgger --replicas 2 --publish target=8000 --network my_network 329719/flasgger;
