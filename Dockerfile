# syntax = docker/dockerfile:1
# we need at least syntax version 1.3 for the cache mount. 1 will use the latest 1.x version syntax

# pull official base image
FROM python:3.11-alpine3.18

# set work directory
WORKDIR /app

# set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONPYCACHEPREFIX=/root/.cache/pycache/ \
    PIP_DISABLE_PIP_VERISON_CHECK=ON \
    PIP_DEFAULT_TIMEOUT=100

# install system dependencies
#RUN \
#  --mount=type=cache,target=/var/cache \
#  apk add \
#  # mkdocs-multirepo-plugin requires this
#  git=2.40.1-r0

# install dependencies
COPY requirements.txt .
RUN \
  --mount=type=cache,target=/root/.cache \
  pip install -r requirements.txt
#RUN \
#  --mount=type=cache,target=/root/.cache \
#  pip install poetry==1.5.1
