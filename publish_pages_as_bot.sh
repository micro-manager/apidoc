#!/bin/bash

# This script assumes it is run by a GitHub Actions workflow, that we are on
# the pages/<project>/<version> branch (prepared by prepare_pages_branch.sh),
# and that the generated documentation has been added with `git add` but not
# yet committed.
#
# Project CI should invoke this script with one arg ("<project>/<version>").

proj_ver=$1

if [ -z "$proj_ver" ]; then
    echo "Required argument (<project>/<version>) missing"
    exit 1
fi

branch=pages/$1

# Guard against this script being accidentally added
git rm -f --ignore-unmatch $0

git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'

if [ -z "$(git status --porcelain=v1 2>/dev/null)" ]; then
    echo "No changes to publish"
else
    git commit -m "Publish $proj_ver"
    git push -u origin $branch
fi
