module StateAuto where

open import Function
open import Relation.Binary.PropositionalEquality as PropEq
-- open import Relation.Binary.HeterogeneousEquality as HetEq
open import Data.Product as P
open import Data.Sum as S

data StateAuto (A B : Set) : Set₁ where
  Lift : (A -> B) -> StateAuto A B
  State : {S : Set} -> S -> (A -> S -> (B × S)) -> StateAuto A B

idSA : ∀ {A} -> StateAuto A A
idSA = Lift id

dotSA : ∀ {A B C} -> StateAuto A B -> StateAuto B C -> StateAuto A C
dotSA (Lift f) (Lift g) = Lift (g ∘ f)
dotSA (Lift f) (State gi gt) = State gi (λ x → gt (f x))
dotSA (State fi ft) (Lift g) = State fi (λ x s → let y = ft x s
                                                   in ( (g (proj₁ y)) , proj₂ y))
dotSA (State fi ft) (State gi gt) = State (fi , gi) (λ x s → let y = ft x (proj₁ s)
                                                               in let z = gt (proj₁ y) (proj₂ s)
                                                                    in proj₁ z , (proj₂ y , proj₂ z))

leftID : ∀ {A B} (f : StateAuto A B) -> dotSA idSA f ≡ f
leftID (Lift x) = refl
leftID (State x x₁) = refl

rightID : ∀ {A B} (f : StateAuto A B) -> dotSA f idSA ≡ f
rightID (Lift x) = refl
rightID (State x x₁) = refl

assoc : ∀ {A B C D} (f : StateAuto A B) (g : StateAuto B C) (h : StateAuto C D) ->
        dotSA f (dotSA g h) ≡ dotSA (dotSA f g) h
assoc (Lift x) (Lift x₁) (Lift x₂) = refl
assoc (Lift x) (Lift x₁) (State x₂ x₃) = refl
assoc (Lift x) (State x₁ x₂) (Lift x₃) = refl
assoc (Lift x) (State x₁ x₂) (State x₃ x₄) = refl
assoc (State x x₁) (Lift x₂) (Lift x₃) = refl
assoc (State x x₁) (Lift x₂) (State x₃ x₄) = refl
assoc (State x x₁) (State x₂ x₃) (Lift x₄) = refl
assoc (State x x₁) (State x₂ x₃) (State x₄ x₅) = {!!}

arr : ∀ {A B} -> (A -> B) -> StateAuto A B
arr = Lift

first : ∀ {A B C} -> StateAuto A B -> StateAuto (A × C) (B × C)
first (Lift x) = Lift (P.map x id)
first (State x x₁) = State x (λ y s → let z = x₁ (proj₁ y) s
                                        in (proj₁ z , proj₂ y) , proj₂ z)

arrPrsID : ∀ {A} -> arr id ≡ idSA {A}
arrPrsID = refl

arrPrsComp : ∀ {A B C} (f : A -> B) (g : B -> C) ->
              arr (g ∘ f) ≡ dotSA (arr f) (arr g)
arrPrsComp f g = refl

firstPrsArr : ∀ {A B C} (f : A -> B) -> first {A} {B} {C} (arr f) ≡ arr (P.map f id)
firstPrsArr f = refl

firstProjSwp : ∀ {A B C} (f : StateAuto A B) ->
               dotSA (first {A} {B} {C} f) (arr proj₁) ≡ dotSA (arr proj₁) f
firstProjSwp (Lift x) = refl
firstProjSwp (State x x₁) = refl

firstIndependence : ∀ {A B C D} (f : StateAuto A C) (g : B -> D) ->
                    dotSA (first f) (arr (P.map id g)) ≡ dotSA (arr (P.map id g)) (first f)
firstIndependence (Lift x) g = refl
firstIndependence (State x x₁) g = refl

reassociate : ∀ {A B C} -> ((A × B) × C) -> (A × (B × C))
reassociate ((a , b) , c) = (a , (b , c))

innerFirst : ∀ {A B C D} (f : StateAuto A B) ->
             dotSA (first {A × C} {B × C} {D} (first {A} {B} {C} f)) (arr reassociate) ≡
             dotSA (arr reassociate) (first f)
innerFirst (Lift x) = refl
innerFirst (State x x₁) = refl
