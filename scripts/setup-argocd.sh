#!/usr/bin/env bash

REPO="$1"
REPO_PATH="$2"
PROJECT="$3"
APPLICATION_REPO="$4"
APPLICATION_GIT_PATH="$5"
NAMESPACE="$6"
BRANCH="$7"

APPLICATION_REPO_URL="https://${APPLICATION_REPO}"

REPO_DIR=".tmprepo-namespace-${NAMESPACE}"

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

mkdir -p "${REPO_DIR}"

git clone "https://${TOKEN}@${REPO}" "${REPO_DIR}"

cd "${REPO_DIR}" || exit 1

cat > "${REPO_PATH}/rbac-${NAMESPACE}.yaml" <<EOL
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: rbac-${NAMESPACE}-${BRANCH}
spec:
  destination:
    namespace: ${NAMESPACE}
    server: "https://kubernetes.default.svc"
  project: ${PROJECT}
  source:
    path: ${APPLICATION_GIT_PATH}
    repoURL: ${APPLICATION_REPO_URL}
    targetRevision: ${BRANCH}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOL

if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  git add .
  git commit -m "Adds argocd config for rbac in ${NAMESPACE} namespace"
  git push
fi

cd ..
rm -rf "${REPO_DIR}"
