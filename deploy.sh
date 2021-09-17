#!/bin/ash

# Fetch website
git clone $HUGO_REPOSITORY --recurse-submodules /temp/website

# Build Website to www mount
hugo -s /temp/website -d /www
chown nobody:nogroup -R /www

# Cleanup
rm -R /temp/website