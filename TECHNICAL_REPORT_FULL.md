# Toward Verified Hybrid Cryptography: A Lean 4 Formalization of QKD + Post-Quantum KEM Composition

**Technical Report for ResearchGate Publication**

*Version 1.0 — January 2026*

---

## Abstract

We present a Lean 4 formalization of hybrid key establishment protocols that combine quantum key distribution (QKD) with post-quantum key encapsulation mechanisms (PQ-KEM). Our work provides machine-checked specifications for: (1) an abstract KEM interface with a parallel hybrid combiner in the style of X-Wing; (2) a lightweight Universal Composability (UC) framework capturing the real/ideal simulation paradigm; and (3) an "either-breaks" security theorem establishing that hybrid security holds if either component remains secure.

**Honest Assessment**: This formalization follows an *interface-first* methodology where security predicates (IND-CCA, UC indistinguishability) are defined as placeholders. The theorems are *structurally verified*—the composition patterns and type signatures are machine-checked—but the security guarantees are *cryptographically vacuous* until placeholders are replaced with game-based definitions. We explicitly document this limitation and provide a roadmap for completing the formalization.

**Contribution**: We demonstrate that proof assistants can capture the *architecture* of hybrid cryptographic constructions with full rigor, establishing verified scaffolding that future work can instantiate with concrete security reductions.

---

## 1. Introduction

### 1.1 The Quantum Threat and Hybrid Cryptography

The development of large-scale quantum computers poses an existential threat to classical public-key cryptography. Shor's algorithm (1994) enables efficient factoring and discrete logarithm computation, breaking RSA, DSA, and elliptic curve cryptography. In response, the cryptographic community has pursued two complementary approaches:

1. **Post-Quantum Cryptography (PQC)**: Algorithms believed resistant to quantum attack, based on mathematical problems such as lattice problems (Learning With Errors), hash functions, codes, and multivariate equations. NIST finalized FIPS 203 (ML-KEM), FIPS 204 (ML-DSA), and FIPS 205 (SLH-DSA) in August 2024 [1].

2. **Quantum Key Distribution (QKD)**: Protocols exploiting quantum mechanical properties to establish shared keys with information-theoretic security. BB84 (Bennett-Brassard, 1984) remains the foundational protocol, with security based on the no-cloning theorem rather than computational assumptions [2].

**Hybrid constructions** combine both approaches, providing security if *either* component remains unbroken. This "belt and suspenders" strategy is critical during the transition period when:
- PQC algorithms are newly deployed and may harbor undiscovered weaknesses
- QKD implementations may have side-channel vulnerabilities
- Regulatory requirements mandate classical algorithms alongside PQC

The X-Wing hybrid KEM [3], combining X25519 with ML-KEM-768, exemplifies this approach and is progressing through IETF standardization (draft-connolly-cfrg-xwing-kem-09, September 2025) [4].

### 1.2 The Verification Gap

Despite extensive cryptographic research, formal verification of hybrid constructions lags significantly behind:

1. **UC Framework Complexity**: Canetti's Universal Composability framework [5] provides powerful composition guarantees but is notoriously difficult to mechanize. The EasyUC project [6] represents the state-of-the-art, using EasyCrypt to verify UC proofs, but requires substantial expertise.

2. **QKD Verification Challenges**: Security proofs for QKD protocols like BB84 involve quantum information theory, entanglement, and unconditional security arguments. Recent work [7] identifies significant gaps in existing proofs and calls for more rigorous, verifiable treatments.

3. **Hybrid Security Arguments**: The "either-breaks" security property of hybrids requires reasoning about the composition of computational and information-theoretic security—a non-trivial task even informally.

### 1.3 Our Approach and Contributions

We take an *interface-first* approach: rather than attempting a complete cryptographic proof, we formalize the *structure* of hybrid key establishment in Lean 4, establishing:

**What We Formally Verify (Machine-Checked)**:
- Type signatures and API contracts for KEMs, key sources, and UC components
- The hybrid combiner construction (parallel composition of two KEMs)
- Composition theorems relating component security to hybrid security
- Absence of `sorry` or `admit` (all proof terms are closed)

