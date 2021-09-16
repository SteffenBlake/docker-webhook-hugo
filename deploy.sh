#!/bin/ash

# Fetch website
mkdir /temp
git clone $HUGO_REPOSITORY --recurse-submodules /temp

# Build Website to www mount
hugo -s /temp -d /www
chown nobody:nogroup -R /www

# Cleanup
rm -R /temp