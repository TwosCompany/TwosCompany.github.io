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

SSH_KEY_NAME="travis_key"
ENCRYPTED_KEY_VAR=encrypted_${ENCRYPTION_LABEL}_key
ENCRYPTED_IV_VAR=encrypted_${ENCRYPTION_LABEL}_iv
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}

openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in build/${SSH_KEY_NAME}.enc -out ~/.ssh/${SSH_KEY_NAME} -d
eval `ssh-agent -s`
chmod 600 ~/.ssh/${SSH_KEY_NAME}
ssh-add ~/.ssh/${SSH_KEY_NAME}
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

REPO_NAME=$(basename $REPO)
TARGET_DIR=$(mktemp -d /tmp/$REPO_NAME.XXXX)
REV=$(git rev-parse HEAD)
git clone --branch ${DEPLOY_BRANCH} ${REPO} ${TARGET_DIR}
rsync -rt --delete --exclude=".git" --exclude=".nojekyll" --exclude=".travis.yml" $SOURCE_DIR/ $TARGET_DIR/
cd $TARGET_DIR
git add -A .
git commit --allow-empty -m "Built from commit $REV"
git push $REPO $TARGET_BRANCH