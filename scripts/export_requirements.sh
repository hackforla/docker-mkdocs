#!/bin/bash
set -eux

docker-compose exec mkdocs sh -c "set -eux;
poetry export -f requirements.txt > requirements.txt;
"
#docker-compose -f docker-compose.yml run mkdocs sh -c "poetry update &&
#poetry export -f requirements.txt > requirements.txt --with dev"
