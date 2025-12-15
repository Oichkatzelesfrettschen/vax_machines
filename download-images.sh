#!/bin/bash
# Download disk images from GitHub Releases
#
# This script fetches the large disk image files that are stored as
# GitHub Release artifacts (not in the git repository to save space).
#
# Usage:
#   ./download-images.sh              # Download latest release
#   ./download-images.sh v1.0.0       # Download specific version
#   ./download-images.sh --check      # Verify existing images
#
# Required: curl or wget, and optionally gh (GitHub CLI) for private repos

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configure these for your repository
REPO_OWNER="${REPO_OWNER:-YOUR_USERNAME}"
REPO_NAME="${REPO_NAME:-vax_machines}"
RELEASE_TAG="${1:-latest}"

# Files to download (VHD format for sparse storage)
DISK_FILES=(
    "boot43"          # 22KB  - PDP-11 boot loader
    "RA81.vhd"        # 237MB - Main BSD 4.3 system disk
    "RA81-src.vhd"    # 406MB - BSD 4.3 sources disk
)

# Checksums file
CHECKSUMS_FILE="checksums.sha256"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] [VERSION]

Download disk images from GitHub Releases.

Options:
    --check     Verify existing images against checksums
    --list      List available releases
    --help      Show this help message

Examples:
    $0              Download latest release
    $0 v1.0.0       Download specific version
    $0 --check      Verify existing files

Environment:
    REPO_OWNER      GitHub username/org (default: YOUR_USERNAME)
    REPO_NAME       Repository name (default: vax_machines)
EOF
}

check_dependencies() {
    if command -v gh &>/dev/null; then
        DOWNLOAD_METHOD="gh"
    elif command -v curl &>/dev/null; then
        DOWNLOAD_METHOD="curl"
    elif command -v wget &>/dev/null; then
        DOWNLOAD_METHOD="wget"
    else
        log_error "No download tool found. Install: gh, curl, or wget"
        exit 1
    fi
    log_info "Using download method: $DOWNLOAD_METHOD"
}

get_release_url() {
    local tag="$1"
    if [[ "$tag" == "latest" ]]; then
        echo "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
    else
        echo "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${tag}"
    fi
}

download_file() {
    local url="$1"
    local output="$2"

    log_info "Downloading: $output"

    case "$DOWNLOAD_METHOD" in
        gh)
            gh release download "$RELEASE_TAG" --pattern "$output" --repo "${REPO_OWNER}/${REPO_NAME}" --clobber
            ;;
        curl)
            curl -L -o "$output" "$url"
            ;;
        wget)
            wget -O "$output" "$url"
            ;;
    esac
}

list_releases() {
    log_info "Available releases for ${REPO_OWNER}/${REPO_NAME}:"
    if command -v gh &>/dev/null; then
        gh release list --repo "${REPO_OWNER}/${REPO_NAME}"
    else
        curl -s "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases" | \
            grep -E '"tag_name"|"name"' | head -20
    fi
}

verify_checksums() {
    if [[ ! -f "$CHECKSUMS_FILE" ]]; then
        log_warn "No checksums file found. Downloading..."
        download_checksums
    fi

    log_info "Verifying checksums..."
    if shasum -a 256 -c "$CHECKSUMS_FILE" 2>/dev/null; then
        log_info "All files verified successfully!"
        return 0
    else
        log_error "Checksum verification failed!"
        return 1
    fi
}

download_checksums() {
    if [[ "$DOWNLOAD_METHOD" == "gh" ]]; then
        gh release download "$RELEASE_TAG" --pattern "$CHECKSUMS_FILE" \
            --repo "${REPO_OWNER}/${REPO_NAME}" --clobber 2>/dev/null || true
    fi
}

download_all() {
    log_info "Downloading disk images (release: $RELEASE_TAG)..."

    check_dependencies

    # Download checksums first
    download_checksums

    # Download each file
    for file in "${DISK_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            log_warn "$file already exists, skipping (use --force to overwrite)"
            continue
        fi

        if [[ "$DOWNLOAD_METHOD" == "gh" ]]; then
            gh release download "$RELEASE_TAG" --pattern "$file" \
                --repo "${REPO_OWNER}/${REPO_NAME}" --clobber || \
                log_warn "Could not download $file (may not exist in release)"
        else
            # For curl/wget, we need to get the asset URL from the API
            log_warn "For best results, install GitHub CLI: brew install gh"
            log_info "Manual download URL: https://github.com/${REPO_OWNER}/${REPO_NAME}/releases"
        fi
    done

    # Verify if checksums available
    if [[ -f "$CHECKSUMS_FILE" ]]; then
        verify_checksums
    fi

    log_info "Done! Run ./run.sh to start the emulator."
}

# Parse arguments
case "${1:-}" in
    --help|-h)
        usage
        exit 0
        ;;
    --check)
        verify_checksums
        exit $?
        ;;
    --list)
        check_dependencies
        list_releases
        exit 0
        ;;
    *)
        download_all
        ;;
esac
