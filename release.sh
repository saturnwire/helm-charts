#!/bin/bash

wget --no-verbose https://github.com/saturnwire/chart-releaser/releases/download/1.1.0/chart-releaser_1.1.0_linux_amd64.tar.gz
tar -zxvf chart-releaser_1.1.0_linux_amd64.tar.gz

./cr index -h

echo ${GITHUB_OWNER}
echo ${GITHUB_REPO}

