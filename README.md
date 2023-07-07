# Docker MkDocs

This repo contains the source code to build the docker image used by Hack for LA developers to work on MkDocs documentation. The image enables the deployment of a local MkDocs website with a single command.

The image is hosted at [Hack for LA's repo](https://hub.docker.com/r/hackforlaops/mkdocs) on DockerHub. It contains MkDocs and plugins used by Hack for LA projects. We will update the plugins list and package versions as needed.

For full documentation, visit [https://hackforla.github.io/docker-mkdocs](https://hackforla.github.io/docker-mkdocs).

## Project Context

At Hack for LA, we have projects that utilize many different core technologies. We chose MkDocs which is a documentation site generator that works well with any of them. We provide this docker image as an option for projects so they won't have to go through the setup steps on their own.

### For Projects

Projects can use the image by referencing it directly in a docker-compose.yml or the commandline. The recommended way is to create a docker-compose.yml file. See the User Guide for instructions. From there, projects are free to configure the site as needed.

Projects can also extend the image to add MkDocs plugins and dependencies if needed. See the User Guide for instructions

When it's determined useful, projects can request that their plugin be incorporated into this image by opening a pull request from a fork.

### For Maintainers

Maintainers can update package versions, add MkDocs plugins, or add system dependencies. See the Maintainer Guide for details.

Maintainers can build and upload a test image to the docker hub repository for testing. Once the main branch is updated, the github workflow will build and push an image to docker hub. See the Maintainer Guide for details.

## Technology used

- [python](https://docs.python.org/3/)
- [mkdocs](https://www.mkdocs.org/getting-started/)
- [docker](https://docs.docker.com)
- [github actions](https://docs.docker.com/build/ci/github-actions/)
- [docker hub](https://docs.docker.com/get-started/)
- [poetry](https://python-poetry.org/docs/)

## Contact info

Please post in the #engineering hackforla slack channel for any issues.

## Licensing

This code is made available under the [GNU General Public Licence v2.0](LICENSE)
