#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

YAML_DIR="$1"
NAMESPACE="$2"
SA_NAME="$3"
SA_NAMESPACE="$4"
LABEL="$5"
CLUSTER_SCOPE="$6"

if [[ -z "${ROLES}" ]]; then
  ROLES = '[]'
fi

if [[ -z "${RULES}" ]] || [[ $(echo "${ROLES}" | ${BIN_DIR}/jq '. | length') -eq 0 ]]; then
  echo "Rules must be provided via the RULES environment variable"
  exit 1
fi


mkdir -p "${YAML_DIR}"

if [[ "${CLUSTER_SCOPE}" == "true" ]]; then
  KIND="ClusterRole"
else
  KIND="Role"
fi

if [[ -n "${RULES}" ]]; then
cat > "${YAML_DIR}/rbac.yaml" <<EOL
apiVersion: rbac.authorization.k8s.io/v1
kind: ${KIND}
metadata:
  name: ${LABEL}
  annotations:
    argocd.argoproj.io/sync-wave: "-5"
rules:
${RULES}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ${KIND}Binding
metadata:
  name: ${LABEL}
  annotations:
    argocd.argoproj.io/sync-wave: "-5"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ${KIND}
  name: ${LABEL}
subjects:
- kind: ServiceAccount
  name: ${SA_NAME}
  namespace: ${SA_NAMESPACE}
---
EOL
fi

echo "${ROLES}" | ${BIN_DIR}/jq -c '.[]' | while read role; do
  name=$(echo "${role}" | ${BIN_DIR}/jq -r '.name')

  kind="ClusterRole"

  cat >> "${YAML_DIR}/rbac.yaml" <<EOL
apiVersion: rbac.authorization.k8s.io/v1
kind: ${KIND}Binding
metadata:
  name: ${LABEL}-${name}
  annotations:
    argocd.argoproj.io/sync-wave: "-5"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ${kind}
  name: ${name}
subjects:
- kind: ServiceAccount
  name: ${SA_NAME}
  namespace: ${SA_NAMESPACE}
---
EOL
done
