#!/usr/bin/env bash

REPO="$1"
REPO_PATH="$2"
NAMESPACE="$3"
SA_NAME="$4"
SA_NAMESPACE="$5"
LABEL="$6"

if [[ -z "${RULES}" ]]; then
  echo "Rules must be provided via the RULES environment variable"
  exit 1
fi

echo "Path: ${REPO_PATH}"

REPO_DIR=".tmprepo-rbac-${NAMESPACE}"

SEMAPHORE="${REPO//\//-}.semaphore"

while true; do
  echo "Checking for semaphore"
  if [[ ! -f "${SEMAPHORE}" ]]; then
    echo -n "${REPO_DIR}" > "${SEMAPHORE}"

    if [[ $(cat "${SEMAPHORE}") == "${REPO_DIR}" ]]; then
      echo "Got the semaphore. Setting up gitops repo"
      break
    fi
  fi

  SLEEP_TIME=$((1 + $RANDOM % 10))
  echo "  Waiting $SLEEP_TIME seconds for semaphore"
  sleep $SLEEP_TIME
done

function finish {
  rm "${SEMAPHORE}"
}

trap finish EXIT

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

mkdir -p "${REPO_DIR}"

git clone "https://${TOKEN}@${REPO}" "${REPO_DIR}"

cd "${REPO_DIR}" || exit 1

mkdir -p "${REPO_PATH}/rbac/${NAMESPACE}"

cat > "${REPO_PATH}/rbac/${NAMESPACE}/${LABEL}-rbac.yaml" <<EOL
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${LABEL}
rules:
${RULES}
---
EOL

apiVersion: apps/v1
kind: Deployment

cat >> "${REPO_PATH}/rbac/${NAMESPACE}/${LABEL}-rbac.yaml" <<EOL
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${LABEL}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ${LABEL}
subjects:
- kind: ServiceAccount
  name: ${SA_NAME}
  namespace: ${SA_NAMESPACE}
---
EOL

git add .
git commit -m "Adds config for '$LABEL' role and role-binding in '$NAMESPACE' namespace"
git push

cd ..
rm -rf "${REPO_DIR}"
