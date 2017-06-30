#!/bin/bash

set -e

# Setting variables for repo
if [ -z "$1" ] ; then
    echo "Usage: ./github-transfer.sh <org-name> <repo-name> <ghe-url>"
    exit 1
fi

if [ -z "$2" ] ; then
    echo "Usage: ./github-transfer.sh <org-name> <repo-name> <ghe-url>"
    exit 1
fi


if [ -z "$3" ] ; then
    echo "Usage: ./github-transfer.sh <org-name> <repo-name> <ghe-url>"
    exit 1
fi

REPO="$1/$2"
DIR=$(basename $REPO)
GHE="$3"

# clean up to run at end of script
clean_up () {
    echo "$1"
    cd ..
    rm -fr "$DIR" "$DIR"-source
    exit 0
}

# warns to run in other dir because of rm -fr in clean_up
if [ -d "$DIR" ] ; then
    echo "$DIR" in pwd. Run this somewhere else.
    exit 1
fi

# clone github repo and remove notes and .git
git clone --depth=1 git@github.com:$REPO.git "$DIR"-source
rm -fr "$DIR"-source/notes "$DIR"-source/.git

# check for .gitignore
if ! [ -a "$DIR"-source/.gitignore ] ; then
    curl https://www.gitignore.io/api/osx > "$DIR"-source/.gitignore
fi

git clone git@$GHE:$REPO.git
# if ghe repo is empty perform initial commit
if [ -z "$(ls "$DIR")" ] ; then
    cp -a "$DIR"-source/* "$DIR"
    cd "$DIR" || exit
    git add -A
    git commit -m 'initial commit'
    git push

# otherwise, update existing repo
else
    rm -fr "${DIR:?}"/*
    cp -a "$DIR"-source/* "$DIR"
    cd "$DIR" || exit
    git add -A
    git commit -m 'doc update' || clean_up 'Nothing to update'
    git push
fi

#clean_up 'Done'
