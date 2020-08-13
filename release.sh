#!/bin/bash

wget --no-verbose https://github.com/saturnwire/chart-releaser/releases/download/1.1.0/chart-releaser_1.1.0_linux_amd64.tar.gz
tar -zxvf chart-releaser_1.1.0_linux_amd64.tar.gz

./cr index -o ${GITHUB_OWNER} -r ${GITHUB_REPO} -c https://charts.saturnwire.com -i ./index.yaml --token ${GITHUB_TOKEN}

cat index.yaml
