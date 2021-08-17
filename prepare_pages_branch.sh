#!/bin/bash

# Project CI should invoke this script with one arg ("<project>/<version>") to
# checkout or create the branch pages/<project>/<version>.
#
# After this script is run, the html docs can be copied in and a commit can be
# made.
#
# It is assumed that this script is run from the root of the main branch,
# freshly checked out.

proj_ver=$1

if [ -z "$proj_ver" ]; then
    echo "Required argument (<project>/<version>) missing"
    exit 1
fi

branch=pages/$1

git checkout $branch -- || git checkout --orphan $branch

# Remove all previous content, or 'main' content if new branch
git rm -rf .

# Readd workflows, possibly updating
git checkout main -- .github/workflows
