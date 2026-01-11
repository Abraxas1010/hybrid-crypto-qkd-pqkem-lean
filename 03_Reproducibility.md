# Reproducibility Guide

## Quick Verification

```bash
cd RESEARCHER_BUNDLE
./scripts/verify_hybrid.sh
```

This runs:
1. `sorry`/`admit` scan (must find zero)
2. Strict library build (`lake build --wfail`)
3. Key module verification

## Manual Build Steps

### Prerequisites

- Lean 4 toolchain (version pinned in `lean-toolchain`)
- `elan` (Lean version manager)

### Install Toolchain

```bash
cd RESEARCHER_BUNDLE
elan override set $(cat lean-toolchain)
```

### Fetch Dependencies

```bash
cd RESEARCHER_BUNDLE
lake exe cache get  # if mathlib cache available
lake update
```

### Build Library

```bash
cd RESEARCHER_BUNDLE
lake build --wfail
```

### Build Specific Modules

```bash
lake build HeytingLean.Crypto.Hybrid.QKDPQHybrid --wfail
lake build HeytingLean.Crypto.KEM.HybridKEM --wfail
lake build HeytingLean.Security.Composable.UC --wfail
lake build HeytingLean.Tests.Crypto.HybridSanity --wfail
```

## Expected Output

A successful build should:
- Complete without errors
- Show no `sorry` or `admit` warnings
- Pass all type checking

## Generating UMAP Visualizations

```bash
cd RESEARCHER_BUNDLE
pip install numpy umap-learn  # if not installed
python3 scripts/generate_umap_previews.py \
  --lean-dir HeytingLean \
  --out-dir artifacts/visuals
```

## Troubleshooting

### Cache Issues

If build fails with missing dependencies:
```bash
lake clean
lake update
lake build --wfail
```

### Toolchain Mismatch

Ensure correct Lean version:
```bash
elan show
# Should match lean-toolchain file
```
