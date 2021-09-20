# Webhook-Hugo

Minimal Alpine Linux Docker image with [webhook](https://github.com/adnanh/webhook/) installed that listens on `/build` and runs hugo publish on a set git repo.

## Usage

This docker image hosts a n Alpine Image with a single webhook that, when triggered by a Git server's Push event, will trigger a hugo build of that repo.

Port `9000` is exposed.

The build hook is located at `/hooks/build`

# Required Environment Variables

* `HUGO_BRANCH` - The branch name you want to trigger builds with. IE `master`
* `HUGO_SECRET` - The Secret value you set for your webhook on the Git Server

# Volume Mounts

* `/path/to/website/output/dir:/www`
  * **Required**
  * This is the folder the build trigger will pipe the static hugo web files out into.
  * **NOTE WHEN TRIGGERED THIS FOLDER'S CONTENTS WILL BE WIPED WITH EACH BUILD TO MAKE WAY FOR THE NEW FILES** 
* `/path/to/after-deploy.sh:/after-deploy.sh`
  * **Optional**
  * Customizable **ash** (alpine) script you can override with your own custom "after build" script to perform any additional operations after the build has succeeded.
  * See [after-deploy.sh](/after-deploy.sh) for an example 
  * Alpine enviro so please take note that the header is `#!/bin/ash` not `#!/bin/bash`

# Hugo File setup

At this time, the Hugo web folder must be the root of the git repo. That is to say this image expects `config.toml` to be at the very root of the repo (right beside your README.md for example). There is currently not support for a hugo web app nested within a folder in the repo.

# Example Deploys

## docker run

`docker run -d -v /My/Website/Out/Folder:/www -p 9000:9000 -e HUGO_BRANCH=main -e HUGO_SECRET=MyPassword steffenblake/webhook-hugo`

## docker compose

```
version: "3"

services:
  server:
    image: steffenblake/webhook-hugo
    container_name: webhook-hugo
    environment:
      - HUGO_BRANCH=main
      - HUGO_SECRET=MyPassword
    restart: always
    volumes:
      - /My/Website/Out/Folder:/www
    ports:
      - "9000:9000"
```

Both of the above will now be listening on `http://localhost:9000/hooks/build`

# Supported servers

- [x] Gogs
- [x] Github
- [x] Gitea
- [x] Gitlab
- [x] Bitbucket

Also, any other server software that also performs the hmac-sha256 secret algorithm on any of these headers will also be implicitly supported:

- [x] `X-Gogs-Signature`
- [x] `X-Hub-Signature`
- [x] `X-Hub-Signature-256`

Additionaly, the following two properties must be part of its json payload for its `Push` event:

- [x] `ref`
- [x] `repository.clone_url`

Finally, the webhook must be an HTTP `POST` 

If these three above conditions are met, the server should inherently work with `docker-webhook` without any alterations needed
