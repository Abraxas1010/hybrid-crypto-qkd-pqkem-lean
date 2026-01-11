# Proof Index

## Main Theorems

### Hybrid KEM Security

| Theorem | Statement | File:Line |
|---------|-----------|-----------|
| `hybrid_security_of_left` | IND-CCA(K1) → IND-CCA(hybridKEM K1 K2) | `HybridKEM.lean:62` |
| `hybrid_security_of_right` | IND-CCA(K2) → IND-CCA(hybridKEM K1 K2) | `HybridKEM.lean:67` |
| `hybrid_security_of_or` | (IND-CCA K1 ∨ IND-CCA K2) → IND-CCA(hybridKEM K1 K2) | `HybridKEM.lean:72` |

### Hybrid Key Source Security

| Theorem | Statement | File:Line |
|---------|-----------|-----------|
| `hybridKey_security_of_left` | KeySecure(S1) → KeySecure(hybridKeySource S1 S2) | `HybridKEM.lean:103` |
| `hybridKey_security_of_right` | KeySecure(S2) → KeySecure(hybridKeySource S1 S2) | `HybridKEM.lean:108` |
| `hybridKey_security_of_or` | (KeySecure S1 ∨ KeySecure S2) → KeySecure(hybridKeySource S1 S2) | `HybridKEM.lean:113` |

### QKD + PQ Hybrid Security

| Theorem | Statement | File:Line |
|---------|-----------|-----------|
| `hybrid_security` | (UCSecure F_KE π ∨ PQSecure K) → HybridSecure π K | `QKDPQHybrid.lean:42` |

### UC Composition

| Theorem | Statement | File:Line |
|---------|-----------|-----------|
| `uc_composition` | UCSecure(F₁, π₁) ∧ UCSecure(F₂, π₂) ∧ Uses(π₂, F₁) → UCSecure(F₂, compose(π₂, π₁)) | `Composition.lean:29` |

## Sanity Tests

| Test | Purpose | File |
|------|---------|------|
| `ke_uc_secure` | Demonstrates a trivial protocol is UC-secure | `HybridSanity.lean:23` |
| `example` | HybridSecure holds for toy KEM + trivial protocol | `HybridSanity.lean:37` |

## Key Definitions

| Definition | Description | File:Line |
|------------|-------------|-----------|
| `KEMScheme` | Abstract KEM interface (keygen, encaps, decaps) | `HybridKEM.lean:25` |
| `hybridKEM` | Product combiner for two KEMs | `HybridKEM.lean:44` |
| `KeySource` | Abstract key material source | `HybridKEM.lean:86` |
| `hybridKeySource` | Product combiner for two key sources | `HybridKEM.lean:99` |
| `IdealFunctionality` | UC ideal functionality interface | `IdealFunctionality.lean:17` |
| `Protocol` | UC protocol interface | `Simulator.lean:17` |
| `Simulator` | UC simulator interface | `Simulator.lean:28` |
| `UCSecure` | UC security predicate | `UC.lean:36` |
| `HybridKEM` (struct) | QKD key + PQ ciphertext/secret bundle | `QKDPQHybrid.lean:22` |
| `HybridSecure` | "Either breaks" hybrid security | `QKDPQHybrid.lean:37` |

## Placeholder Predicates (Interface-First)

These predicates are intentionally defined as `True` and tracked for replacement:

| Predicate | Purpose | Conjecture |
|-----------|---------|------------|
| `IND_CCA` | KEM security game | `conjectures/kem_indcca_game.json` |
| `KeySecure` | Key source security | (implicit in `kem_indcca_game`) |
| `PQSecure` | PQ-KEM security (delegates to IND_CCA) | (implicit in `kem_indcca_game`) |
| `Indistinguishable` in `UCSecure` | Real/ideal indistinguishability | `conjectures/uc_game_bridge.json` |
