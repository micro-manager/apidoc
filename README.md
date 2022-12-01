# API docs for Micro-Manager projects

This repository collects auto-generated API documentation (Javadoc, Doxygen)
for Micro-Manager projects and publishes them on GitHub Pages.

## Published docs

Latest:
[MMCore latest](https://micro-manager.org/apidoc/MMCore/latest/),
[MMDevice latest](https://micro-manager.org/apidoc/MMDevice/latest/),
[mmcorej latest](https://micro-manager.org/apidoc/mmcorej/latest/),
[mmstudio latest](https://micro-manager.org/apidoc/mmstudio/latest/).

Release:
[mmstudio 1.4](https://micro-manager.org/apidoc/mmstudio/1.4/),
[mmstudio 1.4.23](https://micro-manager.org/apidoc/mmstudio/1.4.23/),
[mmstudio 2](https://micro-manager.org/apidoc/mmstudio/2/),
[mmstudio 2.0](https://micro-manager.org/apidoc/mmstudio/2.0/),
[mmstudio 2.0.0](https://micro-manager.org/apidoc/mmstudio/2.0.0/),
[mmstudio stable](https://micro-manager.org/apidoc/mmstudio/stable/).
(Some of these have the same content.)

The docs are published at `micro-manager.org/apidoc/<project>/<version>/`.
When linking from Markdown in the main micro-manager.org website, use the form
`/apidoc/mmstudio/latest/...` without the `https://micro-manager.org` part.

Currently the above list is maintained manually. Publishing of per-version docs
has not yet been automated.

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

After adding the html files (`git add`), the script `publish_pages_as_bot.sh`
should be run to commit and push. (This script should not be used for manual
changes, which should be committed and pushed the normal way.)

API docs for release versions can be manually pushed. If the project is in its
own dedicated repo and git tags are used for versioning, then publication of
relese docs can also be automated by setting up a workflow that is triggered on
a push to a tag of the appropriate pattern (usually a `v` prefix); the workflow
should build the docs and push them to this repo's `pages/<project>/<version>`
branch, where `<version>` is the tag name with the `v` prefix removed.

The branch `pages/<project>/stable` should be made to point to the latest
release branch's head. This is not automated yet.

### Setting up write access to the apidoc repo

Create an SSH key (use an empty passphrase):
```sh
ssh-keygen -t ed25519 -C deploy-to-apidoc-from-myproject -f mykey
```

In the `apidoc` repository settings, create a **Deploy Key** and paste in the
public key (contents of `mykey.pub`). Check Allow Write Access. Name like
`deploy-from-myproject` so that it is easy to keep track.

In the project's repository settings, create a **Repository Secret** and paste
in the private key (contents of `mykey`). Name it `SSH_KEY_DEPLOY_TO_APIDOC`.

Delete the key pair from your local computer. (Create a new key if/when needed
for another project.)

### Minimal GitHub Actions workflow example for a project

```yml
name: Publish docs

on: [push, pull_request]

jobs:
  build-and-push-docs:
    name: Build and publish docs
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          path: myproject  # Clone in subdirectory

      - name: Build docs
        run: |
          cd myproject
          generate_docs --outdir=htmldocs  # Replace this with actual doc gen
          tar cf ../docs.tar -C htmldocs .

      - uses: actions/checkout@v2
        if: github.repository == 'micro-manager/myproject' && github.ref == 'refs/heads/main'
        with:
          repository: micro-manager/apidoc
          ssh-key: ${{ secrets.SSH_KEY_DEPLOY_TO_APIDOC }}
          fetch-depth: 0  # All refs and history
          path: apidoc

      - name: Publish docs
        if: github.repository == 'micro-manager/myproject' && github.ref == 'refs/heads/main'
        run: |
          cd apidoc
          ./prepare_pages_branch.sh myproject/latest
          tar xf ../docs.tar
          git add .
          ./publish_pages_as_bot.sh myproject/latest
```

The `if:` keys on the last to steps limit publishing to the main branch of
the official repo.

Use of `tar` is optional (the html docs could also be copied or moved), but
the `tar` command is less error-prone. You could also upload the tar archive
as an artifact so that it can be downloaded and inspected even when on a
branch or fork.

## Maintainer notes

If the publishing workflow is updated and needs to be re-run for every
`pages/**` branch, we'll need a new script or workflow to do that. (Probably
should add a workflow to update all branches when there is a push to `main`.)
