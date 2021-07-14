#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

YAML_DIR="$1"
NAMESPACE="$2"
SA_NAME="$3"
SA_NAMESPACE="$4"
LABEL="$5"
CLUSTER_SCOPE="$6"

if [[ -z "${RULES}" ]]; then
  echo "Rules must be provided via the RULES environment variable"
  exit 1
fi

mkdir -p "${YAML_DIR}"

if [[ "${CLUSTER_SCOPE}" == "true" ]]; then
  KIND="ClusterRole"
else
  KIND="Role"
fi

cat > "${YAML_DIR}/${LABEL}-rbac.yaml" <<EOL
apiVersion: rbac.authorization.k8s.io/v1
kind: ${KIND}
metadata:
  name: ${LABEL}
rules:
${RULES}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ${KIND}Binding
metadata:
  name: ${LABEL}
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
