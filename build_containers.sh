#!/bin/bash
set -eux
####
# This script looks for changes to the docker files and rebuilds the containers based on
# which docker files were changed in the last commit.
#
####

GITBRANCH=${1#origin/}
if [ "${GITBRANCH}" != "production" ]; then
         mapfile -t DOCKERFILES < <(git diff-tree --no-commit-id --name-status -r HEAD |grep Dockerfile|grep -v ^D|awk '{print $2}')
else
         mapfile -t DOCKERFILES < <(git diff-tree --no-commit-id --name-status -r -m HEAD |grep Dockerfile|grep -v ^D|awk '{print $2}')
fi

if [[ ! -z "${DOCKERFILES-}" ]]; then
    for DOCKERFILE in "${DOCKERFILES[@]}"
    do
      DOCKERTAG=$(echo ${DOCKERFILE} | awk 'BEGIN {FS="/";} {print $1"-"$2}')
      docker build -t drupalci/${DOCKERTAG}:${GITBRANCH} ./${DOCKERFILE%/Dockerfile}
      BUILDRESULT=$?
      if [ ${BUILDRESULT} -eq 0 ]; then
          docker push drupalci/${DOCKERTAG}:${GITBRANCH}
          #TODO: this currently assumes that the only containers we are working on are the php containers.
          if [ "${GITBRANCH}" != "production" ]; then
            curl https://dispatcher.drupalci.org/job/drupalci_test_containers/buildWithParameters?token=${2}\&DCI_PHPVersion=${DOCKERTAG}:${GITBRANCH}
          fi
      fi
    done
fi
