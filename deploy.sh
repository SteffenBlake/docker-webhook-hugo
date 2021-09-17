#!/bin/ash

# Fetch website
git clone $HUGO_REPOSITORY --recurse-submodules /temp/website

# Clear old website files
rm -R /www/*

# Build Website to www mount
hugo -s /temp/website
cp -R /temp/website/public/* /www

# Cleanup
rm -R /temp/website

/bin/sh /after-deploy.sh