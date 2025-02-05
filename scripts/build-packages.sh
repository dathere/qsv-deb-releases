#!/bin/bash

# Check if version argument is provided
if [ -z "$1" ]; then
    echo "Error: Version number is required"
    echo "Usage: $0 <version>"
    exit 1
fi

VERSION=$1
ARCH="amd64"
BUILD_DIR="build"

# Function to check for errors
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Clean and create build directories
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/{qsv,qsvdp,qsvlite}/DEBIAN
mkdir -p ${BUILD_DIR}/{qsv,qsvdp,qsvlite}/usr/bin/

# Copy binaries (adjust paths as needed)
cp bin/qsv ${BUILD_DIR}/qsv/usr/bin/qsv
check_error "Failed to copy qsv binary"

cp bin/qsvdp ${BUILD_DIR}/qsvdp/usr/bin/qsvdp
check_error "Failed to copy qsvdp binary"

cp bin/qsvlite ${BUILD_DIR}/qsvlite/usr/bin/qsvlite
check_error "Failed to copy qsvlite binary"

# Set permissions
chmod 755 ${BUILD_DIR}/qsv/usr/bin/qsv
chmod 755 ${BUILD_DIR}/qsvdp/usr/bin/qsvdp
chmod 755 ${BUILD_DIR}/qsvlite/usr/bin/qsvlite

# Create control files
for pkg in qsv qsvdp qsvlite; do
    SIZE=$(du -sk ${BUILD_DIR}/${pkg} | cut -f1)
    
    # Determine package specific details
    case ${pkg} in
        qsv)
            DESC="Standard version"
            DEPS="libc6 (>= 2.34)"
            CONFLICTS="qsvdp, qsvlite"
            ;;
        qsvdp)
            DESC="DataPusher version"
            DEPS="libc6 (>= 2.34), libstdc++6 (>= 11)"
            CONFLICTS="qsv, qsvlite"
            ;;
        qsvlite)
            DESC="Lite version"
            DEPS="libc6 (>= 2.34)"
            CONFLICTS="qsv, qsvdp"
            ;;
    esac
    
    cat > ${BUILD_DIR}/${pkg}/DEBIAN/control << EOF
Package: ${pkg}
Version: ${VERSION}
Architecture: ${ARCH}
Maintainer: Konstantin Sivakov <konstantin@datHere.com>
Installed-Size: ${SIZE}
Depends: ${DEPS}
Conflicts: ${CONFLICTS}
Section: utility
Priority: optional
Homepage: https://qsv.dathere.com
Description: A Blazing-Fast Data-wrangling toolkit (${DESC}).
 A high performance CSV data-wrangling toolkit.
EOF
done

# Build the packages
for pkg in qsv qsvdp qsvlite; do
    dpkg-deb --build ${BUILD_DIR}/${pkg} ${pkg}_${VERSION}_${ARCH}.deb
    check_error "Failed to build ${pkg} package"
done

# Clean up
rm -rf ${BUILD_DIR}

echo "Packages built successfully!"
echo 
echo "Built packages:"
ls -l *.deb
echo
echo "Next steps:"
echo "1. Update the repository: ./update-repo.sh <your-gpg-email>"
echo "2. Test installation:"
echo "   sudo apt install qsv"
echo "   sudo apt install qsvdp"
echo "   sudo apt install qsvlite"