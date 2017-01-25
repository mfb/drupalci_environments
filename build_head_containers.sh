#!/bin/bash
set -eux
####
# This script looks for changes to the docker files and rebuilds the containers based on
# which docker files were changed in the last commit.
#
####

GITBRANCH=${1}

mapfile -t DOCKERFILES < <(ls -1 php/*.x-apache/Dockerfile)

if [[ ! -z "${DOCKERFILES-}" ]]; then
    for DOCKERFILE in "${DOCKERFILES[@]}"
    do
      DOCKERTAG=$(echo ${DOCKERFILE} | awk 'BEGIN {FS="/";} {print $1"-"$2}')
      docker build -t --no-cache drupalci/${DOCKERTAG}:${GITBRANCH} ./${DOCKERFILE%/Dockerfile}
      BUILDRESULT=$?
      if [ ${BUILDRESULT} -eq 0 ]; then
          docker push drupalci/${DOCKERTAG}:${GITBRANCH}
      fi
    done
fi
