#!/usr/bin/env bash

echo "namespace: ${TF_VAR_namespace}"

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

cd ..
rm -rf .testrepo
