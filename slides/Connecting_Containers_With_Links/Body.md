<!SLIDE>
# How *links* work

* Links are created *between two containers*
* Links are created *from the client to the server*
* Links associate an arbitrary name to an existing container
* Links exist *only in the context of the client*

<!SLIDE printonly>
# The plan

* We will create the `redis` container first.
* Then, we will create the `www` container, *with a link to the previous container.*
* We don't need to use a custom network for this to work.

<!SLIDE printonly>
# Create the `redis` container

Let's launch a container from the `redis` image.

    @@@ Sh
    $ docker run -d --name datastore redis
    <yourContainerID>

Let's check the container is running:

    @@@ Sh
    $ docker ps -l
    CONTAINER ID   IMAGE          COMMAND        ...   PORTS      NAMES
    9efd72a4f320   redis:latest   redis-server   ...   6379/tcp   datastore


* Our container is launched and running an instance of Redis.
* We used the `--name` flag to reference our container easily later.
* We could have used *any name we wanted.*

<!SLIDE printonly>
# Create the `www` container

If we create the web container without any extra option, it will not be able to connect to redis.

    @@@ Sh
    $ docker run -dP jpetazzo/trainingwheels

Check the port number with `docker ps`, and connect to it.

We get the same red error page as before.

<!SLIDE printonly>
# How our app connects to Redis

Remember, in the code, we connect to the name `redis`:

    @@@ Python
    redis = redis.Redis("redis")

* This means "try to connect to 'redis'".
* Not 192.168.123.234.
* Not redis.prod.mycompany.net.

*Obviously* it doesn't work.

<!SLIDE printonly>
# Creating a linked container

Docker allows to specify *links*.

Links indicate an intent: "this container will connect to this other container."

Here is how to create our first link:

    @@@ Sh
    $ docker run -ti --link datastore:redis alpine sh

In this container, we can communicate with `datastore` using
the `redis` DNS alias.

<!SLIDE printonly>
# DNS

Docker has created a DNS entry for the container, resolving to its internal IP address.

    @@@ Sh
    $ docker run -it --link datastore:redis alpine ping redis
    PING redis (172.17.0.29): 56 data bytes
    64 bytes from 172.17.0.29: icmp_seq=0 ttl=64 time=0.164 ms
    64 bytes from 172.17.0.29: icmp_seq=1 ttl=64 time=0.122 ms
    64 bytes from 172.17.0.29: icmp_seq=2 ttl=64 time=0.086 ms
    ^C--- redis ping statistics ---
    3 packets transmitted, 3 packets received, 0% packet loss
    round-trip min/avg/max/stddev = 0.086/0.124/0.164/0.032 ms


* The ``--link`` flag connects one container to another.
* We specify the name of the container to link to, ``datastore``, and an
  alias for the link, ``redis``, in the format ``name:alias``.

<!SLIDE printonly>
# Starting our application

Now that we've poked around a bit let's start the application itself in
a fresh container:

    @@@ Sh
    $ docker run -d -P --link datastore:redis jpetazzo/trainingwheels

Now let's check the port number associated to the container.

    @@@ Sh
    $ docker ps -l

<!SLIDE printonly>
# Confirming that our application works properly

Finally, let's browse to our application and confirm it's working.

    @@@ Sh
    http://<yourHostIP>:<port>

<!SLIDE>
# Links and environment variables

In addition to the DNS information, Docker will automatically set environment variables in our container, giving extra details about the linked container.

    @@@ Sh
    $ docker run --link datastore:redis alpine env
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    HOSTNAME=0738e57b771e
    REDIS_PORT=tcp://172.17.0.120:6379
    REDIS_PORT_6379_TCP=tcp://172.17.0.120:6379
    REDIS_PORT_6379_TCP_ADDR=172.17.0.120
    REDIS_PORT_6379_TCP_PORT=6379
    REDIS_PORT_6379_TCP_PROTO=tcp
    REDIS_NAME=/dreamy_wilson/redis
    REDIS_ENV_REDIS_VERSION=2.8.13
    REDIS_ENV_REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-2.8.13.tar.gz
    REDIS_ENV_REDIS_DOWNLOAD_SHA1=a72925a35849eb2d38a1ea076a3db82072d4ee43
    HOME=/
    RUBY_MAJOR=2.1
    RUBY_VERSION=2.1.2


* Each variables is prefixed with the link alias: ``redis``.
* Includes connection information PLUS any environment variables set in
  the ``datastore`` container via ``ENV`` instructions.

<!SLIDE>
# Differences between network aliases and links

* With network aliases, you can start containers in *any order.*
* With links, you have to start the server (in our example: Redis) first.
* With network aliases, you cannot change the name of the server once it is running. If you want to add a name, you have to create a new container.
* With links, you can give new names to an existing container.
* Network aliases require the use of a custom network.
* Links can be used on the default bridge network.
* Network aliases work across multi-host networking.
* Links (as of Engine 1.11) only work with local containers (but this might be changed in the future).
* Network aliases don't populate environment variables.
* Links give access to the environment of the target container.

<!SLIDE printonly>
# Section summary

We've learned how to:

* Create links between containers.
* Use names and links to communicate across containers.

