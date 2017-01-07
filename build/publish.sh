#!/bin/bash
set -e

echo SOURCE_DIR: $SOURCE_DIR
echo DEPLOY_BRANCH: $DEPLOY_BRANCH
echo BUILD_BRANCH: $BUILD_BRANCH
echo ENCRYPTION_LABEL: $ENCRYPTION_LABEL
echo GIT_NAME: $GIT_NAME
echo GIT_EMAIL: $GIT_EMAIL

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

## Git configuration
git config --global user.email ${GIT_EMAIL}
git config --global user.name ${GIT_NAME}

## Repository URL
REPO=$(git config remote.origin.url)
REPO=${REPO/git:\/\/github.com\//git@github.com:}
REPO=${REPO/https:\/\/github.com\//git@github.com:}
echo "REPO: ${REPO}"

## Loading SSH key
echo "Loading key..."

ENCRYPTED_KEY_VAR=encrypted_${ENCRYPTION_LABEL}_key
ENCRYPTED_IV_VAR=encrypted_${ENCRYPTION_LABEL}_iv
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in travis_key.enc -out travis_key -d
chmod 600 travis_key
eval `ssh-agent -s`
ssh-add travis_key
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"