**What Remains Placeholder (Explicitly Documented)**:
- `IND_CCA : KEMScheme → Prop := True` (KEM security predicate)
- `KeySecure : KeySource → Prop := True` (key source security)
- `Indistinguishable` in `UCSecure` (existentially quantified, any relation works)

**Why This Matters**:
- Establishes verified scaffolding for future instantiation
- Catches structural errors (type mismatches, missing assumptions) that informal proofs miss
- Provides a template for hybrid constructions in Lean 4
- Documents the gap between specification and proof in formal cryptography

---

## 2. Background: Universal Composability

### 2.1 The UC Framework

Canetti's Universal Composability (UC) framework [5] provides a rigorous foundation for analyzing cryptographic protocols under arbitrary composition. The key insight is the *simulation paradigm*: a protocol π securely realizes an ideal functionality F if no environment can distinguish between:

1. **Real World**: The environment interacts with parties running π
2. **Ideal World**: The environment interacts with a simulator S that has access to F

Formally, for all environments Z:
$$\text{EXEC}_{π,A,Z} \approx \text{EXEC}_{F,S,Z}$$

where ≈ denotes computational indistinguishability.

### 2.2 Composition Theorem

The UC Composition Theorem states: if protocol π UC-realizes F, then π can replace F in any larger protocol ρ that uses F as a subroutine, preserving security. This enables modular protocol design—components can be analyzed independently and composed safely.

### 2.3 Our UC Formalization

We formalize a lightweight UC framework in Lean 4:

```lean
/-- Ideal functionality interface -/
structure IdealFunctionality where
  Input : Type
  Output : Type
  Leakage : Type
  compute : Input → Output × Leakage

/-- Protocol implementing a functionality -/
structure Protocol (F : IdealFunctionality) where
  State : Type
  Message : Type
  init : State
  execute : F.Input → State → F.Output × Message × State

/-- Simulator translating ideal leakage to protocol messages -/
structure Simulator (F : IdealFunctionality) (π : Protocol F) where
  SimState : Type
  init : SimState
  simulate : F.Leakage → SimState → π.Message × SimState

/-- UC Security: existence of simulator with indistinguishability -/
def UCSecure (F : IdealFunctionality) (π : Protocol F) : Prop :=
  ∃ sim : Simulator F π,
    ∃ Indistinguishable : (F.Input → F.Output × π.Message) →
                          (F.Input → F.Output × π.Message) → Prop,
      Indistinguishable (realExecution π) (idealExecution π sim)
```

**Critical Limitation**: The `Indistinguishable` predicate is existentially quantified. This means *any* protocol trivially satisfies `UCSecure` by choosing `Indistinguishable := fun _ _ => True`. The definition captures the *shape* of UC security but not its *content*.

### 2.4 Comparison with Prior Work

| Approach | Framework | Completeness | Mechanization |
|----------|-----------|--------------|---------------|
| EasyUC [6] | EasyCrypt | Full UC proofs | High |
| CryptoVerif | Probabilistic | Game-based | Medium |
| FCF (Coq) | Foundational | Game-based | High |
| **This work** | Lean 4 | Interface-only | High (structure) |

Our work trades cryptographic completeness for accessibility and rapid prototyping. The goal is verified scaffolding, not verified security.

---

## 3. Hybrid KEM Formalization

### 3.1 Abstract KEM Interface

We define a minimal KEM interface capturing the essential operations:

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

This follows the standard KEM syntax from NIST FIPS 203 [1]:
- `keygen`: Generate a key pair
- `encaps`: Encapsulate a shared secret under a public key
- `decaps`: Decapsulate to recover the shared secret

### 3.2 Hybrid Combiner

The parallel hybrid combiner runs both KEMs independently and pairs the results:

