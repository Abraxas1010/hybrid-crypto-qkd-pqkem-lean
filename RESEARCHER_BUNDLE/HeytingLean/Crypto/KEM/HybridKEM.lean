/-!
# Hybrid KEM composition (X-Wing style, spec-level)

This module provides:
- a small abstract KEM interface (`KEMScheme`);
- a product/parallel combiner (`hybridKEM`);
- a generic "either assumption implies security" lemma for the hybrid.

We intentionally do **not** introduce new axioms here. Concrete cryptographic assumptions and
reductions are tracked separately (conjecture/session workflow) and, when approved, isolated in
dedicated axiom modules.

Reference motivation:
- ePrint 2024/039 ("X-Wing: The Hybrid KEM You've Been Looking For")
- IETF draft "tls-ecdhe-mlkem" (hybrid ECDHE + ML-KEM)
-/

namespace HeytingLean
namespace Crypto
namespace KEM

/-- Abstract KEM interface (shape only). -/
structure KEMScheme where
  PublicKey : Type
  SecretKey : Type
  Ciphertext : Type
  SharedSecret : Type
  keygen : Unit → PublicKey × SecretKey
  encaps : PublicKey → Ciphertext × SharedSecret
  decaps : SecretKey → Ciphertext → Option SharedSecret

/-!
PLACEHOLDER: IND-CCA security predicate

This is an interface stub. Replace with a game-based definition wired to the
`HeytingLean.Crypto.Games.INDCCA` framework (or a refined UC/game bridge) via the
conjecture workflow. See `conjectures/kem_indcca_game.json`.
-/
def IND_CCA (_K : KEMScheme) : Prop := True

/-- Hybrid combiner: run both KEMs and pair ciphertexts/secrets. -/
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

theorem hybrid_security_of_left (K1 K2 : KEMScheme) :
    IND_CCA K1 → IND_CCA (hybridKEM K1 K2) := by
  intro _h
  trivial

theorem hybrid_security_of_right (K1 K2 : KEMScheme) :
    IND_CCA K2 → IND_CCA (hybridKEM K1 K2) := by
  intro _h
  trivial

theorem hybrid_security_of_or (K1 K2 : KEMScheme) :
    (IND_CCA K1 ∨ IND_CCA K2) → IND_CCA (hybridKEM K1 K2) := by
  intro h
  cases h with
  | inl h1 => exact hybrid_security_of_left K1 K2 h1
  | inr h2 => exact hybrid_security_of_right K1 K2 h2

/-
Phase 11 (Hybrid Protocols) additionally uses a hybrid of *key sources* (e.g. QKD + PQ KEM).
We keep this interface-first, parallel to `KEMScheme`, so later work can connect it to UC
executions and concrete KEM game definitions.
-/

/-- Abstract source of key material (shape only). -/
structure KeySource where
  Key : Type
  gen : Unit → Key

/-!
PLACEHOLDER: key-source security predicate

This is an interface stub to model "secure key source". Replace with a concrete
predicate derived from a game/UC formalization in future phases.
-/
def KeySecure (_S : KeySource) : Prop := True

/-- Hybrid key source: generate both keys and pair them. -/
def hybridKeySource (S1 S2 : KeySource) : KeySource where
  Key := S1.Key × S2.Key
  gen := fun () => (S1.gen (), S2.gen ())

theorem hybridKey_security_of_left (S1 S2 : KeySource) :
    KeySecure S1 → KeySecure (hybridKeySource S1 S2) := by
  intro _h
  trivial

theorem hybridKey_security_of_right (S1 S2 : KeySource) :
    KeySecure S2 → KeySecure (hybridKeySource S1 S2) := by
  intro _h
  trivial

theorem hybridKey_security_of_or (S1 S2 : KeySource) :
    (KeySecure S1 ∨ KeySecure S2) → KeySecure (hybridKeySource S1 S2) := by
  intro h
  cases h with
  | inl h1 => exact hybridKey_security_of_left S1 S2 h1
  | inr h2 => exact hybridKey_security_of_right S1 S2 h2

end KEM
end Crypto
end HeytingLean
