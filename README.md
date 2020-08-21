# Helm Charts
This repository builds and maintains the helm repository `index.yaml` file.  It can be triggered by helm chart repos to rebuild when new helm distributed helm charts are released.

## Release Script
This repository also contains a release script that can be downloaded and utilized by chart repositories.

It requires the following environment variables to be set: 
|Env Var|Description|
|-|-|
|GITHUB_TOKEN|Github token with access to charts repository.  This is normally generated automatically by Github actions.|
|GITHUB_REPOSITORY|Github repository where the chart is located.  Has the format  `<owner>/<repo>`, for example, `saturnwire/multi-stage-cron-helm`. This is normally generated automatically by Github actions.|
|INDEX_REPOSITORY|Github repository where the chart index file should be updated.  Has the format  `<owner>/<repo>`, for example, `saturnwire/helm-charts`. Defaults to  `saturnwire/helm-charts`.|
|CHART_PATH|Path to the directory containing the chart.  Defaults to  `./chart`. |

<br>
It can be downloaded via the command:

```
curl -OL https://raw.githubusercontent.com/saturnwire/helm-charts/master/scripts/release.sh
chmod +x release.sh
./release.sh
```