```lean
def hybridKEM (K1 K2 : KEMScheme) : KEMScheme where
  PublicKey := K1.PublicKey × K2.PublicKey
  SecretKey := K1.SecretKey × K2.SecretKey
  Ciphertext := K1.Ciphertext × K2.Ciphertext
  SharedSecret := K1.SharedSecret × K2.SharedSecret
  keygen := fun () =>
    let (pk1, sk1) := K1.keygen ()
    let (pk2, sk2) := K2.keygen ()
    ((pk1, pk2), (sk1, sk2))
  encaps := fun (pk1, pk2) =>
    let (ct1, ss1) := K1.encaps pk1
    let (ct2, ss2) := K2.encaps pk2
    ((ct1, ct2), (ss1, ss2))
  decaps := fun (sk1, sk2) (ct1, ct2) =>
    match K1.decaps sk1 ct1, K2.decaps sk2 ct2 with
    | some ss1, some ss2 => some (ss1, ss2)
    | _, _ => none
```

This matches the X-Wing construction [3], which combines X25519 and ML-KEM-768 with a KDF to derive the final shared secret.

### 3.3 Security Predicates (Placeholder)

```lean
/-- IND-CCA security predicate (PLACEHOLDER) -/
def IND_CCA (_K : KEMScheme) : Prop := True
```

**What IND-CCA Should Mean**: In a complete formalization, IND-CCA (Indistinguishability under Chosen Ciphertext Attack) would be defined via a cryptographic game:

1. Challenger generates (pk, sk) ← K.keygen()
2. Adversary receives pk and access to decapsulation oracle
3. Challenger computes (ct*, ss0) ← K.encaps(pk), samples ss1 ← random, flips coin b
4. Adversary receives (ct*, ss_b) and must guess b
5. K is IND-CCA secure if advantage |Pr[guess = b] - 1/2| is negligible

Formalizing this requires:
- A probabilistic programming framework
- Adversary modeling (polynomial-time, oracle access)
- Negligible function definitions
- Concrete security bounds

### 3.4 Security Theorems

```lean
theorem hybrid_security_of_or (K1 K2 : KEMScheme) :
    (IND_CCA K1 ∨ IND_CCA K2) → IND_CCA (hybridKEM K1 K2) := by
  intro h
  cases h with
  | inl h1 => exact hybrid_security_of_left K1 K2 h1
  | inr h2 => exact hybrid_security_of_right K1 K2 h2
```

**What This Theorem Says**: If either K1 or K2 is IND-CCA secure, then the hybrid is IND-CCA secure.

**What This Theorem Actually Proves**: Since `IND_CCA` is defined as `True`, the theorem reduces to `True → True`, which is trivially provable. The *structure* of the proof (case analysis on the disjunction) is verified, but the *cryptographic content* is vacuous.

**What a Real Proof Would Require**: A game-hopping argument showing:
1. If K1 is IND-CCA, construct a reduction from hybrid security to K1 security
2. If K2 is IND-CCA, construct a reduction from hybrid security to K2 security
3. Bound the advantage in terms of the component advantages

---

## 4. QKD + PQ Hybrid Specification

### 4.1 Ideal Key Exchange Functionality

We model QKD via the ideal key exchange functionality F_KE:

```lean
def IdealKeyExchange (keyLen : Nat) : IdealFunctionality where
  Input := Unit
  Output := Fin keyLen → Bool  -- n-bit key
  Leakage := Unit              -- no information leaked
  compute := fun _ => (fun _ => false, ())
```

This captures the *ideal* behavior of QKD: parties receive identical random keys with no information leakage. A real QKD protocol (like BB84) would be proven to UC-realize this functionality under appropriate assumptions.

### 4.2 Hybrid Key Material

```lean
structure HybridKEM (n : Nat) (K : KEMScheme) where
  qkd_key : Fin n → Bool        -- QKD-derived key
  pq_ciphertext : K.Ciphertext  -- PQ-KEM ciphertext
  pq_sharedSecret : K.SharedSecret
```

### 4.3 "Either-Breaks" Security

```lean
def HybridSecure {n : Nat}
    (πqkd : Protocol (IdealKeyExchange n))
    (K : KEMScheme) : Prop :=
  UCSecure (IdealKeyExchange n) πqkd ∨ PQSecure K

theorem hybrid_security {n : Nat}
    (πqkd : Protocol (IdealKeyExchange n))
    (K : KEMScheme) :
    (UCSecure (IdealKeyExchange n) πqkd ∨ PQSecure K) →
      HybridSecure πqkd K := by
  intro h
  exact h
```

