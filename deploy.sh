#!/bin/ash

set -e

refBranch=$(basename $WEBHOOK_REF)

if [ "$HUGO_BRANCH" != "$refBranch" ]; then
    echo "Wrong branch pushed '$refBranch'. Cancelling build.";
    return 1;
fi

# Clean, then Fetch website
rm -rf /temp/website

tries=1
echo "Attempting git clone #$tries"
git clone -b $HUGO_BRANCH $HUGO_REPOSITORY --recurse-submodules /temp/website || :

while [ ! -d "/temp/website" ] && [ "$tries" -lt "6" ]; do
    sleep 5
    tries=$((tries+1))
    echo "Attempting git clone #$tries"
    git clone -b $HUGO_BRANCH $HUGO_REPOSITORY --recurse-submodules /temp/website || :
done

if [ ! -d "/temp/website" ]; then
    echo "Git Clone failed after $tries attempts, exiting"
    exit 1
fi

# Clear old website files
rm -rf /www/*

# Build Website to www mount
hugo -s /temp/website $HUGO_ARGS
cp -R /temp/website/public/* /www

# Cleanup
rm -rf /temp/website

/bin/sh /after-deploy.sh