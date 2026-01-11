# Axiom Audit

## Summary

This formalization uses **only standard Lean kernel axioms**. No project-specific axioms are introduced.

## Kernel Axioms Used

| Axiom | Purpose | Status |
|-------|---------|--------|
| `propext` | Propositional extensionality | Standard |
| `Classical.choice` | Axiom of choice | Standard |
| `Quot.sound` | Quotient soundness | Standard |

## Flagship Theorems

### `hybrid_security_of_or`

```
#print axioms HeytingLean.Crypto.KEM.hybrid_security_of_or
-- depends on axioms: [propext]
```

### `hybridKey_security_of_or`

```
#print axioms HeytingLean.Crypto.KEM.hybridKey_security_of_or
-- depends on axioms: [propext]
```

### `hybrid_security`

```
#print axioms HeytingLean.Crypto.Hybrid.hybrid_security
-- depends on axioms: [propext]
```

### `uc_composition`

```
#print axioms HeytingLean.Security.Composable.uc_composition
-- depends on axioms: [propext]
```

## Assumption Audit

### Mathematical Assumptions

None. All results follow from structural properties.

### Cryptographic Assumptions

The following predicates are **placeholders** (defined as `True`):

| Predicate | Intended Meaning | Placeholder |
|-----------|------------------|-------------|
| `IND_CCA` | IND-CCA security for KEMs | `True` |
| `KeySecure` | Security for key sources | `True` |
| `PQSecure` | PQ-KEM security | `IND_CCA` (= `True`) |
| `Indistinguishable` in `UCSecure` | Existentially quantified | Any relation works |

### Model Fidelity

The UC framework is simplified:
- No corruption model
- No adaptive security
- Indistinguishability is abstract

## No `sorry` or `admit`

Verified by `guard_no_sorry.sh`:
```bash
grep -rn --include="*.lean" -E '\bsorry\b|\badmit\b' HeytingLean/
# (no output = clean)
```

## Conclusion

The formalization is axiom-clean. Security guarantees are structural (verified composition patterns) rather than cryptographic (placeholder predicates). The conjectures track work to replace placeholders with game-based definitions.