**Interpretation**: The hybrid provides security if either:
1. The QKD protocol UC-realizes ideal key exchange (information-theoretic security), OR
2. The PQ-KEM is IND-CCA secure (computational security)

This is precisely the "belt and suspenders" property motivating hybrid deployment.

---

## 5. Axiom and Assumption Audit

### 5.1 Lean Kernel Axioms

All theorems depend only on standard Lean kernel axioms:

| Axiom | Usage | Justification |
|-------|-------|---------------|
| `propext` | Propositional extensionality | Standard in classical logic |
| `Classical.choice` | Axiom of choice | Required for classical reasoning |
| `Quot.sound` | Quotient soundness | Required for quotient types |

**No project-specific axioms are introduced.**

### 5.2 Placeholder Summary

| Predicate | Definition | Intended Meaning |
|-----------|------------|------------------|
| `IND_CCA` | `True` | KEM indistinguishability under CCA |
| `KeySecure` | `True` | Key source security |
| `PQSecure` | `IND_CCA` (= `True`) | PQ-KEM security |
| `Indistinguishable` | Existentially quantified | Real/ideal indistinguishability |

### 5.3 Verification Status

```
✓ No sorry or admit in codebase (guard_no_sorry.sh passes)
✓ All modules compile with --wfail (warnings as errors)
✓ Type signatures are machine-checked
✗ Security predicates are placeholder (no cryptographic content)
✗ Reductions not formalized (no game-hopping proofs)
✗ Probability/adversary model not implemented
```

---

## 6. Honest Assessment: What Was and Was Not Achieved

### 6.1 Verified Claims

1. **API Contracts**: The type signatures for `KEMScheme`, `hybridKEM`, `IdealFunctionality`, `Protocol`, `Simulator`, and `UCSecure` are formally specified and type-checked.

2. **Structural Composition**: The hybrid combiner correctly combines two KEMs. The UC composition theorem has the correct shape.

3. **Theorem Shapes**: The "either-breaks" theorems have the expected logical structure (implications, disjunction elimination).

4. **No Incomplete Proofs**: Every proof term is closed; no `sorry` or `admit` is used.

### 6.2 Not Verified (Placeholder)

1. **Cryptographic Security**: The theorems are true because security predicates are trivially satisfied, not because of cryptographic arguments.

2. **Reduction Proofs**: We do not formalize the actual security reductions (e.g., "if hybrid is broken, then K1 or K2 is broken").

3. **Probability Theory**: No measure-theoretic foundations for probabilistic security definitions.

4. **Adversary Model**: No formalization of PPT adversaries, oracle access, or advantage bounds.

5. **Concrete Bounds**: No security parameter, no concrete advantage bounds.

### 6.3 Comparison with Complete Formalizations

| Aspect | EasyUC [6] | This Work |
|--------|------------|-----------|
| UC Definition | Full | Shape only |
| Simulator Construction | Verified | Not needed (trivial) |
| Game-Based Security | Supported | Placeholder |
| Composition Proof | Complete | Structural |
| Effort Required | High | Low |
| Cryptographic Soundness | Yes | No |

---

## 7. Applications and Impact

### 7.1 Immediate Applications

Despite the placeholder limitations, this formalization provides value for:

1. **Protocol Design**: Type-checking catches structural errors early. A developer can prototype hybrid constructions and verify type compatibility before investing in full proofs.

2. **Documentation**: The Lean code serves as executable specification, more precise than informal prose.

3. **Teaching**: The formalization demonstrates UC concepts in a modern proof assistant, suitable for graduate courses.

4. **Scaffolding**: Future work can replace placeholders with real definitions without restructuring.

### 7.2 Industry Relevance

The hybrid approach is increasingly mandated:

- **NIST SP 800-227** (draft): Guidance on hybrid ML-KEM constructions [8]
- **X-Wing (IETF)**: General-purpose hybrid KEM in standardization [4]
- **AWS/Cloudflare**: Deployed hybrid TLS with ML-KEM + X25519 [9]
- **European Regulations**: Hybrid recommended during transition period

A verified implementation guide, even at the interface level, aids correct deployment.

### 7.3 Research Directions Enabled

