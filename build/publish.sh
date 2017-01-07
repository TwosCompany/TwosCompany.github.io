#!/bin/bash
set -e

echo "SOURCE_DIR: ${SOURCE_DIR}"

## Generated folder must exist
if [ ! -d "$SOURCE_DIR" ]; then
  echo "SOURCE_DIR (${SOURCE_DIR}) does not exist, build the source directory before deploying"
  exit 1
fi

## Prevent publish on tags
CURRENT_TAG=$(git tag --contains HEAD)

if [ -z "${STOP_PUBLISH}" ] && [ "$TRAVIS_OS_NAME" = "linux" ] && [ "$TRAVIS_BRANCH" = "$BUILD_BRANCH" ] && [ -z "$CURRENT_TAG" ] && [ "$TRAVIS_PULL_REQUEST" = "false" ]
then
  echo 'Publishing...'
else
  echo 'Skipping publishing'
  exit 0
fi

SSH_KEY_NAME="travis_rsa"

## Git configuration
echo "User: ${USER_NAME}(${USER_EMAIL})"
git config --global user.email ${USER_EMAIL}
git config --global user.name "${USER_NAME}"

## Repository URL
echo "Repo: $(git config remote.origin.url)"
REPO=$(git config remote.origin.url)
REPO=${REPO/git:\/\/github.com\//git@github.com:}
REPO=${REPO/https:\/\/github.com\//git@github.com:}

