# dcw

dcw is docker compose wrapper to simplify everyday dev work with containers.

## Installation

```shell
curl -o /usr/local/bin/dcw -fsSL https://github.com/rezzza/dcw/raw/master/dcw \
&& chmod a+x /usr/local/bin/dcw
```

## Usage

```shell

Usage: dcw [OPTIONS] CMD

  A docker compose wrapper to simplify everyday dev work with containers

    -f, --file             Path to the docker compose file
    -s, --service          Name of docker compose service to run
    -p, --service-ports    Run command with the service's ports enabled and mapped
    -r, --run-options      Extra docker-compose run options (quote them)
    -h, --help             Display this usage description
    -v, --verbose          Display executed docker-compose command
    -d, --dry-run          Display docker-compose command aims to be executed
    -V, --version          Return dcw version

  You can also configure following environment variables, either putting then
  into a .dcw file in the current execution path of the command OR by
  exporting them.

    DCW_COMPOSE_FILE_PATH
    DCW_COMPOSE_DEFAULT_RUN_OPTIONS
    DCW_COMPOSE_SERVICE

  Most useful use cases examples:

    Run a simple command
    $ dcw ls /

    Run a command with some options
    $ dcw -- ls -lha /

    Run a command on a service wich need to bind ports
    $ dcw -p npm start /

```

### Advanced usage

When you're used to develop on some project repository, you probably want
preset some options to not repeat yourself typing commands.

So you can simply create a `.dcw` file at the root of your repository.

`.dcw` file example:
```shell
cat > .dcw <<EOL
DCW_COMPOSE_FILE_PATH=docker/dev.myapp.mycompany/docker-compose.yml
DCW_COMPOSE_DEFAULT_RUN_OPTIONS="--rm --no-deps"
DCW_COMPOSE_SERVICE="app"
EOL
```
