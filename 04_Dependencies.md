# Dependencies

## Lean Toolchain

- **Lean version**: 4.24.0 (see `lean-toolchain`)
- **Lake**: Bundled with Lean

## Mathlib

- **Repository**: https://github.com/leanprover-community/mathlib4
- **Version**: v4.24.0
- **Commit**: See `lake-manifest.json`

## Python (for visualizations)

Optional dependencies for UMAP generation:
- `numpy`
- `umap-learn`

Install via:
```bash
pip install numpy umap-learn
```

## Version Pinning

All versions are locked in:
- `lean-toolchain`: Lean version
- `lake-manifest.json`: Transitive dependency pins
- `lakefile.lean`: Direct dependency declarations

## Updating Dependencies

To update mathlib (not recommended for reproducibility):
```bash
lake update mathlib
lake build --wfail
```

## Minimal Dependencies

This package is intentionally lightweight. It depends on:
1. Lean 4 standard library
2. Mathlib (for basic algebraic structures)

No external cryptographic libraries or FFI bindings are required.
