this section will host nginx documentation



12/6/23
Here is the structure of our nginx project.
It will be dockerized and part of a docker-compose project.
The Nginx network will be the basis of the docker-compose network, attached to which will be docker-compose projects containing all websites & web apps on the Linux server.


So, now that we can run our terraform + yaml combination from our CLI, using secrets we dynamically extract from 1password, we can apply the same process via Github Actions CICD, where:
- Github Actions CICD spins up a temporary linux server
- That linux server, which has access to our repo's github secrets then inserts the secrets' values into the tf script, and it boots up our server for us.
- Then, that temporary linux server can move to the next step: creating our nginx-certbot docker container, to allow encrypted web traffic to flow into our servers.  That process will be setup as follows:

- a nginx main conf file (also in the docker container)
- a nginx sub-conf file for each project, for example:
  - the basic http test connection
    - a server block plus an json file
    - a CICD process which attempts a "health check" to ensure the json file can be reached
  - the https test connection.
    - Once our automatic verification checks that http traffic is flowing, then we repeat the above, except via https:
    -  a server block plus an json file.  Checked for connectivity with a "health check"
  - now that we verify http & https are working, we can continue on:
  - a serverblock for every subsequent app or website we add to the server.

1. First, a basic http server will be setup and tested for traffic.  It will fit into our overall nginx setup because we'll have a main nginx conf file, and we'll have sub-conf files.  The http server will be its own sub-conf file.