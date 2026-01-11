# Technical Report: Hybrid Crypto Formalization

## Overview

This formalization provides machine-checked specifications for hybrid cryptographic key establishment, combining:
- **Information-theoretic security** via QKD (modeled as UC ideal key exchange)
- **Computational security** via post-quantum KEMs

## Design Philosophy

### Interface-First Approach

Security predicates (`IND_CCA`, `KeySecure`, `UCSecure`) are defined with placeholder implementations (`True`). This approach:

1. **Establishes contracts**: The type signatures and composition structures are verified
2. **Enables incremental refinement**: Placeholder predicates can be replaced with game-based definitions
3. **Separates concerns**: Structural correctness is verified independently of cryptographic assumptions

### "Either Breaks" Security

The key insight formalized:

```
HybridSecure(π_qkd, K) ≡ UCSecure(F_KE, π_qkd) ∨ PQSecure(K)
```

If either component remains secure, the hybrid provides security. This is critical for:
- Quantum-safe transition (PQ protects against future quantum attacks)
- Defense in depth (QKD provides information-theoretic guarantees if PQ breaks)

## Key Formalizations

### KEMScheme (Abstract Interface)

```lean
structure KEMScheme where
  PublicKey : Type
  SecretKey : Type
  Ciphertext : Type
  SharedSecret : Type
  keygen : Unit → PublicKey × SecretKey
  encaps : PublicKey → Ciphertext × SharedSecret
  decaps : SecretKey → Ciphertext → Option SharedSecret
```

This captures the essential KEM API without implementation details.

### Hybrid Combiner

```lean
def hybridKEM (K1 K2 : KEMScheme) : KEMScheme where
  PublicKey := K1.PublicKey × K2.PublicKey
  SecretKey := K1.SecretKey × K2.SecretKey
  Ciphertext := K1.Ciphertext × K2.Ciphertext
  SharedSecret := K1.SharedSecret × K2.SharedSecret
  keygen := ...  -- run both, pair results
  encaps := ...  -- run both, pair results
  decaps := ...  -- run both, pair if both succeed
```

This is the X-Wing style parallel combiner.

### UC Framework

The UC framework provides:
- `IdealFunctionality`: Abstract ideal functionality interface
- `Protocol`: Real-world protocol implementation
- `Simulator`: Adversary simulator for ideal world
- `UCSecure`: Existence of simulator + indistinguishability

The framework is "interface-first" — the indistinguishability notion is existentially quantified, allowing different instantiations.

## Limitations

1. **Security predicates are placeholders**: The theorems are structurally correct but cryptographically vacuous until predicates are replaced
2. **No concrete KEM implementations**: The package works with abstract KEM interfaces
3. **Simplified UC model**: The UC framework omits many standard features (corruption, adaptive security, etc.)

## Future Work

Tracked via conjecture workflow:
- `kem_indcca_game.json`: Replace `IND_CCA` with game-based definition
- `uc_game_bridge.json`: Ground `UCSecure` in explicit game notion

## References

- Schwabe et al., "X-Wing: The Hybrid KEM You've Been Looking For" (ePrint 2024/039)
- Canetti, "Universally Composable Security" (FOCS 2001)
- NIST PQC Standardization
