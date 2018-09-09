# Docker Swarm with node labels

This sample creates a Docker Swarm using 1 droplet as manager and 3 as nodes. One of the nodes is tagged as type _database_ and the two remaining type _general_.

When you create a Docker Swarm service, you can use node labels as a constraint. A constraint limits the nodes where the scheduler deploys tasks for a service. The idea of this example is to use always the same node for the database, or any other stateful container such as middle cache, to persist data so the storage of the database can be re-attached anytime for a new database container even after updates or restarts. To accomplish this, the database service has to be created as follow:

```sh
docker service create \
  --mount type=bind,src=<HOST-PATH>,dst=<CONTAINER-PATH> \
  --name my-service-name \
  --constraint type==database \
  <DATABASE_IMAGE>
```

This PoC will use the Docker volume driver _local_ and is written for only one stateful container in mind. For HA, multi-storage platform, decentralized or any other special feature consider to use a container storage orchestration engine like [REX-Ray](https://rexray.io/).

It also includes:

-   Container Linux Config to provision CoreOS
    -   Auto-updates with a maintenance window
    -   Docker registry auth set-up
-   Shows droplet IP's as output
-   Docker manager listen through TCP socket
-   No need to save manager token, thanks to the manager TCP socket nodes can join invoking manager
-   Specific CoreOS config for the manager
-   Firewall configuration

Requires:

-   [Terraform Provider for Container Linux Configs](https://github.com/coreos/terraform-provider-ct)
