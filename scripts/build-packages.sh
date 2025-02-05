#!/bin/bash

# Check if version argument is provided
if [ -z "$1" ]; then
    echo "Error: Version number is required"
    echo "Usage: $0 <version>"
    exit 1
fi

VERSION="$1"
ARCH="amd64"
BUILD_DIR="build"

# Clean build directory
rm -rf ${BUILD_DIR}

# Create directory structure for each package
for pkg in qsv qsvdp qsvlite; do
    mkdir -p ${BUILD_DIR}/${pkg}/DEBIAN
    mkdir -p ${BUILD_DIR}/${pkg}/usr/lib/${pkg}/bin
    mkdir -p ${BUILD_DIR}/${pkg}/usr/bin
done

# Copy binaries and create symlinks (update paths as needed)
for pkg in qsv qsvdp qsvlite; do
    # Copy the binary to the lib directory
    if [ -f "../qsv/target/release/${pkg}" ]; then
        cp "../qsv/target/release/${pkg}" "${BUILD_DIR}/${pkg}/usr/lib/${pkg}/bin/${pkg}"
        chmod 755 "${BUILD_DIR}/${pkg}/usr/lib/${pkg}/bin/${pkg}"
        # Create symlink in /usr/bin
        (cd "${BUILD_DIR}/${pkg}/usr/bin" && ln -s "../lib/${pkg}/bin/${pkg}" "${pkg}")
    else
        echo "Warning: ${pkg} binary not found, using placeholder"
        echo "#!/bin/sh" > "${BUILD_DIR}/${pkg}/usr/lib/${pkg}/bin/${pkg}"
        echo "echo \"${pkg} binary\"" >> "${BUILD_DIR}/${pkg}/usr/lib/${pkg}/bin/${pkg}"
        chmod 755 "${BUILD_DIR}/${pkg}/usr/lib/${pkg}/bin/${pkg}"
        (cd "${BUILD_DIR}/${pkg}/usr/bin" && ln -s "../lib/${pkg}/bin/${pkg}" "${pkg}")
    fi
done

# Create control files
cat > ${BUILD_DIR}/qsv/DEBIAN/control << EOF
Package: qsv
Version: ${VERSION}
Architecture: ${ARCH}
Maintainer: Konstantin Sivakov <konstantin@datHere.com>
Installed-Size: 19393
Depends: libc6 (>= 2.34)
Section: utility
Priority: optional
Homepage: https://qsv.dathere.com
Description: A Blazing-Fast Data-wrangling toolkit (Standard version).
 A high performance CSV data-wrangling toolkit.
EOF

cat > ${BUILD_DIR}/qsvdp/DEBIAN/control << EOF
Package: qsvdp
Version: ${VERSION}
Architecture: ${ARCH}
Maintainer: Konstantin Sivakov <konstantin@datHere.com>
Installed-Size: 19599
Depends: libc6 (>= 2.34), libstdc++6 (>= 11)
Section: utility
Priority: optional
Homepage: https://qsv.dathere.com
Description: A Blazing-Fast Data-wrangling toolkit (DataPusher version).
 A high performance CSV data-wrangling toolkit.
EOF

cat > ${BUILD_DIR}/qsvlite/DEBIAN/control << EOF
Package: qsvlite
Version: ${VERSION}
Architecture: ${ARCH}
Maintainer: Konstantin Sivakov <konstantin@datHere.com>
Installed-Size: 15081
Depends: libc6 (>= 2.34)
Section: utility
Priority: optional
Homepage: https://qsv.dathere.com
Description: A Blazing-Fast Data-wrangling toolkit (Lite version).
 A high performance CSV data-wrangling toolkit.
EOF

# Build the packages
for pkg in qsv qsvdp qsvlite; do
    echo "Building ${pkg} package..."
    dpkg-deb --build ${BUILD_DIR}/${pkg} ${pkg}_${VERSION}_${ARCH}.deb
    ln -sf ${pkg}_${VERSION}_${ARCH}.deb ${pkg}.deb
done

# Generate Packages file
dpkg-scanpackages --multiversion . > Packages
gzip -k -f Packages

# Clean up
rm -rf ${BUILD_DIR}

echo "Packages built successfully!"
echo "Don't forget to run update-release.sh to sign the repository"
echo
echo "Next steps:"
echo "1. Sign the repository: ./scripts/update-release.sh <your-gpg-email>"
echo "2. Test installation:"
echo "   # Install all versions:"
echo "   sudo apt install qsv qsvdp qsvlite"
echo "   # Or install individually:"
echo "   sudo apt install qsv"
echo "   sudo apt install qsvdp"
echo "   sudo apt install qsvlite"