#!/bin/bash
# build-and-update.sh

# Configuration
VERSION="2.2.1-1"
ARCH="amd64"
REPO_DIR="."
GITHUB_REPO="dathere/qsv-deb-releases"

# Create build directories
mkdir -p build/{qsv,qsv-dp,qsv-lite}/DEBIAN

# Create control files
cat > build/qsv/DEBIAN/control << EOF
Package: qsv
Version: ${VERSION}
Architecture: ${ARCH}
Maintainer: Konstantin Sivakov <konstantin@datHere.com>
Installed-Size: 19393
Depends: libc6 (>= 2.34)
Section: utility
Priority: optional
Homepage: https://qsv.dathere.com
Description: A Blazing-Fast Data-wrangling toolkit.
 A high performance CSV data-wrangling toolkit.
Conflicts: qsv-dp, qsv-lite
EOF

cat > build/qsv-dp/DEBIAN/control << EOF
Package: qsv-dp
Version: ${VERSION}
Architecture: ${ARCH}
Maintainer: Konstantin Sivakov <konstantin@datHere.com>
Installed-Size: 19599
Depends: libc6 (>= 2.34), libstdc++6 (>= 11)
Section: utility
Priority: optional
Homepage: https://qsv.dathere.com
Description: A Blazing-Fast Data-wrangling toolkit (DataPusher version).
 A high performance CSV data-wrangling toolkit with additional DataPusher features.
Conflicts: qsv, qsv-lite
Provides: qsvdp
EOF

cat > build/qsv-lite/DEBIAN/control << EOF
Package: qsv-lite
Version: ${VERSION}
Architecture: ${ARCH}
Maintainer: Konstantin Sivakov <konstantin@datHere.com>
Installed-Size: 15081
Depends: libc6 (>= 2.34)
Section: utility
Priority: optional
Homepage: https://qsv.dathere.com
Description: A Blazing-Fast Data-wrangling toolkit (Lite version).
 A lightweight version of the high performance CSV data-wrangling toolkit.
Conflicts: qsv, qsv-dp
Provides: qsvlite
EOF

# Create directory structure for binaries
mkdir -p build/{qsv,qsv-dp,qsv-lite}/usr/bin/

# Copy binaries 
# Note: Update these paths to match your binary locations
cp ../qsv build/qsv/usr/bin/qsv
cp ../qsvdp build/qsv-dp/usr/bin/qsvdp
cp ../qsvlite build/qsv-lite/usr/bin/qsvlite

# Set permissions
chmod 755 build/qsv/usr/bin/qsv
chmod 755 build/qsv-dp/usr/bin/qsvdp
chmod 755 build/qsv-lite/usr/bin/qsvlite

# Build the packages with standardized names
dpkg-deb --build build/qsv ${REPO_DIR}/qsv_${VERSION}_${ARCH}.deb
dpkg-deb --build build/qsv-dp ${REPO_DIR}/qsv-dp_${VERSION}_${ARCH}.deb
dpkg-deb --build build/qsv-lite ${REPO_DIR}/qsv-lite_${VERSION}_${ARCH}.deb

# Update Packages file
cd ${REPO_DIR}
dpkg-scanpackages . /dev/null > Packages
gzip -k -f Packages

# Create Release file
cat > Release << EOF
Origin: QSV Repository
Label: QSV
Suite: stable
Codename: stable
Version: 1.0
Architectures: amd64
Components: main
Description: A Blazing-Fast Data-wrangling toolkit.
 A high performance CSV data-wrangling toolkit.
Date: $(date -R)
EOF

# Clean up
rm -rf build

echo "Package build complete!"
echo "Don't forget to:"
echo "1. Commit and push the changes"
echo "2. Create a new release on GitHub with version ${VERSION}"
echo "3. Upload the .deb files to the release"
echo
echo "Users can add the repository using:"
echo "echo \"deb [trusted=yes] https://raw.githubusercontent.com/${GITHUB_REPO}/main ./\" | sudo tee /etc/apt/sources.list.d/qsv.list"