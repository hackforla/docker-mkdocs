# Maintainer Guide

## Project layout

``` yaml title="Project structure"
├── docker-compose.yml # Config to tag and run the image container
├── Dockerfile         # Instructions to build the image
├── docs/              # Contains documentation pages
├── mkdocs.yml         # MkDocs configs
├── pyproject.toml     # Poetry configs
├── requirements.txt   # Python packages list (generated)
└── scripts
    └── export_requirements.sh # Generates the requirements file
```

We are following this [guide for multiplatform builds](https://docs.docker.com/build/ci/github-actions/multi-platform/). It recommends a matrix strategy if we ever need to add more platforms.

## How to run MkDocs

These are the ways to run MkDocs within this project.

=== "Docker"

    #### Docker

    This option is required for the other maintenance steps below.

    1. Build the image

        ``` bash
        docker-compose build
        ```

    1. Start the container

        ``` bash
        docker-compose up
        ```

    1. Open a browser to `http://localhost:8000/` to view the documentation locally

    1. Modify the files in the `docs/` directory. The site will auto update when the files are saved.

    1. Quit

        ++ctrl+c++ to quit the local server and stop the container

=== "Local install (pip)"

    #### Local Install (pip)

    python should be version 3

    1. Install mkdocs

        ``` bash
        pip install -r requirements.txt
        ```

    1. Start the local server

        ``` bash
        mkdocs serve -a localhost:8000
        ```

    1. Open a browser to `http://localhost:8000/` to view the documentation locally

    1. Modify the files in the `docs/` directory. The site will auto update when the files are saved.

    1. Quit

        ++ctrl+c++ to quit mkdocs

=== "Local install (poetry)"

    #### Local Install (poetry)

    python poetry must be installed in the local system. We recommend installing via pipx into an isolated environment.

    1. Install mkdocs

        ``` bash
        poetry install
        ```

    1. Start the local server

        ``` bash
        poetry run mkdocs serve -a localhost:8000
        ```

    1. Open a browser to `http://localhost:8000/` to view the documentation locally

    1. Modify the files in the `docs/` directory. The site will auto update when the files are saved.

    1. Quit

        ++ctrl+c++ to quit mkdocs

## How to update the package versions

Staying updated may give us speed improvements (python), better security, and bugfixes. Docker hub, for example, can scan image layers to find packages with security advisories. These are the steps to update the package versions.

1. [Add poetry to the container](poetry.md/#how-to-add-poetry-to-the-running-container)

1. Update packages using poetry

    ``` bash
    docker-compose exec mkdocs sh -c "poetry update"
    ```

1. Export `requirements.txt`

    === "script"

        ``` bash
        ./scripts/export_requirements.sh
        ```

    === "command"

        ``` bash
        # (1)!
        docker-compose exec mkdocs \
        poetry export -f requirements.txt > requirements.txt # (2)!
        ```

        1. This docker-compose command runs the second line inside the docker container
        2. Export in requirements.txt format, to requirements.txt.

1. Commit the requirements file

    ``` bash
    git add requirements.txt poetry.lock
    git commit -m"chore: update package versions"
    ```

1. Once merged into `main`, the CI will build the new image and upload it with the `latest` tag.

## How to add an MkDocs plugin

Let's say we want to add the `mkdocs-multirepo-plugin`.

1. [Add poetry to the container](poetry.md/#how-to-add-poetry-to-the-running-container)

1. Install the new MkDocs plugin

    ``` bash
    docker-compose exec mkdocs sh -c "poetry add mkdocs-multirepo-plugin"
    ```

1. Export `requirements.txt`

    === "script"

        ``` bash
        ./scripts/export_requirements.sh
        ```

    === "command"

        ``` bash
        # (1)!
        docker-compose exec mkdocs \
        poetry export -f requirements.txt > requirements.txt # (2)!
        ```

        1. This docker-compose command runs the second line inside the docker container
        2. Export in requirements.txt format, to requirements.txt.

1. Add any system dependencies in the `Dockerfile`

    We're adding git here, which is a dependency of mkdocs-multirepo-plugin

    ```docker title="Dockerfile"
    ...
    # install system dependencies
    RUN \
      --mount=type=cache,target=/var/cache \
      apk add \
      git=2.40.1-r0
    # (1)!
    ...
    ```

    1. Mount the `/var/cache` directory as cache in docker when running the command

1. Commit `requirements.txt` and `Dockerfile`

    ``` bash
    git add requirements.txt Dockerfile pyproject.toml poetry.lock
    git commit -m"feat: add plugin mkdocs-multirepo-plugin"
    ```

1. Once merged into `main`, the CI will build the new image and upload it with the `latest` tag.

??? info "How we set it up"

    ## Setup from scratch

    Here's the recommended setup, from our experience setting it up.

    ### Project directory

    ``` bash
    mkdir mkdocs-notes && cd $_
    ```

    ### Poetry project

    ``` bash
    poetry init —name docs —description “Project Documentation” # (1)!
    # use a modern stable python like version 3.11.4
    # don’t define dependencies interactively
    ```

    1. We chose poetry because it performs multiple useful functions such as creating the virtual environment and dependency management. It will be easy to update to the latest versions of dependencies.

    ### Mkdocs package

    ``` bash
    poetry run poetry add mkdocs
    ```

    ### Mkdocs project

    ``` bash
    mkdocs new . # creates mkdocs project in current directory
    ```

    ### Local dev server

    ``` bash
    mkdocs serve —dev-addr 0.0.0.0:8000 # (1)!
    ```

    1. Start the dev server locally on any address on port 8000.
    This is useful for development from a different local network computer, where the default localhost won’t work

    ### Material theme

    ``` bash
    poetry add mkdocs-material
    cat "theme: material" >> mkdocs.yml
    git ci -a -m"setup material theme for mkdocs"
    ```

    ### ~~Multirepo~~ (not yet working)
    ``` bash
    poetry add mkdocs-multirepo-plugin
    # add the plugin in mkdocs.yml
    # import the other repos in mkdocs.yml
    ```

    ### Export requirements

    We need to export the requirements whenever we add a new package, so that the docker setup and pip users can know to use it.

    ``` bash
    # (1)!
    poetry export -f requirements.txt > requirements.txt
    ```

    1. This is also contained in a script `export_requirements.sh` in the scripts directory

    ### Deployment to Github Pages

    We closely followed [this guide](https://squidfunk.github.io/mkdocs-material/publishing-your-site/).
    This setup creates a gh-pages branch to store the latest docs. Make the necessary configurations in the Github repo settings as necessary under Pages.

    ### Docker setup

    We modified the dockerfile and docker-compose files from People Depot to install and serve mkdocs locally.
    The files are `docker-compose.yml` and `Dockerfile`.
