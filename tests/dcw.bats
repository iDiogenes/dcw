#!/usr/bin/env bats
PATH=$(pwd):$PATH

setup() {
    rm -f .dcw
}

teardown() {
    rm -f .dcw
}

@test "it should fail when running without any command" {
    run dcw
    [ "$status" -eq 2 ]
}

@test "it should fail when running a command without any option" {
    run dcw app ls /
    [ "$status" -eq 3 ]
}

@test "it should fail when running a command only with file option or in .dcw file" {
    run dcw -f tests/fixtures/docker-compose.yml app ls /
    [ "$status" -eq 3 ]

    echo DCW_COMPOSE_FILE_PATH=tests/fixtures/docker-compose.yml > .dcw
    run dcw app ls /
    [ "$status" -eq 3 ]
}

@test "it should display version when running with --version or -V option" {
    run dcw --version
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "dcw 1.0.0" ]

    run dcw -V
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "dcw 1.0.0" ]
}

@test "it should display help when running with --help or -h option" {
    run dcw --help
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Usage: dcw [OPTIONS] CMD" ]

    run dcw -h
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Usage: dcw [OPTIONS] CMD" ]

    run dcw --help -s app
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Usage: dcw [OPTIONS] CMD" ]

    run dcw -h -s app -f tests/fixtures/docker-compose.yml ls /
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Usage: dcw [OPTIONS] CMD" ]
}

@test "it should fail when running a command only with service option" {
    run dcw -s app ls /
    [ "$status" -eq 4 ]

    echo DCW_COMPOSE_SERVICE=app > .dcw
    run  ./dcw app ls /
    [ "$status" -eq 4 ]
}


@test "it should return expected docker-compose command when running in dry-run mode" {

cat > .dcw <<EOF
DCW_COMPOSE_SERVICE=app
DCW_COMPOSE_FILE_PATH=tests/fixtures/docker-compose.yml
DCW_COMPOSE_DEFAULT_RUN_OPTIONS="--rm"
EOF

    # simple command
    run dcw -d echo \"hello\"
    [ "$status" -eq 0 ]
    [ "$output" = "docker-compose --file tests/fixtures/docker-compose.yml run --rm app echo \"hello\"" ]

    # command with some options
    run dcw -d -- ls -lha /
    [ "$status" -eq 0 ]
    [ "$output" = "docker-compose --file tests/fixtures/docker-compose.yml run --rm app ls -lha /" ]

    # service ports
    run dcw -d -p -- ls -lha /
    [ "$status" -eq 0 ]
    [ "$output" = "docker-compose --file tests/fixtures/docker-compose.yml run --rm --service-ports app ls -lha /" ]

    run dcw -d --service-ports -- ls -lha /
    [ "$status" -eq 0 ]
    [ "$output" = "docker-compose --file tests/fixtures/docker-compose.yml run --rm --service-ports app ls -lha /" ]

    # some extra run options
    run dcw -d -r "--name zorg" -- ls -lha /
    [ "$status" -eq 0 ]
    [ "$output" = "docker-compose --file tests/fixtures/docker-compose.yml run --rm --name zorg app ls -lha /" ]

    run dcw -d --run-options "--no-deps" -- ls -lha /
    [ "$status" -eq 0 ]
    [ "$output" = "docker-compose --file tests/fixtures/docker-compose.yml run --rm --no-deps app ls -lha /" ]

    run dcw -d -p --run-options "--no-deps" -- ls -lha /
    [ "$status" -eq 0 ]
    [ "$output" = "docker-compose --file tests/fixtures/docker-compose.yml run --rm --service-ports --no-deps app ls -lha /" ]

    # default run options variant
cat > .dcw <<EOF
DCW_COMPOSE_SERVICE=app
DCW_COMPOSE_FILE_PATH=tests/fixtures/docker-compose.yml
DCW_COMPOSE_DEFAULT_RUN_OPTIONS="--rm --no-deps"
EOF
    run dcw -d -p --run-options "--name zorg" -- ls -lha /
    [ "$status" -eq 0 ]
    [ "$output" = "docker-compose --file tests/fixtures/docker-compose.yml run --rm --no-deps --service-ports --name zorg app ls -lha /" ]
}

# DOCKER INTEGRATION
@test "it should display 'hello' when running printf 'hello' command" {
    #skip
cat > .dcw <<EOF
DCW_COMPOSE_SERVICE=app
DCW_COMPOSE_FILE_PATH=tests/fixtures/docker-compose.yml
DCW_COMPOSE_DEFAULT_RUN_OPTIONS="--rm"
EOF
    run dcw printf hello
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "hello" ]
}
