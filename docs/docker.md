# Docker

## How to remove extra project files from docker image

We use the `.dockerignore` file for this. It marks project files to skip when building the docker image.

1. Look into the image to find extra unneeded files

    1. Run a shell in the docker image

        ``` bash
        docker run -it image_name sh
        ```

    1. Look at the directory structure

        ``` bash
        ls
        ```

1. Add the extra files and paths in `.dockerignore`

1. Rebuild the image

## Cache mount

This helps speed up subsequent docker builds by caching intermediate files and reusing them across builds. It's available with docker buildkit. The key here is to disable anything that could delete the cache, because we want to preserve it. The cache mount is not going to end up in the docker image being built, so there's no concern about disk space usage.

Put this flag between `RUN` and the command

``` docker hl_lines="2"
RUN \
--mount=type=cache,target=/root/.cache
  pip install -r requirements.txt
```

For pip, the files are by default stored in `/root/.cache/pip`.  [Pip caching docs](https://pip.pypa.io/en/stable/topics/caching/)
For apk, the cache directory is `/var/cache/apk/`. [APK wiki on local cache](https://wiki.alpinelinux.org/wiki/Local_APK_cache)

??? info "References"
    - [buildkit mount the cache](https://vsupalov.com/buildkit-cache-mount-dockerfile/)
    - [proper usage of mount cache](https://dev.doroshev.com/blog/docker-mount-type-cache/)
    - [mount cache reference](https://docs.docker.com/engine/reference/builder/#run---mounttypecache)

## Reducing the image size

There are methods to do this on many levels. All of these methods contribute to reduce the final image size, either by skipping generation of intermediate files or by removing them afterward. We list the commonly-recommended methods here although we opted to use cache mount instead, which speeds up image rebuilds. The methods discussed here may be more suitable for a CI environment.

!!! Note "`mkdocs-material` `babel` dependency

    `mkdocs-material` theme added `babel` as a dependency starting at version 9.2. As a result, the docker image size increased from <30MB to around 40MB. This is unavoidable.

### Docker

1. Docker cache mount

    We use this method instead of ones which disable caching. See [cache mount](#cache-mount) above. There's no need to delete any files since they're in a cache mount that's not part of the docker image.

### Python

1. Skip bytecode (.pyc) generation

    [Python docs on `PYTHONDONTWRITEBYTECODE`](https://docs.python.org/3/using/cmdline.html#envvar-PYTHONDONTWRITEBYTECODE)

    === "env variable"

        Set this environment variable

        ``` docker
        ENV PYTHONDONTWRITEBYTECODE 1
        ```

    === "command env"

        Set the `-B` flag for python

        ``` docker
        RUN python3 -B -m pip install -r requirements.txt
        ```

1. Pycache prefix and rm

    [Python docs on `PYTHONPYCACHEPREFIX`](https://docs.python.org/3/using/cmdline.html#envvar-PYTHONPYCACHEPREFIX)

    1. Tell python to write `.pyc` files in a mirror directory

        === "env variable"

            Set this environment variable to make python store all pycache bytecode files under some directory

            ``` docker
            ENV PYTHONPYCACHEPREFIX=/root/.cache/pycache/
            ```

        === "flag"

            Use the commandline flag for python

            ``` docker
            RUN python3 -X pycache_prefix=/root/.cache/pycache/ -m pip install -r requirements.txt
            ```

    1. Remove the files in the same RUN command by appending this to the end

        ``` bash
        && rm -rf /root/.cache/pycache/
        ```

### Pip

1. Don't compile python into byte code

    Pass the flag into pip to skip generating `pyc` files during install

    ``` docker
    RUN pip install --no-compile -r requirements.txt
    ```

1. Disable caching

    [Pip docs on caching](https://pip.pypa.io/en/stable/topics/caching/)

    === "env variable"

        Set this environment variable

        ``` bash
        ENV PIP_NO_CACHE_DIR=1
        ```

    === "flag"

        Pass this flag into pip

        ``` bash
        RUN pip install --no-cache-dir -r requirements.txt
        ```

## Clean build

Combineable flags can be passed into a docker or docker-compose build to force a clean build. See [docker build options](https://docs.docker.com/engine/reference/commandline/build/#options)

1. Try to download the latest base image

    ``` bash
    docker-compose build --pull
    ```

1. Disable caching. Build everything

    ``` bash
    docker-compose build --no-cache
    ```
