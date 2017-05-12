#!/bin/bash

MINISHIFT_DIRECTORY="$(cd "$(dirname "$0")" && pwd)"
PROJECT=minishift-demo
APP_NAME=hello-server

OPENSHIFT_TOKEN=$(oc whoami -t)
OPENSHIFT_REGISTRY="$(minishift openshift registry)"

echo "Creating demo application..."

echo "=========================="
echo "(1/4) Creating new project..."

oc new-project $PROJECT --display-name="Demo Project" --description="A demo project designed to help you start developing with Minishift" > /dev/null

echo "=========================="
echo "(2/4) Installing node_modules..."

cd "$MINISHIFT_DIRECTORY"/../demo/hello && npm install --quiet && cd - || exit 1

echo "=========================="
echo "(3/4) Deploying hello-server..."

oc process -f "$MINISHIFT_DIRECTORY"/../demo/manifests/openshift/nodejs.yaml \
  -p NAMESPACE=$PROJECT \
  -p NAME=$APP_NAME \
  -p PROBE=/healthz \
  -p SERVER_PORT=8080 \
  -p LOG_LEVEL=debug \
  -p APP_VOLUME="${MINISHIFT_DIRECTORY}"/../demo/hello | oc create -f -

echo "(4/4) Building hello-server Image"
oc start-build $APP_NAME --from-dir $MINISHIFT_DIRECTORY/../demo/hello
