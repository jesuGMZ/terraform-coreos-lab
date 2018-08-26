# Single droplet with firewall

This sample creates a single droplet and set-up a firewall.

It also includes:

-   Container Linux Config to provision CoreOS
    -   Auto-updates with a maintenance window
    -   Docker registry auth set-up
-   Shows droplet IP as output

Requires:

-    [Terraform Provider for Container Linux Configs](https://github.com/coreos/terraform-provider-ct)
