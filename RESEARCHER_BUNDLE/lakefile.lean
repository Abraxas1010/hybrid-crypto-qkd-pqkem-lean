import Lake
open Lake DSL

package «crypto-hybrid» where
  leanOptions := #[
    ⟨`autoImplicit, false⟩,
    ⟨`relaxedAutoImplicit, false⟩
  ]

require «mathlib» from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.24.0"

@[default_target]
lean_lib HeytingLean where
  globs := #[.submodules `HeytingLean]