1. **Verified X-Wing**: Instantiate `K1 := X25519`, `K2 := ML-KEM-768` with concrete KDF
2. **QKD + PQC Bridge**: Connect UC-secure BB84 formalization to hybrid framework
3. **Lean Crypto Library**: Build reusable verified crypto primitives in Lean 4

---

## 8. Future Work: Roadmap to Complete Verification

### 8.1 Phase 1: Game-Based Security (IND-CCA)

**Goal**: Replace `IND_CCA : KEMScheme → Prop := True` with a game-based definition.

**Requirements**:
- Probabilistic monad for sampling
- Adversary type (function with oracle access)
- Advantage definition (|Pr[win] - 1/2|)
- Negligible function formalization

**Prior Art**: Lean crypto library development, FCF (Coq), EasyCrypt

**Tracked As**: `conjectures/kem_indcca_game.json`

### 8.2 Phase 2: UC Indistinguishability

**Goal**: Ground `UCSecure` in an explicit indistinguishability notion.

**Requirements**:
- Environment/distinguisher formalization
- Computational indistinguishability (poly-time, negligible advantage)
- Connection to game-based security

**Prior Art**: EasyUC [6], CryptoVerif

**Tracked As**: `conjectures/uc_game_bridge.json`

### 8.3 Phase 3: Concrete Reductions

**Goal**: Prove the actual security reduction for `hybrid_security_of_or`.

**Proof Sketch**:
1. Assume adversary A breaks hybrid with advantage ε
2. Construct adversary B1 that uses A to break K1
3. Construct adversary B2 that uses A to break K2
4. Show: ε ≤ Adv(B1) + Adv(B2)

**Challenge**: Requires probabilistic reasoning, oracle simulation

### 8.4 Phase 4: QKD Security

**Goal**: Formalize BB84 UC-security (or connect to existing formalization).

**Requirements**:
- Quantum information theory foundations
- Entanglement-based security argument (Shor-Preskill)
- Error rate bounds

**Prior Art**: QPL-based formalization [7], quantum Hoare logic

### 8.5 Phase 5: Concrete Instantiation

**Goal**: Verify X-Wing (X25519 + ML-KEM-768 + SHA3-256 KDF).

**Requirements**:
- Verified X25519 implementation
- Verified ML-KEM-768 implementation
- KDF security (random oracle model)
- Concrete security bounds

---

## 9. Related Work

### 9.1 Formal Verification in Cryptography

- **EasyCrypt**: Probabilistic relational Hoare logic for game-based proofs [10]
- **CryptoVerif**: Automated verification in the computational model [11]
- **FCF (Coq)**: Foundational Cryptography Framework [12]
- **Jasmin/Libjade**: Verified assembly implementations [13]
- **HACL*/F***: Verified cryptographic library [14]

### 9.2 UC Formalization

- **EasyUC**: First mechanized UC proofs in EasyCrypt [6]
- **Symbolic UC**: Translation from symbolic to computational UC [15]

### 9.3 QKD Verification

- **QPL-based proofs**: Shor-Preskill style in quantum programming language [7]
- **Quantum Hoare Logic**: Formal reasoning about quantum programs [16]

### 9.4 Lean 4 for Cryptography

- **Computationally-Sound Symbolic Crypto**: Recent Lean 4 formalization translating symbolic to computational proofs [17]
- **Mathlib**: Foundational mathematics, including algebra and number theory

---

## 10. Conclusion

We have presented a Lean 4 formalization of hybrid key establishment combining QKD and post-quantum KEMs. Our approach prioritizes *structural verification*—ensuring type correctness, composition patterns, and theorem shapes—over *cryptographic verification*—which would require substantial additional formalization of probability theory, adversary models, and game-based security.

**Honest Summary**:
- The formalization is *complete* in the sense of having no sorry/admit
- The formalization is *vacuous* in the sense that security predicates are `True`
- The value lies in verified scaffolding, not verified security

**Call to Action**: We invite the formal methods and cryptography communities to build on this scaffolding, replacing placeholders with real definitions to achieve complete verified hybrid cryptography.

---

## References

[1] NIST FIPS 203: Module-Lattice-Based Key-Encapsulation Mechanism Standard, August 2024. https://csrc.nist.gov/pubs/fips/203/final

