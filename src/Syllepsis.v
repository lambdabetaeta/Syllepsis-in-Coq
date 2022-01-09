From HoTT Require Import Basics Types.

(* Monoidal isomorphisms *)

Local Definition ulnat {X} {a b : X} {p q : a = b} (alpha : p = q) :
  whiskerL 1 alpha @ concat_1p q = concat_1p p @ alpha.
Proof.
  destruct p. destruct alpha. exact 1.
Defined. 

Local Definition urnat {X} {a b : X} {p q : a = b} (alpha : p = q) :
  whiskerR alpha 1 @ concat_p1 q = concat_p1 p @ alpha.
Proof.
  destruct p. destruct alpha. exact 1.
Defined. 

Local Definition rightSqueeze {X} {a b : X} {p q : a = b}
  : (p @ 1 = 1 @ q) <~> (p = q).
Proof.
  refine (equiv_compose' _ _).
  - exact (equiv_concat_r (concat_1p _) _).
  - exact (equiv_concat_l (concat_p1 _)^ _).
Defined.

Local Definition downSqueeze {X} {a b : X} {p q : a = b}
  : (1 @ p = q @ 1) <~> (p = q) .
Proof.
  refine (equiv_compose' _ _).
  - exact (equiv_concat_r (concat_p1 _) _).
  - exact (equiv_concat_l (concat_1p _)^ _).
Defined.

Local Definition wlrnat {X} {a b c : X} {p q : a = b} {r s : b = c} alpha beta
  : whiskerL p beta @ whiskerR alpha s = whiskerR alpha r @ whiskerL q beta.
Proof.
  destruct alpha. destruct beta. exact 1.
Defined.

(* Eckmann-Hilton *)

Definition EH {X} {a : X} (p q : idpath a = idpath a) :
  p @ q = q @ p.
Proof.
  refine (((rightSqueeze (ulnat p) @@ rightSqueeze (urnat q))^) @ _).
  refine (wlrnat q p @ _).
  refine (rightSqueeze (urnat q) @@ rightSqueeze (ulnat p)).
Defined.

(* EH on reflexivity *)

Local Definition EH_refl_L_coh {X} {a b c : X} {p q : a = b} {r : b = c} {alpha : p = q}
  {s : p @ r = q @ r} (theta : whiskerR alpha r = s)
  : (1 @@ theta)^ @ (wlrnat alpha (idpath r) @ (theta @@ 1))
      = concat_1p s @ (concat_p1 s)^.
Proof.
  destruct theta. destruct alpha. exact 1.
Defined.

Local Definition EH_refl_L {X} {a : X} (p : idpath a = idpath a) :
  EH idpath p = concat_1p p @ (concat_p1 p)^.
Proof.
  unfold EH. 
  srapply (EH_refl_L_coh (p:=1) (q:=1) (r:=1) (rightSqueeze (urnat p))).
Defined.

Local Definition EH_refl_R_coh {X} {a b c : X} {p : a = b} {q r : b = c} {alpha : q = r}
  {s : p @ q = p @ r} (theta : whiskerL p alpha = s)
  : (theta @@ 1)^ @ (wlrnat (idpath p) alpha @ (1 @@ theta))
      = concat_p1 s @ (concat_1p s)^.
Proof.
  destruct theta. destruct alpha. exact 1.
Defined.

Local Definition EH_refl_R {X} {a : X} (p : idpath a = idpath a) :
  EH p idpath = concat_p1 p @ (concat_1p p)^.
Proof.
  unfold EH.
  srapply (EH_refl_R_coh (p:=1) (q:=1) (r:=1) (rightSqueeze (ulnat p))).
Defined.

(* Naturality of Eckmann - Hilton *)

Local Definition EH_natL {X} {a : X} {x u v : idpath a = idpath a} p :
  whiskerL x p @ EH x v = EH x u @ whiskerR p x.
Proof.
  induction p. unfold whiskerL. simpl.
  srapply (downSqueeze^-1 idpath).
Defined.

Local Definition EH_natR {X} {a : X} {x u v : idpath a = idpath a} p :
  whiskerR p x @ EH v x = EH u x @ whiskerL x p.
Proof.
  induction p. unfold whiskerR. simpl.
  srapply (downSqueeze^-1 idpath).
Defined.

(* REWORKED ENDS HERE *)

Section TwoSquares.

  Context {X} {a0 a1 b0 b1 c0 c1 : X}
   {a01 : a0 = a1} {b01 : b0 = b1} {c01 : c0 = c1}
   {ab0 : a0 = b0} {bc0 : b0 = c0}
   {ab1 : a1 = b1} {bc1 : b1 = c1}
   (phi : ab0 @ b01 = a01 @ ab1)
   (theta : bc0 @ c01 = b01 @ bc1).

  Local Definition twoSquares :
    (ab0 @ bc0) @ c01 = a01 @ (ab1 @ bc1).
  Proof.
    refine (concat_pp_p _ _ _ @ _).
    refine (whiskerL ab0 theta @ _).
    refine (concat_p_pp _ _ _ @ _).
    refine (whiskerR phi bc1 @ _).
    srapply concat_pp_p.
  Defined.

End TwoSquares.

Section SquareInv.

  Context {X} {a0 a1 b0 b1 : X}.
  Context {a01 : a0 = a1} {b01 : b0 = b1}.
  Context {ab0 : a0 = b0} {ab1 : a1 = b1}.
  Context (phi : ab0 @ b01 = a01 @ ab1).

  Local Definition squareInv :
    ab1 @ b01^ = a01^ @ ab0.
  Proof.
    induction a01; induction b01. simpl. 
    revert phi; srapply (equiv_ind rightSqueeze^-1); intro phi.
    induction phi.
    srapply (rightSqueeze^-1 idpath).
  Defined.

End SquareInv.

Local Definition EH_natL_twoSquares' {X} {a : X} {u} (p : idpath (idpath a) = u) :
  EH_natL p = (whiskerL (whiskerL 1 p) (EH_refl_L u)) @
              (twoSquares (ulnat p)^ (squareInv (urnat p))^)^.
Proof.
  induction p.
  reflexivity.
Defined.

Local Definition EH_natR_twoSquares' {X} {a : X} {u} (p : idpath (idpath a) = u) :
  EH_natR p = (whiskerL (whiskerR p 1) (EH_refl_R u)) @
              (twoSquares (urnat p)^ (squareInv (ulnat p))^)^.
Proof.
  induction p.
  reflexivity.
Defined.

Definition EH_natL_twoSquares {X} {a : X} (p : idpath (idpath a) = idpath (idpath a)) :
  EH_natL p = (twoSquares (ulnat p)^ (squareInv (urnat p))^)^.
Proof.
  refine (EH_natL_twoSquares' _ @ _).
  exact (concat_1p _).
Defined.

Definition EH_natR_twoSquares {X} {a : X} (p : idpath (idpath a) = idpath (idpath a)) :
  EH_natR p = (twoSquares (urnat p)^ (squareInv (ulnat p))^)^.
Proof.
  refine (EH_natR_twoSquares' _ @ _).
  exact (concat_1p _).
Defined.

Local Definition DL {X} {a : X} {x y u v : idpath a = idpath a} p q :
  (whiskerL u p @ whiskerR q y) @ EH v y = EH u x @ (whiskerR p u @ whiskerL y q) :=
  twoSquares (EH_natL p) (EH_natR q).

Local Definition DR {X} {a : X} {x y u v : idpath a = idpath a} p q :
  (whiskerR q x @ whiskerL v p) @ EH v y = EH u x @ (whiskerL x q @ whiskerR p v) :=
  twoSquares (EH_natR q) (EH_natL p).

Local Definition S {X} {a : X} {x y u v : idpath a = idpath a} p q :
  DL p q @ whiskerL (EH u x) (wlrnat p q)^ = whiskerR (wlrnat q p) (EH v y) @ DR p q.
Proof.
  induction p; induction q.
  srapply (rightSqueeze^-1 idpath).
Defined.

Local Definition EL {X} {a : X} (p q : idpath (idpath a) = idpath (idpath a)) :
  (whiskerL 1 p @ whiskerR q 1) @ 1 = 1 @ (whiskerR p 1 @ whiskerL 1 q).
Proof.
  srapply rightSqueeze^-1.
  refine ((rightSqueeze (ulnat p) @@ rightSqueeze (urnat q)) @ _).
  refine ((rightSqueeze (urnat p) @@ rightSqueeze (ulnat q))^).
Defined.

Local Definition ER {X} {a : X} (p q : idpath (idpath a) = idpath (idpath a)) :
  (whiskerR q 1 @ whiskerL 1 p) @ 1 = 1 @ (whiskerL 1 q @ whiskerR p 1).
Proof.
  srapply rightSqueeze^-1.
  refine ((rightSqueeze (urnat q) @@ rightSqueeze (ulnat p)) @ _).
  refine ((rightSqueeze (ulnat q) @@ rightSqueeze (urnat p))^).
Defined.

Local Definition F {X} {a b c : X} {p0 p1 p2 : a = b} {q0 q1 q2 : b = c}
  {p01 : p0 @ 1 = 1 @ p1} {p12 : p2 @ 1 = 1 @ p1} {p02 : p0 @ 1 = 1 @ p2}
  {q01 : q0 @ 1 = 1 @ q1} {q12 : q2 @ 1 = 1 @ q1} {q02 : q0 @ 1 = 1 @ q2} :
  (twoSquares p01^ (squareInv p12)^)^ = p02 ->
  (twoSquares q01^ (squareInv q12)^)^ = q02 ->
  twoSquares p02 q02 = rightSqueeze^-1 ((rightSqueeze p01 @@ rightSqueeze q01) @ (rightSqueeze p12 @@ rightSqueeze q12)^).
Proof.
  intros phi theta.
  induction phi; induction theta.
  revert p01; srapply (equiv_ind rightSqueeze^-1); intro p01.
  revert q01; srapply (equiv_ind rightSqueeze^-1); intro q01.
  revert p12; srapply (equiv_ind rightSqueeze^-1); intro p12.
  revert q12; srapply (equiv_ind rightSqueeze^-1); intro q12.
  induction p12; induction q12; induction p01; induction q01.
  induction p0; induction q0.
  reflexivity.
Defined.

Local Definition DL_eq_EL {X} {a : X} (p q : idpath (idpath a) = idpath (idpath a)) :
  DL p q = EL p q.
Proof.
  srapply F.
  all: symmetry.
  - exact (EH_natL_twoSquares p).
  - exact (EH_natR_twoSquares q).
Defined.

Local Definition DR_eq_ER {X} {a : X} (p q : idpath (idpath a) = idpath (idpath a)) :
  DR p q = ER p q.
Proof.
  srapply F.
  all: symmetry.
  - exact (EH_natR_twoSquares q).
  - exact (EH_natL_twoSquares p).
Defined.

Local Definition T {X} {a : X} (p q : idpath (idpath a) = idpath (idpath a)) :
  EL p q @ whiskerL 1 (wlrnat p q)^ = whiskerR (wlrnat q p) 1 @ ER p q.
Proof.
  refine (whiskerR (DL_eq_EL p q)^ _ @ _).
  refine (_ @ whiskerL _ (DR_eq_ER p q)).
  exact (S p q).
Defined.

Local Definition H {X} {a b : X} {a0 a1 a2 a3 a4 a5 : a = b}
  {a10 : a1 = a0} {a12 : a1 = a2} {a23 : a2 = a3}
  {a43 : a4 = a3} {a45 : a4 = a5} {a50 : a5 = a0} :
  rightSqueeze^-1 (a10 @ a50^) @ whiskerL 1 a45^ = whiskerR a12 1 @ rightSqueeze^-1 (a23 @ a43^) ->
  a10^ @ (a12 @ a23) = (a43^ @ (a45 @ a50))^.
Proof.
  induction a45; induction a43; induction a23; induction a12; induction a50; induction a1.
  cbn; hott_simpl.
  srapply ap.
Defined.

Definition syllepsis {X} {a : X} (p q : idpath (idpath a) = idpath _)
  : EH p q = (EH q p)^.
Proof.
  snrapply H.
  snrapply T.
Defined.