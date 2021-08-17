# API docs for Micro-Manager projects

This repository collects auto-generated API documentation (Javadoc, Doxygen)
for Micro-Manager projects and publishes them on GitHub Pages.

## Branches of this repo

- `main` -- this branch, containing GitHub Actions workflow(s) and maintainer
  documentation.
- `gh-pages` -- current HTML content for all projects and versions, published
  with GitHub Pages.
- `pages/<project>/<version>` -- HTML docs for a given project and version.

Special `<version>` values: `latest` (current development version) and `stable`
(most recent release version).

Regular version numbers must start with a number and must _not_ include a `v`
prefix.

## What this repo's CI does

This repo expects other project-specific CI workflows to push documentation to
branches named `pages/**`. It then simply updates the `gh-pages` branch with
that content under the corresponding directory.

## What project repos' CI should do to publish docs

Each project should set up a CI workflow that is triggered by a push on its
main branch. The job should build the HTML docs, and push them to this repo's
`pages/<project>/latest` branch.

The branch should be checked out using the `prepare_pages_branch.sh` script,
which takes care of creating the branch if it does not exist and updating the
necessary workflow definitions for the branch.

It will probably be necessary to set up a GitHub encrypted secret containing
the secret key for a deploy key with write access to this repo.

API docs for release versions can be manually pushed. If the project is in its
own dedicated repo and git tags are used for versioning, then publication of
relese docs can also be automated by setting up a workflow that is triggered on
a push to a tag of the appropriate pattern (usually a `v` prefix); the workflow
should build the docs and push them to this repo's `pages/<project>/<version>`
branch, where `<version>` is the tag name with the `v` prefix removed.

The branch `pages/<project>/stable` should be made to point to the latest
release branch's head. This is not automated yet.

## Maintainer notes

If the publishing workflow is updated and needs to be re-run for every
`pages/**` branch, we'll need a new script or workflow to do that. (Probably
should add a workflow to update all branches when there is a push to `main`.)
