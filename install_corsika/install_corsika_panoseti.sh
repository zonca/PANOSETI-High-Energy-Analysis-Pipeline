#!/bin/bash

# Install CORSIKA 7.755 with PANOSETI requirements
# Compiling with: QGSJET-II-04, URQMD 1.3cr, IACT, CHERENKOV, ATMEXT, VOLUMEDET

cd corsika-77550

echo "Cleaning previous installation..."
make distclean 2>/dev/null || true

echo "Extracting bernlohr package (required for IACT)..."
cd bernlohr
tar -xzf bernlohr-1.67.tar.gz
cd ..

echo ""
echo "Installing CORSIKA 7.755 with PANOSETI configuration:"
echo "  - High energy model: QGSJET-II-04"
echo "  - Low energy model: URQMD 1.3cr"
echo "  - Detector geometry: Volume detector (VOLUMEDET)"
echo "  - Options:"
echo "    * IACT (Cherenkov telescope detector)"
echo "    * CHERENKOV (Cherenkov radiation)"
echo "    * ATMEXT (external atmosphere)"
echo ""

./coconut --no-cache << COCONUT_INPUTS
2
5
4
2
1b
z
y
f
COCONUT_INPUTS

if [ $? -eq 0 ]; then
    echo ""
    echo "CORSIKA 7.755 with PANOSETI options compiled successfully!"
    echo ""
    echo "Executable: corsika-77550/run/corsika77550Linux_QGSII_urqmd"
    echo ""
    ls -lh corsika-77550/run/corsika77550Linux_QGSII_urqmd
    echo ""
    echo "Configuration:"
    echo "  - QGSJET-II-04 (high energy hadronic model)"
    echo "  - URQMD 1.3cr (low energy hadronic model)"
    echo "  - VOLUMEDET (volume detector geometry)"
    echo "  - IACT (Cherenkov telescope detector - uses bernlohr)"
    echo "  - CHERENKOV (Cherenkov radiation generation)"
    echo "  - ATMEXT (external atmosphere functions)"
else
    echo ""
    echo "Error: CORSIKA installation failed!"
    exit 1
fi