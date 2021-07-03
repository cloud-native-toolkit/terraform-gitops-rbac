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

#- apiGroups: ["apps"]
#  resources: ["deployments", "statefulsets"]
#  verbs: ["*"]
#- apiGroups: [""]
#  resources: ["secrets", "configmaps", "serviceaccount", "services"]
#  verbs: ["*"]
#- apiGroups: ["route.openshift.io"]
#  resources: ["routes"]
#  verbs: ["*"]

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
