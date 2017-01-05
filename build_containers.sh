#!/bin/bash
set -eux

mapfile -t DOCKERFILES < <(git diff-tree --no-commit-id --name-only -r HEAD |grep Dockerfile|grep -v ^D|awk '{print $2}')
GITBRANCH=$(git rev-parse --abbrev-ref HEAD)

for DOCKERFILE in "${DOCKERFILES[@]}"
do
  DOCKERTAG=$(echo ${DOCKERFILE} | awk 'BEGIN {FS="/";} {print $1"-"$2}')
  docker build -t drupalci/${DOCKERTAG}:${GITBRANCH} ./${DOCKERFILE%/Dockerfile}
done
