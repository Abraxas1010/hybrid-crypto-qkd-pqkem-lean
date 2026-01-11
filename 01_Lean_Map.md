# Concept → Lean Mapping

This document maps cryptographic concepts to their Lean 4 formalizations.

## Core Concepts

| Concept | Lean Definition | File |
|---------|-----------------|------|
| KEM Interface | `KEMScheme` | `HeytingLean/Crypto/KEM/HybridKEM.lean` |
| Hybrid KEM Combiner | `hybridKEM` | `HeytingLean/Crypto/KEM/HybridKEM.lean` |
| Key Source Interface | `KeySource` | `HeytingLean/Crypto/KEM/HybridKEM.lean` |
| Hybrid Key Source | `hybridKeySource` | `HeytingLean/Crypto/KEM/HybridKEM.lean` |
| IND-CCA Security (placeholder) | `IND_CCA` | `HeytingLean/Crypto/KEM/HybridKEM.lean` |
| Key Source Security (placeholder) | `KeySecure` | `HeytingLean/Crypto/KEM/HybridKEM.lean` |

## UC Framework

| Concept | Lean Definition | File |
|---------|-----------------|------|
| Ideal Functionality | `IdealFunctionality` | `HeytingLean/Security/Composable/IdealFunctionality.lean` |
| Protocol | `Protocol` | `HeytingLean/Security/Composable/Simulator.lean` |
| Simulator | `Simulator` | `HeytingLean/Security/Composable/Simulator.lean` |
| UC Security | `UCSecure` | `HeytingLean/Security/Composable/UC.lean` |
| Real Execution | `realExecution` | `HeytingLean/Security/Composable/UC.lean` |
| Ideal Execution | `idealExecution` | `HeytingLean/Security/Composable/UC.lean` |
| Composition Kit | `CompositionKit` | `HeytingLean/Security/Composable/Composition.lean` |
| Ideal Key Exchange (F_KE) | `IdealKeyExchange` | `HeytingLean/Security/Composable/Instances/IdealKeyExchange.lean` |

## QKD + PQ Hybrid

| Concept | Lean Definition | File |
|---------|-----------------|------|
| Hybrid Key Material | `HybridKEM` (struct) | `HeytingLean/Crypto/Hybrid/QKDPQHybrid.lean` |
| Combined Key | `HybridKEM.combined` | `HeytingLean/Crypto/Hybrid/QKDPQHybrid.lean` |
| PQ Security (placeholder) | `PQSecure` | `HeytingLean/Crypto/Hybrid/QKDPQHybrid.lean` |
| Hybrid Security | `HybridSecure` | `HeytingLean/Crypto/Hybrid/QKDPQHybrid.lean` |

## Namespace Structure

```
HeytingLean
├── Crypto
│   ├── Composable          -- UC compatibility re-exports
│   ├── Hybrid
│   │   └── QKDPQHybrid     -- QKD + PQ KEM hybrid
│   └── KEM
│       └── HybridKEM       -- Abstract KEM + hybrid combiner
├── Security
│   └── Composable
│       ├── UC              -- Real/ideal paradigm
│       ├── IdealFunctionality
│       ├── Simulator
│       ├── Composition
│       └── Instances
│           ├── IdealKeyExchange
│           └── IdealSecureChannel
└── Tests
    └── Crypto
        └── HybridSanity    -- Sanity checks
```
