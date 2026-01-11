import HeytingLean.Crypto.Hybrid.QKDPQHybrid

namespace HeytingLean.Tests.Crypto

open HeytingLean
open HeytingLean.Crypto

namespace HybridSanity

open Crypto.Composable

def keProtocol (n : Nat) : Composable.Protocol (Composable.Instances.IdealKeyExchange n) where
  State := Unit
  Message := Unit
  init := ()
  execute := fun _i _s => (fun _ => false, (), ())

def keSim (n : Nat) : Composable.Simulator (Composable.Instances.IdealKeyExchange n) (keProtocol n) where
  SimState := Unit
  init := ()
  simulate := fun _leak _s => ((), ())

theorem ke_uc_secure (n : Nat) :
    Composable.UCSecure (Composable.Instances.IdealKeyExchange n) (keProtocol n) := by
  refine ⟨keSim n, (fun f g => f = g), ?_⟩
  rfl

def toyKEM : Crypto.KEM.KEMScheme where
  PublicKey := Unit
  SecretKey := Unit
  Ciphertext := Unit
  SharedSecret := Bool
  keygen := fun () => ((), ())
  encaps := fun _ => ((), false)
  decaps := fun _ _ => some false

example :
    Crypto.Hybrid.HybridSecure (πqkd := keProtocol 8) toyKEM := by
  left
  exact ke_uc_secure 8

end HybridSanity

end HeytingLean.Tests.Crypto
