# DockerHub

Docker Hub is a container registry hosted by Docker. It is the default whenever docker requests an image. Hosting our image here ensures that it's accessible by anyone.

## getting started

??? note "References"
    ```
    https://docs.docker.com/docker-hub/quickstart/
    https://www.linux.com/training-tutorials/how-use-dockerhub/
    ```

    [todo: connect a repository to a package](https://docs.github.com/en/packages/learn-github-packages/connecting-a-repository-to-a-package)

??? note "old notes"
    I created a repo in my account called local-mkdocs
    The follow commands logs into dockerhub, tags the local image as testing, and pushes it to dockerhub

    ```bash
    docker login --username=hackforlaops
    docker images
    docker tag b6047b203915 hackforlaops/local-mkdocs:testing
    docker push hackforlaops/local-mkdocs:testing
    ```

## How to create an access token

### Token vs password

Docker tokens can be passed in as docker passwords. The difference is passwords can be renewed while tokens remain in use. Tokens are created with different access levels and can be revoked individually for different clients.

We need write access to be able to push images, but not the ability to delete them, so a token is the better way.

### Create the token

1. Create New Access Token in DockerHub.

    1. In the upper-right, click on your username > Account Settings list item > Security tab
    1. Click the ++"New Access Token"++ button
    1. For the Description, enter `docker-mkdocs action push`
    1. For Permissions, choose `Read, Write`
    1. Click the ++"Generate"++ button
    1. Copy and save the token

1. Test login with the token

    ```bash
    docker login -u hackforlaops
    Password: # pass in the token at the prompt
    ...
    Login succeeded
    ```

1. Test tag and push the image

    ```bash
    docker images
    docker tag b6047b203915 hackforlaops/mkdocs:testing # (1)!
    docker push hackforlaops/mkdocs:testing
    ```

    1. The hash value is from the images list for the docker-mkdocs image in the local system

## Create workflow

??? note "References"
    https://github.com/docker/login-action

1. Create action secrets in github so that different forks can configure and push to their own dockerhub accounts

    ```bash
    DOCKER_USERNAME
    DOCKER_TOKEN
    ```

1. See `.github/workflows/build-image.yml` for complete configuration
