#!/usr/bin/env bash

# FYI: This Script assumes you have jq installed
# This script is designed to be run from Github actions or locally assuming the right environment variables are present.

chart_path=${CHART_PATH:-"./chart"}
index_repo=${INDEX_REPOSITORY:-"saturnwire/helm-charts"}

set -eu -o pipefail

token=${GITHUB_TOKEN}
repo_full_name=${GITHUB_REPOSITORY:-$(git config --local remote.origin.url|sed -n 's#.*\:\([^.]*\)\.git#\1#p')}

branch=$(git rev-parse --abbrev-ref HEAD)
chart_name=$(grep 'name:' ${chart_path}/Chart.yaml | awk '{ print $2 }')
chart_version=$(grep 'version:' ${chart_path}/Chart.yaml | awk '{ print $2 }')
helm_package="${chart_name}-${chart_version}.tgz"

generate_post_data() {
cat <<EOF
{
  "tag_name": "${chart_version}",
  "target_commitish": "$branch",
  "name": "${chart_version}",
  "draft": false,
  "prerelease": false
}
EOF
}

echo "Creating helm package: ${helm_package}"
helm package ${chart_path}

echo "Create release ${chart_version} for repo: ${repo_full_name} branch: ${branch}"
id=$(curl --silent --data "$(generate_post_data)" "https://api.github.com/repos/${repo_full_name}/releases?access_token=${token}" | jq -r .id)

# Get ID of the asset based on given filename.
[ "${id}" ] || { echo "Error: Failed to get release id for tag: ${tag}"; echo "${response}" | awk 'length($0)<100' >&2; exit 1; }

echo "Uploading helm package to release with id: ${id}"
response=$(curl --silent \
-H "Authorization: token ${token}" \
-H "Content-Type: $(file -b --mime-type ${helm_package})" \
--data-binary @${helm_package} \
"https://uploads.github.com/repos/${repo_full_name}/releases/${id}/assets?name=$(basename ${helm_package})")

echo "Removing helm package: ${helm_package}"
rm -rf ${helm_package}

# Check to see if the upload worked
SUB='"state":"uploaded"'
if [[ "${response}" != *"$SUB"* ]]; then
  echo "Error: Failed to upload file to release with id: ${id}"; echo "${response}"
  exit 1
fi

# Trigger the helm-charts repo to rebuild the index file
repo_owner=$(echo $repo_full_name | cut -d'/' -f1)
repo_name=$(echo $repo_full_name | cut -d'/' -f2)
curl -X POST \
	-H "Accept: application/vnd.github.everest-preview+json" \
	-H "Content-Type: application/json" \
	"https://api.github.com/repos/${index_repo}/actions/workflows/release.yml/dispatches?access_token=${HELM_CHARTS_DISPATCH_TOKEN}" -d '{"ref":"master","inputs":{"githubOwner":"'${repo_owner}'","githubRepo":"'${repo_name}'"}}'

