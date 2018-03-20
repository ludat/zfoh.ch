#!/bin/bash
set -o nounset -o pipefail -o errexit

DEPLOY_REPO=`git config remote.origin.url`
DEPLOY_SSH_REPO=${DEPLOY_REPO/https:\/\/github.com\//git@github.com:}
DEPLOY_SHA=`git rev-parse --verify HEAD`

DEPLOY_BRANCH="gh-pages"

DEPLOY_AUTHOR_EMAIL="travis.zfoh.ch@jaspervdj.be"
DEPLOY_AUTHOR_NAME="Travis CI"

git config user.name "$DEPLOY_AUTHOR_NAME"
git config user.email "$DEPLOY_AUTHOR_EMAIL"

DEPLOY_KEY="deploy/travis.zfoh.ch.key"
DEPLOY_KEY_ENC="$DEPLOY_KEY.enc"

openssl aes-256-cbc \
    -K "${encrypted_ccab536b289e_key-}" -iv "${encrypted_ccab536b289e_iv-}" \
    -in "$DEPLOY_KEY_ENC" -out "$DEPLOY_KEY" -d

chmod 600 "$DEPLOY_KEY"
eval "$(ssh-agent -s)"
ssh-add "$DEPLOY_KEY"

DEPLOY_DIR="$(mktemp -d)"
git clone --single-branch --branch "$DEPLOY_BRANCH" \
    "$DEPLOY_SSH_REPO" "$DEPLOY_DIR"

rsync -v -r --exclude '.git/' --delete "_site/" "$DEPLOY_DIR/"

cd "$DEPLOY_DIR"

git add -A .
git commit -m 'CI commit'
git push origin "$DEPLOY_BRANCH"
