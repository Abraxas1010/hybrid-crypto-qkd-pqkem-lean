#!/usr/bin/env bash
set -euo pipefail

# Verify Hybrid Crypto PaperPack
# One-command verification: strict build, no sorry, sanity test

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

echo "=== Hybrid Crypto Verification ==="
echo "Working directory: $ROOT_DIR"
echo ""

# 1. Check for sorry/admit
echo "== Step 1: Checking for sorry/admit =="
if grep -rn --include="*.lean" -E '\bsorry\b|\badmit\b' HeytingLean/; then
  echo "ERROR: Found sorry or admit in codebase"
  exit 1
fi
echo "PASS: No sorry or admit found"
echo ""

# 2. Build with strict flags
echo "== Step 2: Building library (strict) =="
lake build --wfail
echo "PASS: Library build completed"
echo ""

# 3. Verify key files
echo "== Step 3: Verifying key modules =="
lake build HeytingLean.Crypto.Hybrid.QKDPQHybrid --wfail
lake build HeytingLean.Crypto.KEM.HybridKEM --wfail
lake build HeytingLean.Security.Composable.UC --wfail
lake build HeytingLean.Tests.Crypto.HybridSanity --wfail
echo "PASS: All key modules verified"
echo ""

echo "==================================="
echo "VERIFICATION PASSED"
echo "==================================="
