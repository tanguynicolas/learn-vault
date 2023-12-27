#!/usr/bin/env bash

# Used only for bootstrap, after that, argo manages it

CHART_REPO_NAME="cilium"
CHART_REPO_URL="https://helm.cilium.io/"

CHART_RELEASE_NAME="cilium"
CHART_PATH="cilium/cilium"
CHART_NAMESPACE="kube-system"
CHART_VERSION="1.14.4"
