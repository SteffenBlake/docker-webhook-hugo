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
rm -rf /www/*

# Build Website to www mount
hugo -s /temp/website $HUGO_ARGS
cp -R /temp/website/public/* /www

# Cleanup
rm -rf /temp/website

/bin/sh /after-deploy.sh