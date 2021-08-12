#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

NAMESPACE="gitops-rbac"
NAME="rbac-${NAMESPACE}-rbac"
SERVER_NAME="default"

if [[ ! -f "payload/1-infrastructure/namespace/${NAMESPACE}/${NAME}/rbac.yaml" ]]; then
  echo "Payload missing: payload/1-infrastructure/namespace/${NAMESPACE}/${NAME}/rbac.yaml"
  exit 1
fi

cat "payload/1-infrastructure/namespace/${NAMESPACE}/${NAME}/rbac.yaml"

if [[ ! -f "argocd/1-infrastructure/cluster/${SERVER_NAME}/base/${NAMESPACE}-${NAME}.yaml" ]]; then
  echo "Argocd config missing: argocd/1-infrastructure/cluster/${SERVER_NAME}/base/${NAMESPACE}-${NAME}.yaml"
  exit 1
fi

cat "argocd/1-infrastructure/cluster/${SERVER_NAME}/base/${NAMESPACE}-${NAME}.yaml"

if [[ ! -f "argocd/1-infrastructure/cluster/${SERVER_NAME}/kustomization.yaml" ]]; then
  echo "Argocd config missing: argocd/1-infrastructure/cluster/${SERVER_NAME}/kustomization.yaml"
  exit 1
fi

cat "argocd/1-infrastructure/cluster/${SERVER_NAME}/kustomization.yaml"

cd ..
rm -rf .testrepo
