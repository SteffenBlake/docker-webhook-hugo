#!/bin/ash

set -e

refBranch=$(basename $WEBHOOK_REF)

if [ "$HUGO_BRANCH" != "$refBranch" ]; then
    echo "Wrong branch pushed '$refBranch'. Cancelling build.";
    return 1;
fi

# Fetch website
git clone -b $HUGO_BRANCH $HUGO_REPOSITORY --recurse-submodules /temp/website

# Clear old website files
rm -R /www/* $HUGO_ARGS

# Build Website to www mount
hugo -s /temp/website
cp -R /temp/website/public/* /www

# Cleanup
rm -R /temp/website

/bin/sh /after-deploy.sh