[2] C. H. Bennett and G. Brassard, "Quantum cryptography: Public key distribution and coin tossing," Proceedings of IEEE International Conference on Computers, Systems and Signal Processing, 1984.

[3] P. Schwabe et al., "X-Wing: The Hybrid KEM You've Been Looking For," IACR ePrint 2024/039. https://eprint.iacr.org/2024/039

[4] D. Connolly, P. Schwabe, B.E. Westerbaan, "X-Wing: general-purpose hybrid post-quantum KEM," IETF Internet-Draft, September 2025. https://datatracker.ietf.org/doc/draft-connolly-cfrg-xwing-kem/

[5] R. Canetti, "Universally Composable Security: A New Paradigm for Cryptographic Protocols," FOCS 2001. https://eprint.iacr.org/2000/067

[6] R. Canetti, A. Stoughton, M. Varia, "EasyUC: Using EasyCrypt to Mechanize Proofs of Universally Composable Security," CSF 2019. https://eprint.iacr.org/2019/582

[7] "QKD security proofs for decoy-state BB84: protocol variations, proof techniques, gaps and limitations," arXiv:2502.10340, 2025.

[8] NIST SP 800-227 (draft): Recommendations for Key-Encapsulation Mechanisms. https://csrc.nist.gov

[9] "State of the post-quantum Internet in 2025," Cloudflare Blog. https://blog.cloudflare.com/pq-2025/

[10] G. Barthe et al., "EasyCrypt: A Tutorial," Foundations of Security Analysis and Design VII, 2013.

[11] B. Blanchet, "CryptoVerif: Computationally Sound Mechanized Prover for Cryptographic Protocols," Dagstuhl Seminar, 2007.

[12] A. Petcher and G. Morrisett, "The Foundational Cryptography Framework," POST 2015.

[13] J. B. Almeida et al., "Jasmin: High-Assurance and High-Speed Cryptography," CCS 2017.

[14] J. K. Zinzindohoué et al., "HACL*: A Verified Modern Cryptographic Library," CCS 2017.

[15] "Computationally-Sound Symbolic Cryptography in Lean," IACR ePrint 2025/1700. https://eprint.iacr.org/2025/1700

[16] M. Ying, "Floyd-Hoare Logic for Quantum Programs," TOPLAS 2011.

[17] A comprehensive survey of the Lean 4 theorem prover, arXiv:2501.18639, 2025.

---

## Appendix A: Repository Structure

```
Crypto_Hybrid_PaperPack/
├── README.md                    # Overview and quick start
├── TECHNICAL_REPORT_FULL.md     # This document
├── 01_Lean_Map.md               # Concept → Lean mapping
├── 02_Proof_Index.md            # Theorem locations
├── 03_Reproducibility.md        # Build commands
├── 04_Dependencies.md           # Version pins
├── 05_Technical_Report.md       # Summary
├── 06_Axiom_Audit.md            # Axiom/assumption audit
├── conjectures/                 # Open proof targets
│   ├── kem_indcca_game.json
│   └── uc_game_bridge.json
└── RESEARCHER_BUNDLE/
    ├── HeytingLean/             # Lean 4 source files
    ├── scripts/verify_hybrid.sh # One-command verification
    └── artifacts/visuals/       # UMAP visualizations
```

## Appendix B: Verification Commands

```bash
# One-command verification
cd RESEARCHER_BUNDLE && ./scripts/verify_hybrid.sh

# Manual verification
lake build --wfail
grep -rn --include="*.lean" -E '\bsorry\b|\badmit\b' HeytingLean/
```

## Appendix C: Conjecture Schema

```json
{
  "id": "kem_indcca_game",
  "status": "open",
  "goal": "Replace IND_CCA placeholder with game-based definition",
  "requirements": [
    "Probabilistic monad",
    "Adversary type with oracle access",
    "Advantage definition",
    "Negligible function formalization"
  ],
  "references": ["EasyCrypt", "FCF", "CryptoVerif"]
}
```

---

*This work is part of the HeytingLean formal verification project: https://apoth3osis.io*

*Repository: https://github.com/Abraxas1010/hybrid-crypto-qkd-pqkem-lean*
