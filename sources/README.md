# Source Materials Mirror

This directory contains (or documents) the upstream source materials for BSD 4.3 Quasijarus preservation.

## Upstream Sources to Mirror

### 1. Quasijarus BSD 4.3

**Primary URL:** http://ifctfvax.harhan.org/Quasijarus/

**Files to obtain:**
```
4.3BSD-Quasijarus0a.tar.gz
4.3BSD-Quasijarus0b.tar.gz
4.3BSD-Quasijarus0c.tar.gz   # Latest public release
patches/                      # All patch files
```

**Mirror command:**
```bash
wget -r -np -nH --cut-dirs=1 http://ifctfvax.harhan.org/Quasijarus/
```

### 2. TUHS BSD 4.3 Archives

**Primary URL:** https://www.tuhs.org/Archive/Distributions/UCB/

**Key directories:**
```
4.3BSD/           # Original 4.3BSD
4.3BSD-Tahoe/     # June 1988 CCI port
4.3BSD-Reno/      # June 1990 intermediate
4.3BSD-Net2/      # Networking Release 2
```

**Mirror command:**
```bash
rsync -avz tuhs.org::Archive/Distributions/UCB/4.3BSD* ./tuhs/
```

### 3. SIMH Source

**GitHub:** https://github.com/simh/simh
**OpenSIMH:** https://github.com/open-simh/simh

```bash
git clone https://github.com/simh/simh.git simh-upstream
git clone https://github.com/open-simh/simh.git opensimh-upstream
```

## Directory Structure

```
sources/
├── README.md           # This file
├── quasijarus/         # Quasijarus releases and patches
│   ├── releases/
│   └── patches/
├── tuhs/               # TUHS BSD 4.3 archives
│   ├── 4.3BSD/
│   ├── 4.3BSD-Tahoe/
│   └── 4.3BSD-Reno/
├── simh/               # SIMH emulator source
└── checksums/          # Verification files
    ├── SHA256SUMS
    └── MD5SUMS
```

## Verification

After downloading, verify against known checksums:
```bash
cd sources/quasijarus
sha256sum -c ../checksums/quasijarus.sha256

cd sources/tuhs
sha256sum -c ../checksums/tuhs.sha256
```

## Notes

- Large archives should be stored in GitHub Releases, not committed
- This directory is for documentation and small text/patch files
- Binary archives go in releases alongside disk images
- Consider using Archive.org as a secondary mirror

## Internet Archive Fallback

If primary sources become unavailable:
```
https://web.archive.org/web/*/http://ifctfvax.harhan.org/Quasijarus/
https://web.archive.org/web/*/https://www.tuhs.org/Archive/
```
