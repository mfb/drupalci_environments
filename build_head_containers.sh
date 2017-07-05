#!/bin/bash
set -eux
####
# This script looks for changes to the docker files and rebuilds the containers based on
# which docker files were changed in the last commit.
#
####

# make sure any floating containers are cleaned up
docker ps -a |grep Exited |awk '{print $1}'|xargs docker rm || true

GITBRANCH=${1}

mapfile -t DOCKERFILES < <(ls -1 php/*.x-apache/Dockerfile)

if [[ ! -z "${DOCKERFILES-}" ]]; then
    for DOCKERFILE in "${DOCKERFILES[@]}"
    do
      DOCKERTAG=$(echo ${DOCKERFILE} | awk 'BEGIN {FS="/";} {print $1"-"$2}')
      docker build --no-cache -t drupalci/${DOCKERTAG}:${GITBRANCH} ./${DOCKERFILE%/Dockerfile}
      BUILDRESULT=$?
      if [ ${BUILDRESULT} -eq 0 ]; then
          docker push drupalci/${DOCKERTAG}:${GITBRANCH}
      fi
    done
fi

#clean up extra images
docker images |grep none |awk '{print $3}' |xargs docker rmi || true
