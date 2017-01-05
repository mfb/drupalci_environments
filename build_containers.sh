#!/bin/bash
set -eux
####
# This script looks for changes to the docker files and rebuilds the containers based on
# which docker files were changed in the last commit.
#
####


mapfile -t DOCKERFILES < <(git diff-tree --no-commit-id --name-status -r HEAD |grep Dockerfile|grep -v ^D|awk '{print $2}')
GITBRANCH=$(git rev-parse --abbrev-ref HEAD)

for DOCKERFILE in "${DOCKERFILES[@]}"
do
  DOCKERTAG=$(echo ${DOCKERFILE} | awk 'BEGIN {FS="/";} {print $1"-"$2}')
  docker build -t drupalci/${DOCKERTAG}:${GITBRANCH} ./${DOCKERFILE%/Dockerfile}
done
