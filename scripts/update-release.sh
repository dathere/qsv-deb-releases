#!/bin/bash

# Check if email argument is provided
if [ -z "$1" ]; then
    echo "Error: Email address for GPG key is required"
    echo "Usage: $0 <email>"
    exit 1
fi

EMAIL=$1

# Function to check for errors
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Verify GPG key existence
gpg --list-keys "${EMAIL}" > /dev/null 2>&1
check_error "GPG key for ${EMAIL} not found"

echo "Creating Packages and Packages.gz files..."
# Add --multiversion to support multiple versions and architectures
dpkg-scanpackages --multiversion . > Packages
check_error "Failed to create Packages file"

gzip -k -f Packages
check_error "Failed to create Packages.gz"

echo "Creating Release file..."
# Enhanced Release file with more metadata
cat > Release.new << EOF
Origin: QSV Repository
Label: QSV Tools
Suite: stable
Codename: stable
Version: 1.0
Architectures: amd64
Components: main
Description: QSV - CSV Data-wrangling toolkit Repository
Date: $(date -R)
EOF

# Append checksums to Release file
apt-ftparchive release . >> Release.new
mv Release.new Release
check_error "Failed to create Release file"

echo "Signing Release file..."
# Create detached signature
gpg --default-key "${EMAIL}" -abs -o - Release > Release.gpg
check_error "Failed to create Release.gpg"

# Create inline signature
gpg --default-key "${EMAIL}" --clearsign -o - Release > InRelease
check_error "Failed to create InRelease"

echo "Verifying signatures..."
gpg --verify Release.gpg Release
gpg --verify InRelease

echo "Repository files updated successfully!"
echo
echo "Repository structure:"
echo "├── Packages        (Package index)"
echo "├── Packages.gz     (Compressed package index)"
echo "├── Release         (Repository metadata)"
echo "├── Release.gpg     (Detached signature)"
echo "└── InRelease       (Inline signed Release)"