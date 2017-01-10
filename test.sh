#!/bin/bash
set -eux
####
# This script looks for changes to the docker files and rebuilds the containers based on
# which docker files were changed in the last commit.
#
####

GITBRANCH=dev

if [ "${GITBRANCH}" != "production" ]; then
echo 'curl https://dispatcher.drupalci.org/job/drupalci_test_containers/buildWithParameters'
fi


