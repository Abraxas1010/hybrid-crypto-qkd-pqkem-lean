import HeytingLean.Crypto.Composable
import HeytingLean.Crypto.KEM.HybridKEM

/-!
# Hybrid protocols: QKD + PQC (spec-level)

Phase 11: interface-first specification for hybrid key establishment that combines:
- an information-theoretic QKD key (modeled via UC `IdealKeyExchange`), and
- a computational PQ KEM shared secret (modeled via an abstract `KEMScheme`).

This file is intentionally lightweight: it provides stable names and a "either breaks" style
security statement shell without asserting concrete cryptographic reductions.
-/

namespace HeytingLean
namespace Crypto
namespace Hybrid

open HeytingLean.Crypto.Composable
open HeytingLean.Crypto.KEM

/-- Hybrid key material: a QKD key together with a PQ shared secret (plus ciphertext). -/
structure HybridKEM (n : Nat) (K : KEMScheme) where
  qkd_key : Fin n → Bool
  pq_ciphertext : K.Ciphertext
  pq_sharedSecret : K.SharedSecret

/-- Combined key material (interface-first). -/
def HybridKEM.combined {n : Nat} {K : KEMScheme} (H : HybridKEM n K) :
    (Fin n → Bool) × K.SharedSecret :=
  (H.qkd_key, H.pq_sharedSecret)

/-- A placeholder UC-style security predicate for the PQ component (to be refined later). -/
def PQSecure (K : KEMScheme) : Prop :=
  IND_CCA K

/-- "Either breaks" hybrid security: if either component is secure, treat the hybrid as secure. -/
def HybridSecure {n : Nat} (πqkd : Protocol (Composable.Instances.IdealKeyExchange n))
    (K : KEMScheme) : Prop :=
  UCSecure (Composable.Instances.IdealKeyExchange n) πqkd ∨ PQSecure K

theorem hybrid_security {n : Nat} (πqkd : Protocol (Composable.Instances.IdealKeyExchange n))
    (K : KEMScheme) :
    (UCSecure (Composable.Instances.IdealKeyExchange n) πqkd ∨ PQSecure K) →
      HybridSecure (πqkd := πqkd) K := by
  intro h
  exact h

end Hybrid
end Crypto
end HeytingLean
