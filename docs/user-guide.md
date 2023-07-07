# User Guide

## Introduction

### What is it

Mkdocs is a static site generator for documentation that converts markdown to html.

### Why we use it

It comes with tools to help create documentation that's pleasing to read and easy to maintain.

??? info "Here's a list of useful features not available in plain markdown"

    ??? example "Dead link checker"

        Github wiki doesn't check for broken links.

    ??? example "[Tabbed content](https://facelessuser.github.io/pymdown-extensions/extensions/tabbed/)"

        === "Linux"

            linux-specific content

        === "Mac"

            mac-specific content

    ??? example "Site table of contents"

        See the contents of the site in the left sidebar.

    ??? example "Per-page table of contents"

        See the contents of the current page in the right sidebar.

    ??? example "Code and text annotations"

        ``` bash
        Click the plus sign --> # (1)!
        ```

        1. This is an explanation text

    ??? example "[Expandable text blocks](https://facelessuser.github.io/pymdown-extensions/extensions/blocks/plugins/details/)"

        That's what this box is!

### Why we made a docker image for it

We want to make it very easy for Hack for LA projects to maintain documentation. Having a docker image allows:

- Hack for LA
    - one location to setup and update the mkdocs installation for all projects
- Projects
    - to save time on mkdocs setup
    - the flexibility to customize configuration
- Developers
    - to save time by not having to install mkdocs locally
    - to use a simple command to serve and work on documentation

## Mkdocs docker image

### How to use it

#### Add it to a project

##### Setup the local mkdocs service

1. Create `docker-compose.yml`.

    ```yaml title="docker-compose.yml"
    version: "3.9"
    services:
      mkdocs:
        image: hackforlaops/mkdocs:latest # (1)!
        # build:
        #   context: .
        #   dockerfile: Dockerfile
        command: mkdocs serve -a "0.0.0.0:8000" # (2)!
        ports:
          - "8005:8000" # (3)!
        volumes:
          - .:/app # (4)!
    ```

    1. Use the pre-built image file from this project.
    1. Expose the site to all IPs. This enables browsing the site from another local computer.
    1. Expose the site on port 8005, in case 8000 is in use by the project.
    1. Map the current directory to the `/app` directory in the container. The current directory is expected to have a `docs/` directory.

##### Setup the mkdocs project

=== "Create a new one"

    Use the docker image to create the new project

    ``` bash
    docker-compose run mkdocs \
    mkdocs new . # (1)!
    ```

    1. docker-compose run executes a command from a new docker image container. In this case, inside the mkdocs container, execute `mkdocs new .` (note the period for the current directory).

=== "Copy an existing one"

    1. Copy the `mkdocs.yml` and the `docs/` directory from an existing repo, such as this one.
    1. Update the configurations in `mkdocs.yml` to your project's info.

#### Work on docs locally

1. Run the mkdocs server from the container

    ```bash
    docker-compose up # (1)!
    ```

    1. Optionally use the `-d` flag to run the container in the background

1. Open a browser to [`http://localhost:8005/`](https://localhost:8005/) to view the documentation locally

1. Modify the files in the docs directory. The site will auto-update when the files are saved.

1. Quit

    ++ctrl+c++ to quit the local server and stop the container

### Extend the image

If your project wants to try other mkdocs plugins not in the hackforla image, here's a way to extend the image on your own before asking to add it to the hackforla image.

!!! info "The hackforla image is built from [hackforla/mkdocs-docker](https://github.com/hackforla/ghpages-docker), where the mkdocs plugins are listed in `pyproject.toml`."

#### Get poetry

1. Add your own `Dockerfile` to install the plugin for local usage that also installs poetry

    ```docker title="Dockerfile.mkdocs" hl_lines="21-23"
    # base image
    FROM hackforlaops/mkdocs:latest

    # set work directory
    WORKDIR /app

    # install system dependencies
    # (2)!
    #RUN \
    #  --mount=type=cache,target=/var/cache \
    #  apk add \
    #  # mkdocs-multirepo-plugin requires this
    #  git=2.40.1-r0

    # install dependencies
    # (1)!
    COPY requirements.txt .
    RUN \
      --mount=type=cache,target=/root/.cache \
      pip install -r requirements.txt
    RUN \
      --mount=type=cache,target=/root/.cache \
      pip install poetry==1.6.1

    ```

    1. Python plugins should be specified in requirement.txt to be installed.
    1. Remove or comment out the block unless the plugin requires non-python packages.

1. Reference the new Dockerfile in the docker-compose file

    ```yaml title="docker-compose.yml" hl_lines="3-6"
    ...
      mkdocs:
          #image: hackforlaops/mkdocs:latest
          build:
            context: .
            dockerfile: Dockerfile.mkdocs
    ...
    ```

1. Build the image.

    ```bash
    docker-compose build
    ```

#### Add the new plugin

Now that we have poetry, we can use it to add the plugin.

1. Create a pyproject.yml similar to the one in this repo.

    === "Generate one using poetry"

        ```bash
        docker-compose run mkdocs poetry init # (1)!
        ```

        1. Do not call the project `mkdocs` since that's the name of a real project.

    === "Copy or create one manually"

        ```yaml title="pyproject.yml"
        [tool.poetry]
        name = "project-name"
        version = "0.1.0"
        description = ""
        authors = []
        readme = "README.md"

        [tool.poetry.dependencies]
        python = "^3.11.4" # (1)!

        [build-system]
        build-backend = "poetry.core.masonry.api"
        requires = [
          "poetry-core",
        ]
        ```

        1. This is the python version in the `hackforla/docker-mkdocs/pyproject.toml` file. It can also be the version that's in the `hackforla/docker-mkdocs/Dockerfile`.

1. Add the new plugin

    ``` bash
    # (1)!
    docker-compose run mkdocs \
    poetry add mkdocs-awesome-pages-plugin --group docs # (2)!
    ```

    1. This docker-compose command runs the second line inside the docker container
    2. Add (install) mkdocs-awesome-pages to pyproject.toml under the docs group. This is in case your project also uses poetry and need to separate the docs dependencies from the rest.

#### Build the image

1. Export the requirements.txt

    ``` bash
    docker-compose run mkdocs \
    poetry export -f requirements.txt --without-hashes --with docs > requirements.txt # (1)!
    ```

    1. Export dependencies, including the docs group, in requirements.txt format, to requirements.txt.

1. Build and run the docker image with the new plugin

    ``` bash
    docker-compose up --build
    ```

#### Use the plugin

1. Add any configuration to `mkdocs.yml`
1. Use the plugin in the documentation
1. Test that the plugin works

#### Add it to the hackforla image

If the plugin works well for your project, and you would like it to be added at the organization level. Please do as much of the following as you can.

1. Create a documentation page about the plugin: What it is, how it's useful, how to use it. etc..
1. Create a PR in `hackforla/docker-mkdocs` with the necessary changes to add the plugin, including the documentation page.
1. Follow up in slack, maybe in the hackforla #engineering channel.
