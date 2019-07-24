#!/usr/bin/env sh

set -e

REMOTE=`git remote get-url origin`
USER_NAME=`git config user.name`
USER_EMAIL=`git config user.email`

npm run build

cd dist

git init

git config user.name $USER_NAME
git config user.email $USER_EMAIL

git add -A
git commit -m 'deploy'

git push -f $REMOTE master:gh-pages

cd -