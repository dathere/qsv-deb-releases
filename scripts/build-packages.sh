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
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Function to check for errors
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

cd "$REPO_DIR"

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/{qsv,qsvdp,qsvlite}/DEBIAN
mkdir -p ${BUILD_DIR}/{qsv,qsvdp,qsvlite}/usr/bin/

QSV_PATH="../qsv" 
QSVDP_PATH="../qsvdp" 
QSVLITE_PATH="../qsvlite"

if [ -f "$QSV_PATH" ]; then
    cp "$QSV_PATH" ${BUILD_DIR}/qsv/usr/bin/qsv
    chmod 755 ${BUILD_DIR}/qsv/usr/bin/qsv
else
    echo "Warning: qsv binary not found at $QSV_PATH"
fi

if [ -f "$QSVDP_PATH" ]; then
    cp "$QSVDP_PATH" ${BUILD_DIR}/qsvdp/usr/bin/qsvdp
    chmod 755 ${BUILD_DIR}/qsvdp/usr/bin/qsvdp
else
    echo "Warning: qsvdp binary not found at $QSVDP_PATH"
fi

if [ -f "$QSVLITE_PATH" ]; then
    cp "$QSVLITE_PATH" ${BUILD_DIR}/qsvlite/usr/bin/qsvlite
    chmod 755 ${BUILD_DIR}/qsvlite/usr/bin/qsvlite
else
    echo "Warning: qsvlite binary not found at $QSVLITE_PATH"
fi

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
Section: utility
Priority: optional
Homepage: https://qsv.dathere.com
Description: A Blazing-Fast Data-wrangling toolkit (${DESC}).
 A high performance CSV data-wrangling toolkit.
EOF
done

# Build the packages
for pkg in qsv qsvdp qsvlite; do
    echo "Building ${pkg} package..."
    dpkg-deb --build ${BUILD_DIR}/${pkg} ${pkg}_${VERSION}_${ARCH}.deb
    check_error "Failed to build ${pkg} package"
    
    # Create symlinks for latest versions
    ln -sf ${pkg}_${VERSION}_${ARCH}.deb ${pkg}.deb
done

rm -rf ${BUILD_DIR}

echo "Packages built successfully!"
echo 
echo "Built packages:"
ls -l *.deb
echo
echo "Next steps:"
echo "1. Run the update release script: ./scripts/update-release.sh <your-gpg-email>"
echo "2. Test installation:"
echo "   sudo apt install qsv"
echo "   sudo apt install qsvdp"
echo "   sudo apt install qsvlite"