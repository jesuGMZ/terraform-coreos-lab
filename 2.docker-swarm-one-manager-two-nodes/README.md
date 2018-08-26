# Docker Swarm

This sample creates a Docker Swarm using 1 droplet as manager and 2 as nodes. The number of nodes is configurable by Terraform variables.

It also includes:

-   Container Linux Config to provision CoreOS
    -   Auto-updates with a maintenance window
    -   Docker registry auth set-up
-   Shows droplet IP as output
-   Docker manager listen through TCP socket
-   No need to save manager token, thanks to the manager TCP socket nodes can join invoking manager
-   Specific CoreOS config for the manager
