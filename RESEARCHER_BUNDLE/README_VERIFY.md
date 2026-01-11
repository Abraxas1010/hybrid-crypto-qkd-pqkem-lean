# Verification Instructions

## One-Command Verification

```bash
./scripts/verify_hybrid.sh
```

## What This Checks

1. **No sorry/admit**: Scans all `.lean` files for incomplete proofs
2. **Strict build**: Runs `lake build --wfail` (warnings are errors)
3. **Key modules**: Verifies core hybrid crypto modules compile

## Expected Output

```
=== Hybrid Crypto Verification ===
Working directory: /path/to/RESEARCHER_BUNDLE

== Step 1: Checking for sorry/admit ==
PASS: No sorry or admit found

== Step 2: Building library (strict) ==
PASS: Library build completed

== Step 3: Verifying key modules ==
PASS: All key modules verified

===================================
VERIFICATION PASSED
===================================
```

## Manual Verification

```bash
# Check for sorry/admit
grep -rn --include="*.lean" -E '\bsorry\b|\badmit\b' HeytingLean/

# Build with strict flags
lake build --wfail

# Build specific modules
lake build HeytingLean.Crypto.Hybrid.QKDPQHybrid --wfail
lake build HeytingLean.Crypto.KEM.HybridKEM --wfail
lake build HeytingLean.Tests.Crypto.HybridSanity --wfail
```

## Troubleshooting

If build fails:
```bash
lake clean
lake update
lake build --wfail
```
