#!/bin/bash

set -e

JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_TOKEN="117429a6b5ffdbffd9aeaa3aa8e4da688c"

# Get crumb JSON
CRUMB_JSON=$(curl -s -u ${JENKINS_USER}:${JENKINS_TOKEN} \
${JENKINS_URL}/crumbIssuer/api/json)

CRUMB=$(echo $CRUMB_JSON | jq -r .crumb)
CRUMB_FIELD=$(echo $CRUMB_JSON | jq -r .crumbRequestField)

echo "Crumb field: $CRUMB_FIELD"
echo "Crumb value: $CRUMB"

while read plugin; do
  echo "Installing ${plugin}..."
  curl -s -X POST \
    -u ${JENKINS_USER}:${JENKINS_TOKEN} \
    -H "${CRUMB_FIELD}: ${CRUMB}" \
    -H "Content-Type: text/xml" \
    --data "<jenkins><install plugin='${plugin}' /></jenkins>" \
    ${JENKINS_URL}/pluginManager/install
done < plugins.txt

echo "Plugin installation triggered."

