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
Build NGINX image :
```bash
docker build -t nginx ./nginx-docker
```
Then using ssh add nginx.conf on each node :
```bash
docker-machine ssh <node_name> "touch /home/docker-user/nginx.conf"
docker-machine scp nginx.conf <node_name>:/home/docker-user/nginx.conf
```
Create tools services :
```bash
./services.sh
```
Create a firewall rule to allow users to access TCP port 80 : 
```bash
gcloud compute firewall-rules create nginx-rule \
    --network default \
    --action allow \
    --direction ingress \
    --rules tcp:80 \
```
Create NGINX service listenning port 80 :
```bash
docker service create --name nginx --replicas 1 \ 
--publish published=80,target=80 --network my_network \  
--mount type=bind,src=/home/docker-user/nginx.conf,dst=/etc/nginx/nginx.conf nginx \
```
## Add a new tool
Create a new service using container image from docker hub :
```bash
docker service create --name <name> \
--replicas <number> \
--network my_network <image_name> \
```
Edit nginx.conf adding : 
```bash
  location ~ /<tools>/(.*)$ {
    add_header 'Access-Control-Allow-Origin' '*';
    add_header 'Access-Control-Allow-Methods' 'GET,POST';
    proxy_pass  http://<tools>/$1;
  }
```
Update nginx.conf on each node : 
```bash
./update_file.sh
```
## Test
To access to swagger documentation request [http://<external_ip>/<tools_name>/apidocs/]().
Request examples :
```
curl -X POST -L -v "http://<external_ip>/contamehistorias/conta" -H  
"accept: application/json" -H  "Content-Type: 
application/json" -d "{  \"domains\": [    
\"http://publico.pt/\",    \"http://www.rtp.pt/\",    
\"http://www.dn.pt/\",    \"http://news.google.pt/\"  ],  \"end_date\": 
\"2018-07-21 17:32:28\",  \"query\": \"Dilma 
Roussef\",  \"start_date\": \"2016-07-21 
17:32:28\"}"

curl -X POST "http://<external_ip>/pampo/pampo" 
-H  "accept: application/json" 
-H  "Content-Type: application/json" 
-d "{  \"text\": \"A aldeia piscatória de Alvor está situada no estuário do Rio Alvor e apesar da evolução 
constante do turismo no Algarve, mantém a sua arquitetura baixa e encanto da cidade velha, com 
ruas estreitas de paralelepípedos que nos levam até à Ria de Alvor, uma das belezas naturais mais 
impressionantes de Portugal. Há muitos hotéis em Alvor por onde escolher e adequar às exigências das suas férias, 
quanto a gosto e orçamento, bem como uma série de alojamento autossuficiente para aqueles que preferem ter um pouco 
mais de liberdade durante a sua estadia na Região de Portimão. Há muito para fazer e descobrir em Alvor, 
quer seja passar os seus dias descobrindo a rede de ruas desta encantadora vila de pescadores, explorar as lojas, 
ir para a praia para se divertir entre brincadeiras na areia e mergulhos no mar, ou descobrir 
a flora e fauna da área classificada da Ria de Alvor. O charme de Alvor não se esgota na Vila. 
Ficar hospedado em Alvor vai proporcionar-lhe momento mágicos entre paisagens de colinas, 
lagoas rasas e vistas panorâmicas sobre o Oceano Atlântico. Terá oportunidade de praticar o seu swing num dos campos de 
golfe de classe mundial e explorar as principais atrações históricas e alguns dos segredos mais bem escondidos 
do Algarve, nas proximidades, em Portimão e Mexilhoeira Grande. Consulte a lista dos nossos
 parceiros e escolha o hotel em Alvor, onde ficar durante as suas férias no Algarve.\"}"

```
