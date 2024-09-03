#!/bin/bash

# Set email variable
EMAIL="konstantin@dathere.com"


echo "Creating Packages and Packages.gz files..."
dpkg-scanpackages --multiversion . > Packages
gzip -k -f Packages

echo "Creating Release, Release.gpg, and InRelease files..."
apt-ftparchive release . > Release
gpg --default-key "${EMAIL}" -abs -o - Release > Release.gpg
gpg --default-key "${EMAIL}" --clearsign -o - Release > InRelease

echo "PPA update completed successfully!"