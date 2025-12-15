#!/bin/bash
# Run VAX 11/780 BSD 4.3 under SIMH
#
# Prerequisites: SIMH VAX emulator (vax780 or vax)
# Install via: brew install simh  OR  port install simh
#
# Disk images required (download from GitHub Releases):
#   - RA81.raw      : Main system disk (RAW format, 457MB)
#   - RA81-src.vhd  : Sources disk (VHD format, 406MB)
#   - boot43        : PDP-11 boot loader (22KB)
#
# Run ./download-images.sh to fetch disk images
#
# Networking: The config attaches to eth0 - may need adjustment for your system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check for required files
MISSING_FILES=()
for required_file in vax780.ini boot43 RA81.raw; do
    if [[ ! -f "$required_file" ]]; then
        MISSING_FILES+=("$required_file")
    fi
done

if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
    echo "ERROR: Missing required files:"
    for f in "${MISSING_FILES[@]}"; do
        echo "  - $f"
    done
    echo ""
    echo "Download disk images with: ./download-images.sh"
    echo "Or manually from: https://github.com/Oichkatzelesfrettschen/vax_machines/releases"
    exit 1
fi

# Find SIMH VAX emulator (different names across package managers)
VAX_EMU=""
for candidate in vax780 simh-vax780 vax simh-vax; do
    if command -v "$candidate" &>/dev/null; then
        VAX_EMU="$candidate"
        break
    fi
done

if [[ -z "$VAX_EMU" ]]; then
    echo "ERROR: SIMH VAX emulator not found"
    echo "Install with: brew install simh  OR  port install simh"
    exit 1
fi

echo "Starting VAX 11/780 BSD 4.3 with $VAX_EMU..."
echo "Console: telnet localhost 2324"
echo "Terminals: telnet localhost 2323"
echo "Press Ctrl-E for SIMH prompt, 'quit' to exit"
echo ""

exec "$VAX_EMU" vax780.ini
