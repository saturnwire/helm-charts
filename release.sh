#!/usr/bin/env bash
set -eu -o pipefail

# Downloads helm chart-releaser
wget --no-verbose https://github.com/saturnwire/chart-releaser/releases/download/1.1.0/chart-releaser_1.1.0_linux_amd64.tar.gz
tar -zxvf chart-releaser_1.1.0_linux_amd64.tar.gz
mkdir -p .cr-release-packages

# Create the new index files with updated packages from repo
./cr index --remote -o ${GITHUB_OWNER} -r ${GITHUB_REPO} -c https://charts.saturnwire.com -i ./index.yaml --token ${GITHUB_TOKEN}

# Detect if index changed and commit back to master
git diff --exit-code index.yaml
if [[ $? -eq 1 ]]; then
  git config --global user.email "automation@saturnwire.com"
  git config --global user.name "SaturnWire Automation"
  git add index.yaml
  git commit -m "Auto-releasing new index file"
  git push -u origin master
fi
