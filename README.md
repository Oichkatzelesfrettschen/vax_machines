# VAX 11/780 BSD 4.3 (Quasijarus) SIMH Emulator

A pre-configured SIMH VAX 11/780 emulator running BSD 4.3 Quasijarus variant.

## Quick Start

```bash
# 1. Install SIMH (pick one)
brew install simh        # Homebrew
port install simh        # MacPorts

# 2. Download disk images from releases
./download-images.sh

# 3. Run
./run.sh
# Or directly: vax780 vax780.ini
```

**Console Access:**
- Main console: `telnet localhost 2324`
- Terminal multiplexer: `telnet localhost 2323`
- SIMH prompt: Press `Ctrl-E`, type `quit` to exit

**Default credentials:** `root` with no password (change immediately!)

## Disk Images (GitHub Releases)

Disk images are distributed via [GitHub Releases](../../releases) to save repository space:

```bash
./download-images.sh          # Download latest release
./download-images.sh v1.0.0   # Download specific version
./download-images.sh --check  # Verify existing images
```

| File | Size | Format | Description |
|------|------|--------|-------------|
| `RA81.vhd` | 237MB | VHD | Main BSD 4.3 system disk |
| `RA81-src.vhd` | 406MB | VHD | BSD 4.3 sources disk |
| `boot43` | 22KB | Binary | PDP-11 boot loader |

**Verify integrity:**
```bash
shasum -a 256 -c checksums.sha256
```

## System Configuration

### Hardware Emulation
- **CPU:** VAX 11/780 with 64MB RAM
- **Disks:** 2x RA81 MSCP drives (456MB each)
- **Network:** DEUNA Ethernet (static IP: 172.17.0.103/16)
- **Console:** DZ-11 terminal multiplexer (8 lines)
- **Tape:** TS11 magtape (not attached)

### Boot Parameters (vax780.ini)
| Register | Value | Meaning |
|----------|-------|---------|
| R10 | 9 | Boot device major ID (9=MSCP/RA) |
| R11 | 0 | Autoboot; 1=boot prompt; 2=single-user; 3=both |

## Provenance & Source Materials

### Origin
This disk image is based on **BSD 4.3 Quasijarus**, a Y2K-fixed variant created by Michael Sokolov. The SIMH configuration references `idle=QUASIJARUS` mode.

### Primary Sources

| Resource | URL | Description |
|----------|-----|-------------|
| **Quasijarus Project** | http://ifctfvax.harhan.org/Quasijarus/ | Michael Sokolov's BSD 4.3 fixes |
| **TUHS Archives** | https://www.tuhs.org/Archive/Distributions/UCB/ | Original BSD distributions |
| **SIMH** | https://github.com/simh/simh | Computer History Simulation |
| **OpenSIMH** | https://github.com/open-simh/simh | Actively maintained fork |

### Historical Context

**BSD 4.3 Timeline:**
- June 1986: BSD 4.3 original release (UC Berkeley)
- June 1988: BSD 4.3-Tahoe (CCI Power 6/32 port)
- June 1990: BSD 4.3-Reno (intermediate)
- 2000s: Quasijarus variant (Y2K fixes, Michael Sokolov)

### License & Copyright

See `licenses/` directory:
- **BSD-LICENSE.txt** - UC Berkeley BSD license
- **SIMH-LICENSE.txt** - MIT license (Robert M. Supnik)

**Copyright holders:**
- The Regents of the University of California (BSD)
- Caldera International (Unix 32V heritage)
- Robert M. Supnik (SIMH)
- Warren Toomey (TUHS archive organization)

## Disk Image Formats

### RAW vs VHD

| Format | Pros | Cons |
|--------|------|------|
| **RAW** (.000) | Simple, portable | Fixed size allocation |
| **VHD** (.001) | Sparse, auto-expands | Microsoft format |

**Recommendation:** Use VHD for new disks:
```simh
set rq0 ra81
set rq0 format=vhd
att rq0 -n newdisk.vhd
```

### Converting RAW to VHD (space savings)
```bash
# Using QEMU tools
qemu-img convert -f raw -O vpc RA81.000 RA81.vhd

# Or compress for archival
gzip -9 RA81.000  # ~60% compression typical
```

## Network Configuration

Default settings (Docker-oriented):
```
IP:      172.17.0.103/16
Gateway: 172.17.0.1
```

Edit on the guest system:
- `/etc/hosts`
- `/etc/networks`
- `/etc/rc.local`
- `/etc/resolv.conf`

**Services enabled:** TELNET, FTP (no SSH - 1986!)

## Included Software

Path | Description
-----|------------
`/usr/new/jove` | JOVE editor (Jonathan's Own Version of Emacs)
`/usr/new/kermit` | Kermit communications
`/usr/new/rcs` | Revision Control System
`/usr/local/bin/hora` | Y2K-aware date/time setter
`/usr/local/bin/zeros` | Disk zeroing utility (for compression)

## Directory Structure

```
vax_machines/
├── README.md           # This file
├── run.sh              # Launch script
├── vax780.ini          # SIMH configuration
├── boot43              # Boot loader (obtain from releases)
├── RA81.000            # System disk (obtain from releases)
├── RA81VHD.001         # Sources disk (obtain from releases)
├── docs/
│   └── VAXBSD-README.txt  # Original documentation
├── licenses/
│   ├── BSD-LICENSE.txt
│   └── SIMH-LICENSE.txt
└── sources/            # Upstream sources (optional mirror)
    └── README.md
```

## Emulator Compatibility

| Emulator | VAX Support | Recommended |
|----------|-------------|-------------|
| **SIMH** | Full (vax, vax780, vax8600) | Yes |
| **OpenSIMH** | Full (actively maintained) | Yes |
| **QEMU** | None | No |

Install either via:
```bash
brew install simh      # SIMH
brew install open-simh # OpenSIMH (if available)
```

## Related Projects

- [TUHS Unix Tree](https://minnie.tuhs.org/cgi-bin/utree.pl) - Browse historical Unix source
- [SIMH Documentation](http://simh.trailing-edge.com) - Emulator guides
- [BSD Family Tree](https://svnweb.freebsd.org/base/head/share/misc/bsd-family-tree) - BSD lineage

## Contributing

1. Fork this repository
2. Disk images should be attached to GitHub Releases (not committed to git)
3. Document any configuration changes
4. Test with both SIMH and OpenSIMH if possible

## Acknowledgments

- **Michael Sokolov** - Quasijarus BSD 4.3 Y2K fixes
- **Robert M. Supnik** - SIMH emulator
- **Warren Toomey** - TUHS archive curation
- **UC Berkeley CSRG** - Original BSD development
