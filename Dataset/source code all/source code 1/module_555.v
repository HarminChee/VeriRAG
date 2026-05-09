(** * Basics: Functional Programming in Coq *)
(*
   [Admitted] is Coq's ""escape hatch"" that says accept this definition
   without proof.  We use it to mark the 'holes' in the development
   that should be completed as part of your homework exercises.  In
   practice, [Admitted] is useful when you're incrementally developing
   large proofs. *)
Definition admit {T: Type} : T.  Admitted.
(* ###################################################################### *)
(** * Introduction *)
(** The functional programming style brings programming closer to
    simple, everyday mathematics: If a procedure or method has no side
    effects, then pretty much all you need to understand about it is
    how it maps inputs to outputs -- that is, you can think of it as
    just a concrete method for computing a mathematical function.
    This is one sense of the word ""functional"" in ""functional
    programming.""  The direct connection between programs and simple
    mathematical objects supports both formal proofs of correctness
    and sound informal reasoning about program behavior.
    The other sense in which functional programming is ""functional"" is
    that it emphasizes the use of functions (or methods) as
    _first-class_ values -- i.e., values that can be passed as
    arguments to other functions, returned as results, stored in data
    structures, etc.  The recognition that functions can be treated as
    data in this way enables a host of useful and powerful idioms.
    Other common features of functional languages include _algebraic
    data types_ and _pattern matching_, which make it easy to construct
    and manipulate rich data structures, and sophisticated
    _polymorphic type systems_ that support abstraction and code
    reuse.  Coq shares all of these features.
    The first half of this chapter introduces the most essential
    elements of Coq's functional programming language.  The second
    half introduces some basic _tactics_ that can be used to prove
    simple properties of Coq programs.
*)
(* ###################################################################### *)
(** * Enumerated Types *)
(** One unusual aspect of Coq is that its set of built-in
    features is _extremely_ small.  For example, instead of providing
    the usual palette of atomic data types (booleans, integers,
    strings, etc.), Coq offers an extremely powerful mechanism for
    defining new data types from scratch -- so powerful that all these
    familiar types arise as instances.  
    Naturally, the Coq distribution comes with an extensive standard
    library providing definitions of booleans, numbers, and many
    common data structures like lists and hash tables.  But there is
    nothing magic or primitive about these library definitions: they
    are ordinary user code.  To illustrate this, we will explicitly
    recapitulate all the definitions we need in this course, rather
    than just getting them implicitly from the library.
    To see how this mechanism works, let's start with a very simple
    example. *)
(* ###################################################################### *)
(** ** Days of the Week *)
(** The following declaration tells Coq that we are defining
    a new set of data values -- a _type_. *)
Inductive day : Type :=
  | monday : day
  | tuesday : day
  | wednesday : day
  | thursday : day
  | friday : day
  | saturday : day
  | sunday : day.
(** The type is called [day], and its members are [monday],
    [tuesday], etc.  The second and following lines of the definition
    can be read ""[monday] is a [day], [tuesday] is a [day], etc.""
    Having defined [day], we can write functions that operate on
    days. *)
Definition next_weekday (d:day) : day :=
  match d with
  | monday    => tuesday
  | tuesday   => wednesday
  | wednesday => thursday
  | thursday  => friday
  | friday    => monday
  | saturday  => monday
  | sunday    => monday
  end.
(** One thing to note is that the argument and return types of
    this function are explicitly declared.  Like most functional
    programming languages, Coq can often figure out these types for
    itself when they are not given explicitly -- i.e., it performs
    some _type inference_ -- but we'll always include them to make
    reading easier. *)
(** Having defined a function, we should check that it works on
    some examples.  There are actually three different ways to do this
    in Coq.  
    First, we can use the command [Eval compute] to evaluate a
    compound expression involving [next_weekday].  *)
Eval compute in (next_weekday friday).
   (* ==> monday : day *)
Eval compute in (next_weekday (next_weekday saturday)).
   (* ==> tuesday : day *)
(** If you have a computer handy, this would be an excellent
    moment to fire up the Coq interpreter under your favorite IDE --
    either CoqIde or Proof General -- and try this for yourself.  Load
    this file ([Basics.v]) from the book's accompanying Coq sources,
    find the above example, submit it to Coq, and observe the
    result. *)
(** The keyword [compute] tells Coq precisely how to
    evaluate the expression we give it.  For the moment, [compute] is
    the only one we'll need; later on we'll see some alternatives that
    are sometimes useful. *)
(** Second, we can record what we _expect_ the result to be in
    the form of a Coq example: *)
Example test_next_weekday:
  (next_weekday (next_weekday saturday)) = tuesday.
(** This declaration does two things: it makes an
    assertion (that the second weekday after [saturday] is [tuesday]),
    and it gives the assertion a name that can be used to refer to it
    later. *)
(** Having made the assertion, we can also ask Coq to verify it,
    like this: *)
Proof. simpl. reflexivity.  Qed.
(** The details are not important for now (we'll come back to
    them in a bit), but essentially this can be read as ""The assertion
    we've just made can be proved by observing that both sides of the
    equality evaluate to the same thing, after some simplification."" *)
(** Third, we can ask Coq to _extract_, from our [Definition], a
    program in some other, more conventional, programming
    language (OCaml, Scheme, or Haskell) with a high-performance
    compiler.  This facility is very interesting, since it gives us a
    way to construct _fully certified_ programs in mainstream
    languages.  Indeed, this is one of the main uses for which Coq was
    developed.  We'll come back to this topic in later chapters.  More
    information can also be found in the Coq'Art book by Bertot and
    Casteran, as well as the Coq reference manual. *)
(* ###################################################################### *)
(** ** Booleans *)
(** In a similar way, we can define the standard type [bool] of
    booleans, with members [true] and [false]. *)
Inductive bool : Type :=
  | true : bool
  | false : bool.
(** Although we are rolling our own booleans here for the sake
    of building up everything from scratch, Coq does, of course,
    provide a default implementation of the booleans in its standard
    library, together with a multitude of useful functions and
    lemmas.  (Take a look at [Coq.Init.Datatypes] in the Coq library
    documentation if you're interested.)  Whenever possible, we'll
    name our own definitions and theorems so that they exactly
    coincide with the ones in the standard library. *)
(** Functions over booleans can be defined in the same way as
    above: *)
Definition negb (b:bool) : bool := 
  match b with
  | true => false
  | false => true
  end.
Definition andb (b1:bool) (b2:bool) : bool := 
  match b1 with 
  | true => b2 
  | false => false
  end.
Definition orb (b1:bool) (b2:bool) : bool := 
  match b1 with 
  | true => true
  | false => b2
  end.
(** The last two illustrate the syntax for multi-argument
    function definitions. *)
(** The following four ""unit tests"" constitute a complete
    specification -- a truth table -- for the [orb] function: *)
Example test_orb1:  (orb true  false) = true. 
Proof. reflexivity.  Qed.
Example test_orb2:  (orb false false) = false.
Proof. reflexivity.  Qed.
Example test_orb3:  (orb false true)  = true.
Proof. reflexivity.  Qed.
Example test_orb4:  (orb true  true)  = true.
Proof. reflexivity.  Qed.
(** (Note that we've dropped the [simpl] in the proofs.  It's not
    actually needed because [reflexivity] automatically performs
    simplification.) *)
(** _A note on notation_: In .v files, we use square brackets to
    delimit fragments of Coq code within comments; this convention,
    also used by the [coqdoc] documentation tool, keeps them visually
    separate from the surrounding text.  In the html version of the
    files, these pieces of text appear in a [different font]. *)
(** The values [Admitted] and [admit] can be used to fill
    a hole in an incomplete definition or proof.  We'll use them in the
    following exercises.  In general, your job in the exercises is 
    to replace [admit] or [Admitted] with real definitions or proofs. *)
(** **** Exercise: 1 star (nandb)  *)
(** Complete the definition of the following function, then make
    sure that the [Example] assertions below can each be verified by
    Coq.  *)
(** This function should return [true] if either or both of
    its inputs are [false]. *)
Definition nandb (b1:bool) (b2:bool) : bool :=
  negb (andb b1 b2).
(** Remove ""[Admitted.]"" and fill in each proof with 
    ""[Proof. reflexivity. Qed.]"" *)
Example test_nandb1:               (nandb true false) = true.
Proof. reflexivity. Qed.
Example test_nandb2:               (nandb false false) = true.
Proof. reflexivity. Qed.
Example test_nandb3:               (nandb false true) = true.
Proof. reflexivity. Qed.
Example test_nandb4:               (nandb true true) = false.
Proof. reflexivity. Qed.
(** [] *)
(** **** Exercise: 1 star (andb3)  *)
(** Do the same for the [andb3] function below. This function should
    return [true] when all of its inputs are [true], and [false]
    otherwise. *)
Definition andb3 (b1:bool) (b2:bool) (b3:bool) : bool :=
  andb (andb b1 b2) b3.
Example test_andb31:                 (andb3 true true true) = true.
Proof. reflexivity. Qed.
Example test_andb32:                 (andb3 false true true) = false.
Proof. reflexivity. Qed.
Example test_andb33:                 (andb3 true false true) = false.
Proof. reflexivity. Qed.
Example test_andb34:                 (andb3 true true false) = false.
Proof. reflexivity. Qed.
(** [] *)
(* ###################################################################### *)
(** ** Function Types *)
(** The [Check] command causes Coq to print the type of an
    expression.  For example, the type of [negb true] is [bool]. *)
Check true.
(* ===> true : bool *)
Check (negb true).
(* ===> negb true : bool *)
(** Functions like [negb] itself are also data values, just like
    [true] and [false].  Their types are called _function types_, and
    they are written with arrows. *)
Check negb.
(* ===> negb : bool -> bool *)
(** The type of [negb], written [bool -> bool] and pronounced
    ""[bool] arrow [bool],"" can be read, ""Given an input of type
    [bool], this function produces an output of type [bool].""
    Similarly, the type of [andb], written [bool -> bool -> bool], can
    be read, ""Given two inputs, both of type [bool], this function
    produces an output of type [bool]."" *)
(* ###################################################################### *)
(** ** Numbers *)
(** _Technical digression_: Coq provides a fairly sophisticated
    _module system_, to aid in organizing large developments.  In this
    course we won't need most of its features, but one is useful: If
    we enclose a collection of declarations between [Module X] and
    [End X] markers, then, in the remainder of the file after the
    [End], these definitions will be referred to by names like [X.foo]
    instead of just [foo].  Here, we use this feature to introduce the
    definition of the type [nat] in an inner module so that it does
    not shadow the one from the standard library. *)
Module Playground1.
(** The types we have defined so far are examples of ""enumerated
    types"": their definitions explicitly enumerate a finite set of
    elements.  A more interesting way of defining a type is to give a
    collection of ""inductive rules"" describing its elements.  For
    example, we can define the natural numbers as follows: *)
Inductive nat : Type :=
  | O : nat
  | S : nat -> nat.
(** The clauses of this definition can be read: 
      - [O] is a natural number (note that this is the letter ""[O],"" not
        the numeral ""[0]"").
      - [S] is a ""constructor"" that takes a natural number and yields
        another one -- that is, if [n] is a natural number, then [S n]
        is too.
    Let's look at this in a little more detail.  
    Every inductively defined set ([day], [nat], [bool], etc.) is
    actually a set of _expressions_.  The definition of [nat] says how
    expressions in the set [nat] can be constructed:
    - the expression [O] belongs to the set [nat]; 
    - if [n] is an expression belonging to the set [nat], then [S n]
      is also an expression belonging to the set [nat]; and
    - expressions formed in these two ways are the only ones belonging
      to the set [nat].
    The same rules apply for our definitions of [day] and [bool]. The
    annotations we used for their constructors are analogous to the
    one for the [O] constructor, and indicate that each of those
    constructors doesn't take any arguments. *)
(** These three conditions are the precise force of the
    [Inductive] declaration.  They imply that the expression [O], the
    expression [S O], the expression [S (S O)], the expression
    [S (S (S O))], and so on all belong to the set [nat], while other
    expressions like [true], [andb true false], and [S (S false)] do
    not.
    We can write simple functions that pattern match on natural
    numbers just as we did above -- for example, the predecessor
    function: *)
Definition pred (n : nat) : nat :=
  match n with
    | O => O
    | S n' => n'
  end.
(** The second branch can be read: ""if [n] has the form [S n']
    for some [n'], then return [n'].""  *)
End Playground1.
Definition minustwo (n : nat) : nat :=
  match n with
    | O => O
    | S O => O
    | S (S n') => n'
  end.
(** Because natural numbers are such a pervasive form of data,
    Coq provides a tiny bit of built-in magic for parsing and printing
    them: ordinary arabic numerals can be used as an alternative to
    the ""unary"" notation defined by the constructors [S] and [O].  Coq
    prints numbers in arabic form by default: *)
Check (S (S (S (S O)))).
Eval compute in (minustwo 4).
(** The constructor [S] has the type [nat -> nat], just like the
    functions [minustwo] and [pred]: *)
Check S.
Check pred.
Check minustwo.
(** These are all things that can be applied to a number to yield a
    number.  However, there is a fundamental difference: functions
    like [pred] and [minustwo] come with _computation rules_ -- e.g.,
    the definition of [pred] says that [pred 2] can be simplified to
    [1] -- while the definition of [S] has no such behavior attached.
    Although it is like a function in the sense that it can be applied
    to an argument, it does not _do_ anything at all! *)
(** For most function definitions over numbers, pure pattern
    matching is not enough: we also need recursion.  For example, to
    check that a number [n] is even, we may need to recursively check
    whether [n-2] is even.  To write such functions, we use the
    keyword [Fixpoint]. *)
Fixpoint evenb (n:nat) : bool :=
  match n with
  | O        => true
  | S O      => false
  | S (S n') => evenb n'
  end.
(** We can define [oddb] by a similar [Fixpoint] declaration, but here
    is a simpler definition that will be a bit easier to work with: *)
Definition oddb (n:nat) : bool   :=   negb (evenb n).
Example test_oddb1:    (oddb (S O)) = true.
Proof. reflexivity.  Qed.
Example test_oddb2:    (oddb (S (S (S (S O))))) = false.
Proof. reflexivity.  Qed.
(** Naturally, we can also define multi-argument functions by
    recursion.  (Once again, we use a module to avoid polluting the
    namespace.) *)
Module Playground2.
Fixpoint plus (n : nat) (m : nat) : nat :=
  match n with
    | O => m
    | S n' => S (plus n' m)
  end.
(** Adding three to two now gives us five, as we'd expect. *)
Eval compute in (plus (S (S (S O))) (S (S O))).
(** The simplification that Coq performs to reach this conclusion can
    be visualized as follows: *)
(*  [plus (S (S (S O))) (S (S O))]    
==> [S (plus (S (S O)) (S (S O)))] by the second clause of the [match]
==> [S (S (plus (S O) (S (S O))))] by the second clause of the [match]
==> [S (S (S (plus O (S (S O)))))] by the second clause of the [match]
==> [S (S (S (S (S O))))]          by the first clause of the [match]
*)
(** As a notational convenience, if two or more arguments have
    the same type, they can be written together.  In the following
    definition, [(n m : nat)] means just the same as if we had written
    [(n : nat) (m : nat)]. *)
Fixpoint mult (n m : nat) : nat :=
  match n with
    | O => O
    | S n' => plus m (mult n' m)
  end.
Example test_mult1: (mult 3 3) = 9.
Proof. reflexivity.  Qed.
(** You can match two expressions at once by putting a comma
    between them: *)
Fixpoint minus (n m:nat) : nat :=
  match n, m with
  | O   , _    => O
  | S _ , O    => n
  | S n', S m' => minus n' m'
  end.
(** The _ in the first line is a _wildcard pattern_.  Writing _ in a
    pattern is the same as writing some variable that doesn't get used
    on the right-hand side.  This avoids the need to invent a bogus
    variable name. *)
End Playground2.
Fixpoint exp (base power : nat) : nat :=
  match power with
    | O => S O
    | S p => mult base (exp base p)
  end.
(** **** Exercise: 1 star (factorial)  *)
(** Recall the standard factorial function:
<<
    factorial(0)  =  1 
    factorial(n)  =  n * factorial(n-1)     (if n>0)
>>
    Translate this into Coq. *)
Fixpoint factorial (n:nat) : nat :=
  match n with
    | O => 1
    | S n' => mult n (factorial n')
  end.
Example test_factorial1:          (factorial 3) = 6.
Proof. reflexivity. Qed.
Example test_factorial2:          (factorial 5) = (mult 10 12).
Proof. reflexivity. Qed.
(** [] *)
(** We can make numerical expressions a little easier to read and
    write by introducing ""notations"" for addition, multiplication, and
    subtraction. *)
Notation ""x + y"" := (plus x y)  
                       (at level 50, left associativity) 
                       : nat_scope.
Notation ""x - y"" := (minus x y)  
                       (at level 50, left associativity) 
                       : nat_scope.
Notation ""x * y"" := (mult x y)  
                       (at level 40, left associativity) 
                       : nat_scope.
Check ((0 + 1) + 1).
(** (The [level], [associativity], and [nat_scope] annotations
   control how these notations are treated by Coq's parser.  The
   details are not important, but interested readers can refer to the
   ""More on Notation"" subsection in the ""Advanced Material"" section at
   the end of this chapter.) *)
(** Note that these do not change the definitions we've already
    made: they are simply instructions to the Coq parser to accept [x
    + y] in place of [plus x y] and, conversely, to the Coq
    pretty-printer to display [plus x y] as [x + y]. *)
(** When we say that Coq comes with nothing built-in, we really
    mean it: even equality testing for numbers is a user-defined
    operation! *)
(** The [beq_nat] function tests [nat]ural numbers for [eq]uality,
    yielding a [b]oolean.  Note the use of nested [match]es (we could
    also have used a simultaneous match, as we did in [minus].)  *)
Fixpoint beq_nat (n m : nat) : bool :=
  match n with
  | O => match m with
         | O => true
         | S m' => false
         end
  | S n' => match m with
            | O => false
            | S m' => beq_nat n' m'
            end
  end.
(** Similarly, the [ble_nat] function tests [nat]ural numbers for
    [l]ess-or-[e]qual, yielding a [b]oolean. *)
Fixpoint ble_nat (n m : nat) : bool :=
  match n with
  | O => true
  | S n' =>
      match m with
      | O => false
      | S m' => ble_nat n' m'
      end
  end.
Example test_ble_nat1:             (ble_nat 2 2) = true.
Proof. reflexivity.  Qed.
Example test_ble_nat2:             (ble_nat 2 4) = true.
Proof. reflexivity.  Qed.
Example test_ble_nat3:             (ble_nat 4 2) = false.
Proof. reflexivity.  Qed.
(** **** Exercise: 2 stars (blt_nat)  *)
(** The [blt_nat] function tests [nat]ural numbers for [l]ess-[t]han,
    yielding a [b]oolean.  Instead of making up a new [Fixpoint] for
    this one, define it in terms of a previously defined function. *)
Definition blt_nat (n m : nat) : bool :=
  ble_nat (S n) m.
Example test_blt_nat1:             (blt_nat 2 2) = false.
Proof. reflexivity. Qed.
Example test_blt_nat2:             (blt_nat 2 4) = true.
Proof. reflexivity. Qed.
Example test_blt_nat3:             (blt_nat 4 2) = false.
Proof. reflexivity. Qed.
(** [] *)
(* ###################################################################### *)
(** * Proof by Simplification *)
(** Now that we've defined a few datatypes and functions, let's
    turn to the question of how to state and prove properties of their
    behavior.  Actually, in a sense, we've already started doing this:
    each [Example] in the previous sections makes a precise claim
    about the behavior of some function on some particular inputs.
    The proofs of these claims were always the same: use [reflexivity] 
    to check that both sides of the [=] simplify to identical values. 
    (By the way, it will be useful later to know that
    [reflexivity] actually does somewhat more simplification than [simpl] 
    does -- for example, it tries ""unfolding"" defined terms, replacing them with
    their right-hand sides.  The reason for this difference is that,
    when reflexivity succeeds, the whole goal is finished and we don't
    need to look at whatever expanded expressions [reflexivity] has
    found; by contrast, [simpl] is used in situations where we may
    have to read and understand the new goal, so we would not want it
    blindly expanding definitions.) 
    The same sort of ""proof by simplification"" can be used to prove
    more interesting properties as well.  For example, the fact that
    [0] is a ""neutral element"" for [+] on the left can be proved
    just by observing that [0 + n] reduces to [n] no matter what
    [n] is, a fact that can be read directly off the definition of [plus].*)
Theorem plus_O_n : forall n : nat, 0 + n = n.
Proof.
  intros n. reflexivity.  Qed.
(** (_Note_: You may notice that the above statement looks
    different in the original source file and the final html output. In Coq
    files, we write the [forall] universal quantifier using the
    ""_forall_"" reserved identifier. This gets printed as an
    upside-down ""A"", the familiar symbol used in logic.)  *)
(** The form of this theorem and proof are almost exactly the
    same as the examples above; there are just a few differences.
    First, we've used the keyword [Theorem] instead of
    [Example].  Indeed, the difference is purely a matter of
    style; the keywords [Example] and [Theorem] (and a few others,
    including [Lemma], [Fact], and [Remark]) mean exactly the same
    thing to Coq.
    Secondly, we've added the quantifier [forall n:nat], so that our
    theorem talks about _all_ natural numbers [n].  In order to prove
    theorems of this form, we need to to be able to reason by
    _assuming_ the existence of an arbitrary natural number [n].  This
    is achieved in the proof by [intros n], which moves the quantifier
    from the goal to a ""context"" of current assumptions. In effect, we
    start the proof by saying ""OK, suppose [n] is some arbitrary number.""
    The keywords [intros], [simpl], and [reflexivity] are examples of
    _tactics_.  A tactic is a command that is used between [Proof] and
    [Qed] to tell Coq how it should check the correctness of some
    claim we are making.  We will see several more tactics in the rest
    of this lecture, and yet more in future lectures. *)
(** We could try to prove a similar theorem about [plus] *)
Theorem plus_n_O : forall n, n + 0 = n.
(** However, unlike the previous proof, [simpl] doesn't do anything in
    this case *)
Proof.
  simpl. (* Doesn't do anything! *)
Abort.
(** (Can you explain why this happens?  Step through both proofs with
    Coq and notice how the goal and context change.) *)
Theorem plus_1_l : forall n:nat, 1 + n = S n. 
Proof.
  intros n. reflexivity.  Qed.
Theorem mult_0_l : forall n:nat, 0 * n = 0.
Proof.
  intros n. reflexivity.  Qed.
(** The [_l] suffix in the names of these theorems is
    pronounced ""on the left."" *)
(* ###################################################################### *)
(** * Proof by Rewriting *)
(** Here is a slightly more interesting theorem: *)
Theorem plus_id_example : forall n m:nat,
  n = m -> 
  n + n = m + m.
(** Instead of making a completely universal claim about all numbers
    [n] and [m], this theorem talks about a more specialized property
    that only holds when [n = m].  The arrow symbol is pronounced
    ""implies.""
    As before, we need to be able to reason by assuming the existence
    of some numbers [n] and [m].  We also need to assume the hypothesis
    [n = m]. The [intros] tactic will serve to move all three of these
    from the goal into assumptions in the current context. 
    Since [n] and [m] are arbitrary numbers, we can't just use
    simplification to prove this theorem.  Instead, we prove it by
    observing that, if we are assuming [n = m], then we can replace
    [n] with [m] in the goal statement and obtain an equality with the
    same expression on both sides.  The tactic that tells Coq to
    perform this replacement is called [rewrite]. *)
Proof.
  intros n m.   (* move both quantifiers into the context *)
  intros H.     (* move the hypothesis into the context *)
  rewrite -> H. (* Rewrite the goal using the hypothesis *)
  reflexivity.  Qed.
(** The first line of the proof moves the universally quantified
    variables [n] and [m] into the context.  The second moves the
    hypothesis [n = m] into the context and gives it the (arbitrary)
    name [H].  The third tells Coq to rewrite the current goal ([n + n
    = m + m]) by replacing the/ left side of the equality hypothesis
    [H] with the right side.
    (The arrow symbol in the [rewrite] has nothing to do with
    implication: it tells Coq to apply the rewrite from left to right.
    To rewrite from right to left, you can use [rewrite <-].  Try
    making this change in the above proof and see what difference it
    makes in Coq's behavior.) *)
(** **** Exercise: 1 star (plus_id_exercise)  *)
(** Remove ""[Admitted.]"" and fill in the proof. *)
Theorem plus_id_exercise : forall n m o : nat,
  n = m -> m = o -> n + m = m + o.
Proof.
  intros n m o H1 H2.
  rewrite H1. rewrite <- H2.
  reflexivity.
Qed.
(** [] *)
(** As we've seen in earlier examples, the [Admitted] command
    tells Coq that we want to skip trying to prove this theorem and
    just accept it as a given.  This can be useful for developing
    longer proofs, since we can state subsidiary facts that we believe
    will be useful for making some larger argument, use [Admitted] to
    accept them on faith for the moment, and continue thinking about
    the larger argument until we are sure it makes sense; then we can
    go back and fill in the proofs we skipped.  Be careful, though:
    every time you say [Admitted] (or [admit]) you are leaving a door
    open for total nonsense to enter Coq's nice, rigorous, formally
    checked world! *)
(** We can also use the [rewrite] tactic with a previously proved
    theorem instead of a hypothesis from the context. *)
Theorem mult_0_plus : forall n m : nat,
  (0 + n) * m = n * m.
Proof.
  intros n m.
  rewrite -> plus_O_n.
  reflexivity.  Qed.
(** **** Exercise: 2 stars (mult_S_1)  *)
Theorem mult_S_1 : forall n m : nat,
  m = S n -> 
  m * (1 + n) = m * m.
Proof.
  intros n m H. simpl. rewrite <- H.
  reflexivity.
Qed.
(** [] *)
(* ###################################################################### *)
(** * Proof by Case Analysis *) 
(** Of course, not everything can be proved by simple
    calculation: In general, unknown, hypothetical values (arbitrary
    numbers, booleans, lists, etc.) can block the calculation.  
    For example, if we try to prove the following fact using the 
    [simpl] tactic as above, we get stuck. *)
Theorem plus_1_neq_0_firsttry : forall n : nat,
  beq_nat (n + 1) 0 = false.
Proof.
  intros n. 
  simpl.  (* does nothing! *)
Abort.
(** The reason for this is that the definitions of both
    [beq_nat] and [+] begin by performing a [match] on their first
    argument.  But here, the first argument to [+] is the unknown
    number [n] and the argument to [beq_nat] is the compound
    expression [n + 1]; neither can be simplified.
    What we need is to be able to consider the possible forms of [n]
    separately.  If [n] is [O], then we can calculate the final result
    of [beq_nat (n + 1) 0] and check that it is, indeed, [false].
    And if [n = S n'] for some [n'], then, although we don't know
    exactly what number [n + 1] yields, we can calculate that, at
    least, it will begin with one [S], and this is enough to calculate
    that, again, [beq_nat (n + 1) 0] will yield [false].
    The tactic that tells Coq to consider, separately, the cases where
    [n = O] and where [n = S n'] is called [destruct]. *)
Theorem plus_1_neq_0 : forall n : nat,
  beq_nat (n + 1) 0 = false.
Proof.
  intros n. destruct n as [| n'].
    reflexivity.
    reflexivity.  Qed.
(** The [destruct] generates _two_ subgoals, which we must then
    prove, separately, in order to get Coq to accept the theorem as
    proved.  (No special command is needed for moving from one subgoal
    to the other.  When the first subgoal has been proved, it just
    disappears and we are left with the other ""in focus."")  In this
    proof, each of the subgoals is easily proved by a single use of
    [reflexivity].
    The annotation ""[as [| n']]"" is called an _intro pattern_.  It
    tells Coq what variable names to introduce in each subgoal.  In
    general, what goes between the square brackets is a _list_ of
    lists of names, separated by [|].  Here, the first component is
    empty, since the [O] constructor is nullary (it doesn't carry any
    data).  The second component gives a single name, [n'], since [S]
    is a unary constructor.
    The [destruct] tactic can be used with any inductively defined
    datatype.  For example, we use it here to prove that boolean
    negation is involutive -- i.e., that negation is its own
    inverse. *)
Theorem negb_involutive : forall b : bool,
  negb (negb b) = b.
Proof.
  intros b. destruct b.
    reflexivity.
    reflexivity.  Qed.
(** Note that the [destruct] here has no [as] clause because
    none of the subcases of the [destruct] need to bind any variables,
    so there is no need to specify any names.  (We could also have
    written [as [|]], or [as []].)  In fact, we can omit the [as]
    clause from _any_ [destruct] and Coq will fill in variable names
    automatically.  Although this is convenient, it is arguably bad
    style, since Coq often makes confusing choices of names when left
    to its own devices. *)
(** **** Exercise: 1 star (zero_nbeq_plus_1)  *)
Theorem zero_nbeq_plus_1 : forall n : nat,
  beq_nat 0 (n + 1) = false.
Proof.
  intros n.
  destruct n as [| n'].
  simpl. reflexivity.
  simpl. reflexivity.
Qed.
(** [] *)
(* ###################################################################### *)
(** * More Exercises *)
(** **** Exercise: 2 stars (boolean_functions)  *)
(** Use the tactics you have learned so far to prove the following 
    theorem about boolean functions. *)
Theorem identity_fn_applied_twice : 
  forall (f : bool -> bool), 
  (forall (x : bool), f x = x) ->
  forall (b : bool), f (f b) = b.
Proof.
  intros f H b.
  rewrite H. rewrite H. reflexivity.
Qed.
(** Now state and prove a theorem [negation_fn_applied_twice] similar
    to the previous one but where the second hypothesis says that the
    function [f] has the property that [f x = negb x].*)
Theorem negation_fn_applied_twice :
  forall (f : bool -> bool),
    (forall (x : bool), f x = negb x) ->
    forall (b : bool), f (f b) = b.
Proof.
  intros f H b.
  rewrite H. rewrite H.
  rewrite negb_involutive.
  reflexivity.
Qed.
(** [] *)
(** **** Exercise: 2 stars (andb_eq_orb)  *)
(** Prove the following theorem.  (You may want to first prove a
    subsidiary lemma or two. Alternatively, remember that you do
    not have to introduce all hypotheses at the same time.) *)
Lemma andb_true :
  forall (b : bool),
    andb b true = true -> b = true.
Proof.
  intros b H.
  destruct b. reflexivity.
  inversion H.
Qed.
Lemma orb_true :
  forall (b : bool),
    orb b true = true.
Proof.
  intros b. destruct b; reflexivity.
Qed.
Lemma andb_true_b :
  forall (b : bool),
    andb b true = b.
Proof.
  intros b.
  destruct b; reflexivity.
Qed.
Lemma orb_false_b :
  forall (b : bool),
    orb b false = b.
Proof.
  intros b. destruct b; reflexivity.
Qed.
Theorem andb_false :
  forall (b : bool),
    andb b false = false.
Proof.
  intros b. destruct b ; reflexivity.
Qed.
Theorem andb_eq_orb : 
  forall (b c : bool),
  (andb b c = orb b c) ->
  b = c.
Proof.
  intros b c H.
  destruct c.
  rewrite <- orb_true with (b := b).
  rewrite <- H. rewrite andb_true_b. reflexivity.
  rewrite <- andb_false with (b := b).
  rewrite H. rewrite orb_false_b. reflexivity.
Qed.
(** [] *)
(** **** Exercise: 3 stars (binary)  *)
(** Consider a different, more efficient representation of natural
    numbers using a binary rather than unary system.  That is, instead
    of saying that each natural number is either zero or the successor
    of a natural number, we can say that each binary number is either
      - zero,
      - twice a binary number, or
      - one more than twice a binary number.
    (a) First, write an inductive definition of the type [bin]
        corresponding to this description of binary numbers. 
    (Hint: Recall that the definition of [nat] from class,
    Inductive nat : Type :=
      | O : nat
      | S : nat -> nat.
    says nothing about what [O] and [S] ""mean.""  It just says ""[O] is
    in the set called [nat], and if [n] is in the set then so is [S
    n].""  The interpretation of [O] as zero and [S] as successor/plus
    one comes from the way that we _use_ [nat] values, by writing
    functions to do things with them, proving things about them, and
    so on.  Your definition of [bin] should be correspondingly simple;
    it is the functions you will write next that will give it
    mathematical meaning.)
    (b) Next, write an increment function [incr] for binary numbers, 
        and a function [bin_to_nat] to convert binary numbers to unary numbers.
    (c) Write five unit tests [test_bin_incr1], [test_bin_incr2], etc.
        for your increment and binary-to-unary functions. Notice that 
        incrementing a binary number and then converting it to unary 
        should yield the same result as first converting it to unary and 
        then incrementing. 
 *)
Inductive bin : Type :=
| Ob : bin
| Tb : bin -> bin
| STb : bin -> bin.
Fixpoint incr (n: bin) : bin :=
  match n with
    | Ob => STb Ob
    | Tb n => STb n
    | STb n => Tb (incr n)
  end.
Fixpoint bin_to_nat (n : bin) : nat :=
  match n with
    | Ob => O
    | Tb n => 2 * (bin_to_nat n)
    | STb n => 2 * (bin_to_nat n) + 1
  end.
Lemma plus_1_S : forall n : nat, n + 1 = S n.
Proof.
  intros n.
  induction n. simpl. reflexivity.
  simpl. rewrite IHn. reflexivity.
Qed.
Lemma plus_O : forall n : nat, n + 0 = n.
  intros n. induction n. reflexivity. simpl. rewrite IHn. reflexivity.
Qed.
Lemma S_equal : forall n m : nat, S n = S m <-> n = m.
Proof.
  intros n m.
  split. intros H. inversion H. reflexivity.
  intros H. rewrite H. reflexivity.
Qed.
Lemma S_equal_l : forall n m : nat, S n = S m -> n = m.
Proof.
  intros n m H. inversion H. reflexivity.
Qed.
Lemma S_equal_r : forall n m : nat, n = m -> S n = S m.
  intros n m H. rewrite H. reflexivity.
Qed.
Lemma plus_SS : forall n m : nat, S n + S m = S (S (n + m)).
Proof.
  intros n. induction n as [|n'].
  intros m. simpl. reflexivity.
  intros m. simpl. apply S_equal. rewrite <- IHn'. simpl. reflexivity.
Qed.
Theorem incr_bin_nat :
  forall n : bin,
    bin_to_nat (incr n) = S (bin_to_nat n).
Proof.
  intros n.
  induction n as [| n' | n'].
  (* n = Ob *) simpl. reflexivity.
  (* n = Tb n' *) simpl. rewrite plus_1_S. reflexivity.
  (* n = STb n' *)
  simpl. rewrite IHn'. 
  rewrite plus_1_S. rewrite plus_O. rewrite plus_O. rewrite plus_SS. reflexivity.
Qed.
(** [] *)
(* ###################################################################### *)
(** * More on Notation (Advanced) *)
(** In general, sections marked Advanced are not needed to follow the
    rest of the book, except possibly other Advanced sections.  On a
    first reading, you might want to skim these sections so that you
    know what's there for future reference. *)
Notation ""x + y"" := (plus x y)  
                       (at level 50, left associativity) 
                       : nat_scope.
Notation ""x * y"" := (mult x y)  
                       (at level 40, left associativity) 
                       : nat_scope.
(** For each notation-symbol in Coq we can specify its _precedence level_
    and its _associativity_. The precedence level n can be specified by the
    keywords [at level n] and it is helpful to disambiguate
    expressions containing different symbols. The associativity is helpful
    to disambiguate expressions containing more occurrences of the same 
    symbol. For example, the parameters specified above for [+] and [*]
    say that the expression [1+2*3*4] is a shorthand for the expression
    [(1+((2*3)*4))]. Coq uses precedence levels from 0 to 100, and 
    _left_, _right_, or _no_ associativity.
    Each notation-symbol in Coq is also active in a _notation scope_.  
    Coq tries to guess what scope you mean, so when you write [S(O*O)] 
    it guesses [nat_scope], but when you write the cartesian
    product (tuple) type [bool*bool] it guesses [type_scope].
    Occasionally you have to help it out with percent-notation by
    writing [(x*y)%nat], and sometimes in Coq's feedback to you it
    will use [%nat] to indicate what scope a notation is in.
    Notation scopes also apply to numeral notation (3,4,5, etc.), so you
    may sometimes see [0%nat] which means [O], or [0%Z] which means the
    Integer zero.
*)
(** * [Fixpoint] and Structural Recursion (Advanced) *)
Fixpoint plus' (n : nat) (m : nat) : nat :=
  match n with
    | O => m
    | S n' => S (plus' n' m)
  end.
(** When Coq checks this definition, it notes that [plus'] is
    ""decreasing on 1st argument.""  What this means is that we are
    performing a _structural recursion_ over the argument [n] -- i.e.,
    that we make recursive calls only on strictly smaller values of
    [n].  This implies that all calls to [plus'] will eventually
    terminate.  Coq demands that some argument of _every_ [Fixpoint]
    definition is ""decreasing"".
    This requirement is a fundamental feature of Coq's design: In
    particular, it guarantees that every function that can be defined
    in Coq will terminate on all inputs.  However, because Coq's
    ""decreasing analysis"" is not very sophisticated, it is sometimes
    necessary to write functions in slightly unnatural ways. *)
(** **** Exercise: 2 stars, optional (decreasing)  *)
(** To get a concrete sense of this, find a way to write a sensible
    [Fixpoint] definition (of a simple function on numbers, say) that
    _does_ terminate on all inputs, but that Coq will reject because
    of this restriction. *)
(* FILL IN HERE *)
(** [] *)
(** $Date: 2014-12-31 15:31:47 -0500 (Wed, 31 Dec 2014) $ *)
module redFour__NMOSwk_X_1_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply0 gnd;
  rtranif1 #(100) NMOSfwk_0 (d, s, g);
endmodule   
module redFour__PMOSwk_X_0_833_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply1 vdd;
  rtranif0 #(100) PMOSfwk_0 (d, s, g);
endmodule   
module scanChainFive__scanL(in, out);
  input in;
  output out;
  supply1 vdd;
  supply0 gnd;
  wire net_4, net_7;
  redFour__NMOSwk_X_1_Delay_100 NMOSwk_0(.g(out), .d(in), .s(net_7));
  redFour__NMOSwk_X_1_Delay_100 NMOSwk_1(.g(out), .d(net_7), .s(gnd));
  redFour__PMOSwk_X_0_833_Delay_100 PMOSwk_0(.g(out), .d(net_4), .s(vdd));
  redFour__PMOSwk_X_0_833_Delay_100 PMOSwk_1(.g(out), .d(in), .s(net_4));
  not (strong0, strong1) #(100) invV_0 (out, in);
endmodule   
module redFour__NMOS_X_6_667_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply0 gnd;
  tranif1 #(100) NMOSf_0 (d, s, g);
endmodule   
module redFour__PMOS_X_3_333_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply1 vdd;
  tranif0 #(100) PMOSf_0 (d, s, g);
endmodule   
module scanChainFive__scanP(in, src, drn);
  input in;
  input src;
  output drn;
  supply1 vdd;
  supply0 gnd;
  wire net_1;
  redFour__NMOS_X_6_667_Delay_100 NMOS_0(.g(in), .d(drn), .s(src));
  redFour__PMOS_X_3_333_Delay_100 PMOS_0(.g(net_1), .d(drn), .s(src));
  not (strong0, strong1) #(0) inv_0 (net_1, in);
endmodule   
module scanChainFive__scanRL(phi1, phi2, rd, sin, sout);
  input phi1;
  input phi2;
  input rd;
  input sin;
  output sout;
  supply1 vdd;
  supply0 gnd;
  wire net_0, net_2, net_3;
  scanChainFive__scanL foo1(.in(net_2), .out(net_3));
  scanChainFive__scanL foo2(.in(net_0), .out(sout));
  scanChainFive__scanP scanP_0(.in(rd), .src(vdd), .drn(net_0));
  scanChainFive__scanP scanP_1(.in(phi1), .src(net_3), .drn(net_0));
  scanChainFive__scanP scanP_2(.in(phi2), .src(sin), .drn(net_2));
endmodule   
module jtag__BR(SDI, phi1, phi2, read, SDO);
  input SDI;
  input phi1;
  input phi2;
  input read;
  output SDO;
  supply1 vdd;
  supply0 gnd;
  scanChainFive__scanRL scanRL_0(.phi1(phi1), .phi2(phi2), .rd(read), 
      .sin(SDI), .sout(SDO));
endmodule   
module scanChainFive__scanIRH(mclr, phi1, phi2, rd, sin, wr, dout, doutb, 
      sout);
  input mclr;
  input phi1;
  input phi2;
  input rd;
  input sin;
  input wr;
  output dout;
  output doutb;
  output sout;
  supply1 vdd;
  supply0 gnd;
  wire net_2, net_4, net_6, net_7;
  scanChainFive__scanL foo1(.in(net_6), .out(net_7));
  scanChainFive__scanL foo2(.in(net_2), .out(sout));
  scanChainFive__scanL foo3(.in(net_4), .out(doutb));
  not (strong0, strong1) #(100) invLT_0 (dout, doutb);
  scanChainFive__scanP scanP_0(.in(wr), .src(sout), .drn(net_4));
  scanChainFive__scanP scanP_1(.in(rd), .src(gnd), .drn(net_2));
  scanChainFive__scanP scanP_2(.in(mclr), .src(vdd), .drn(net_4));
  scanChainFive__scanP scanP_3(.in(phi1), .src(net_7), .drn(net_2));
  scanChainFive__scanP scanP_4(.in(phi2), .src(sin), .drn(net_6));
endmodule   
module scanChainFive__scanIRL(mclr, phi1, phi2, rd, sin, wr, dout, doutb, 
      sout);
  input mclr;
  input phi1;
  input phi2;
  input rd;
  input sin;
  input wr;
  output dout;
  output doutb;
  output sout;
  supply1 vdd;
  supply0 gnd;
  wire net_2, net_3, net_4, net_6;
  scanChainFive__scanL foo1(.in(net_2), .out(net_3));
  scanChainFive__scanL foo2(.in(net_4), .out(sout));
  scanChainFive__scanL foo3(.in(net_6), .out(doutb));
  not (strong0, strong1) #(100) invLT_0 (dout, doutb);
  scanChainFive__scanP scanP_0(.in(rd), .src(vdd), .drn(net_4));
  scanChainFive__scanP scanP_1(.in(mclr), .src(vdd), .drn(net_6));
  scanChainFive__scanP scanP_2(.in(wr), .src(sout), .drn(net_6));
  scanChainFive__scanP scanP_3(.in(phi1), .src(net_3), .drn(net_4));
  scanChainFive__scanP scanP_4(.in(phi2), .src(sin), .drn(net_2));
endmodule   
module jtag__IR(SDI, phi1, phi2, read, reset, write, IR, IRb, SDO);
  input SDI;
  input phi1;
  input phi2;
  input read;
  input reset;
  input write;
  output [8:1] IR;
  output [8:1] IRb;
  output SDO;
  supply1 vdd;
  supply0 gnd;
  wire net_1, net_2, net_3, net_4, net_5, net_6, net_7;
  scanChainFive__scanIRH scanIRH_0(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_1), .wr(write), .dout(IR[1]), .doutb(IRb[1]), 
      .sout(SDO));
  scanChainFive__scanIRL scanIRL_0(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_3), .wr(write), .dout(IR[7]), .doutb(IRb[7]), 
      .sout(net_2));
  scanChainFive__scanIRL scanIRL_1(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_5), .wr(write), .dout(IR[5]), .doutb(IRb[5]), 
      .sout(net_4));
  scanChainFive__scanIRL scanIRL_2(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_2), .wr(write), .dout(IR[6]), .doutb(IRb[6]), 
      .sout(net_5));
  scanChainFive__scanIRL scanIRL_3(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_7), .wr(write), .dout(IR[3]), .doutb(IRb[3]), 
      .sout(net_6));
  scanChainFive__scanIRL scanIRL_4(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_6), .wr(write), .dout(IR[2]), .doutb(IRb[2]), 
      .sout(net_1));
  scanChainFive__scanIRL scanIRL_5(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_4), .wr(write), .dout(IR[4]), .doutb(IRb[4]), 
      .sout(net_7));
  scanChainFive__scanIRL scanIRL_6(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(SDI), .wr(write), .dout(IR[8]), .doutb(IRb[8]), 
      .sout(net_3));
endmodule   
module redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1(ina, inb, 
      out);
  input ina;
  input inb;
  output out;
  supply1 vdd;
  supply0 gnd;
  nor (strong0, strong1) #(100) nor2_0 (out, ina, inb);
endmodule   
module jtag__IRdecode(IR, IRb, Bypass, ExTest, SamplePreload, ScanPath);
  input [4:1] IR;
  input [4:1] IRb;
  output Bypass;
  output ExTest;
  output SamplePreload;
  output [12:0] ScanPath;
  supply1 vdd;
  supply0 gnd;
  wire H00, H01, H10, H11, L00, L01, L10, L11, net_19, net_21, net_23, net_25;
  wire net_26, net_27, net_28, net_29, net_30, net_31, net_32, net_33, net_34;
  wire net_35, net_36, net_37;
  not (strong0, strong1) #(100) inv_0 (Bypass, net_19);
  not (strong0, strong1) #(100) inv_1 (SamplePreload, net_21);
  not (strong0, strong1) #(100) inv_2 (ExTest, net_23);
  not (strong0, strong1) #(100) inv_3 (ScanPath[12], net_25);
  not (strong0, strong1) #(100) inv_4 (ScanPath[11], net_26);
  not (strong0, strong1) #(100) inv_5 (ScanPath[10], net_27);
  not (strong0, strong1) #(100) inv_6 (ScanPath[9], net_28);
  not (strong0, strong1) #(100) inv_7 (ScanPath[8], net_29);
  not (strong0, strong1) #(100) inv_8 (ScanPath[7], net_30);
  not (strong0, strong1) #(100) inv_9 (ScanPath[6], net_31);
  not (strong0, strong1) #(100) inv_10 (ScanPath[5], net_32);
  not (strong0, strong1) #(100) inv_11 (ScanPath[4], net_33);
  not (strong0, strong1) #(100) inv_12 (ScanPath[3], net_34);
  not (strong0, strong1) #(100) inv_13 (ScanPath[2], net_35);
  not (strong0, strong1) #(100) inv_14 (ScanPath[1], net_36);
  not (strong0, strong1) #(100) inv_15 (ScanPath[0], net_37);
  nand (strong0, strong1) #(100) nand2_0 (net_19, L11, H11);
  nand (strong0, strong1) #(100) nand2_1 (net_21, L10, H11);
  nand (strong0, strong1) #(100) nand2_2 (net_23, L01, H11);
  nand (strong0, strong1) #(100) nand2_3 (net_25, L00, H11);
  nand (strong0, strong1) #(100) nand2_4 (net_26, L11, H10);
  nand (strong0, strong1) #(100) nand2_5 (net_27, L10, H10);
  nand (strong0, strong1) #(100) nand2_6 (net_28, L01, H10);
  nand (strong0, strong1) #(100) nand2_7 (net_29, L00, H10);
  nand (strong0, strong1) #(100) nand2_8 (net_30, L11, H01);
  nand (strong0, strong1) #(100) nand2_9 (net_31, L10, H01);
  nand (strong0, strong1) #(100) nand2_10 (net_32, L01, H01);
  nand (strong0, strong1) #(100) nand2_11 (net_33, L00, H01);
  nand (strong0, strong1) #(100) nand2_12 (net_34, L11, H00);
  nand (strong0, strong1) #(100) nand2_13 (net_35, L10, H00);
  nand (strong0, strong1) #(100) nand2_14 (net_36, L01, H00);
  nand (strong0, strong1) #(100) nand2_15 (net_37, L00, H00);
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_0(.ina(IR[1]), .inb(IR[2]), .out(L00));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_1(.ina(IRb[1]), .inb(IR[2]), .out(L01));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_2(.ina(IR[1]), .inb(IRb[2]), .out(L10));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_3(.ina(IRb[1]), .inb(IRb[2]), .out(L11));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_4(.ina(IR[3]), .inb(IR[4]), .out(H00));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_5(.ina(IRb[3]), .inb(IR[4]), .out(H01));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_6(.ina(IR[3]), .inb(IRb[4]), .out(H10));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_7(.ina(IRb[3]), .inb(IRb[4]), .out(H11));
endmodule   
module redFour__PMOSwk_X_0_222_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply1 vdd;
  rtranif0 #(100) PMOSfwk_0 (d, s, g);
endmodule   
module jtag__capture_ctl(capture, phi2, sel, out, phi1);
  input capture;
  input phi2;
  input sel;
  output out;
  input phi1;
  supply1 vdd;
  supply0 gnd;
  wire net_1, net_2, net_3, net_4;
  scanChainFive__scanL foo(.in(net_2), .out(net_3));
  not (strong0, strong1) #(100) inv_0 (net_1, capture);
  not (strong0, strong1) #(100) inv_1 (out, net_4);
  nand (strong0, strong1) #(100) nand3_0 (net_4, sel, net_3, phi1);
  scanChainFive__scanP scanP_0(.in(phi2), .src(net_1), .drn(net_2));
endmodule   
module jtag__shift_ctl(phi1_fb, phi2_fb, sel, shift, phi1_out, phi2_out, 
      phi1_in, phi2_in);
  input phi1_fb;
  input phi2_fb;
  input sel;
  input shift;
  output phi1_out;
  output phi2_out;
  input phi1_in;
  input phi2_in;
  supply1 vdd;
  supply0 gnd;
  wire net_1, net_2, net_3, net_4, net_7;
  jtag__clockGen clockGen_0(.clk(net_7), .phi1_fb(phi1_fb), .phi2_fb(phi2_fb), 
      .phi1_out(phi1_out), .phi2_out(phi2_out));
  scanChainFive__scanL foo(.in(net_2), .out(net_3));
  not (strong0, strong1) #(100) inv_0 (net_7, net_4);
  not (strong0, strong1) #(100) inv_1 (net_1, shift);
  nand (strong0, strong1) #(100) nand3_0 (net_4, sel, net_3, phi1_in);
  scanChainFive__scanP scanP_0(.in(phi2_in), .src(net_1), .drn(net_2));
endmodule   
module jtag__update_ctl(sel, update, out, phi2);
  input sel;
  input update;
  output out;
  input phi2;
  supply1 vdd;
  supply0 gnd;
  wire net_1;
  not (strong0, strong1) #(100) inv_0 (out, net_1);
  nand (strong0, strong1) #(100) nand3_0 (net_1, sel, update, phi2);
endmodule   
module jtag__jtagIRControl(capture, phi1_fb, phi1_in, phi2_fb, phi2_in, shift, 
      update, phi1_out, phi2_out, read, write);
  input capture;
  input phi1_fb;
  input phi1_in;
  input phi2_fb;
  input phi2_in;
  input shift;
  input update;
  output phi1_out;
  output phi2_out;
  output read;
  output write;
  supply1 vdd;
  supply0 gnd;
  jtag__capture_ctl capture__0(.capture(capture), .phi2(phi2_in), .sel(vdd), 
      .out(read), .phi1(phi1_in));
  jtag__shift_ctl shift_ct_0(.phi1_fb(phi1_fb), .phi2_fb(phi2_fb), .sel(vdd), 
      .shift(shift), .phi1_out(phi1_out), .phi2_out(phi2_out), 
      .phi1_in(phi1_in), .phi2_in(phi2_in));
  jtag__update_ctl update_c_0(.sel(vdd), .update(update), .out(write), 
      .phi2(phi2_in));
endmodule   
module redFour__NMOS_X_8_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply0 gnd;
  tranif1 #(100) NMOSf_0 (d, s, g);
endmodule   
module redFour__PMOS_X_4_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply1 vdd;
  tranif0 #(100) PMOSf_0 (d, s, g);
endmodule   
module jtag__tsinvBig(Din, en, enb, Dout);
  input Din;
  input en;
  input enb;
  output Dout;
  supply1 vdd;
  supply0 gnd;
  wire net_13, net_14, net_22, net_23;
  redFour__NMOS_X_8_Delay_100 NMOS_0(.g(Din), .d(net_13), .s(gnd));
  redFour__NMOS_X_8_Delay_100 NMOS_1(.g(en), .d(Dout), .s(net_13));
  redFour__NMOS_X_8_Delay_100 NMOS_2(.g(en), .d(Dout), .s(net_23));
  redFour__NMOS_X_8_Delay_100 NMOS_3(.g(Din), .d(net_23), .s(gnd));
  redFour__PMOS_X_4_Delay_100 PMOS_0(.g(enb), .d(Dout), .s(net_14));
  redFour__PMOS_X_4_Delay_100 PMOS_1(.g(Din), .d(net_14), .s(vdd));
  redFour__PMOS_X_4_Delay_100 PMOS_2(.g(enb), .d(Dout), .s(net_22));
  redFour__PMOS_X_4_Delay_100 PMOS_3(.g(Din), .d(net_22), .s(vdd));
endmodule   
module jtag__jtagScanControl(TDI, capture, phi1_fb, phi1_in, phi2_fb, phi2_in, 
      sel, shift, update, TDO, phi1_out, phi2_out, read, write);
  input TDI;
  input capture;
  input phi1_fb;
  input phi1_in;
  input phi2_fb;
  input phi2_in;
  input sel;
  input shift;
  input update;
  output TDO;
  output phi1_out;
  output phi2_out;
  output read;
  output write;
  supply1 vdd;
  supply0 gnd;
  wire net_0, net_2;
  jtag__capture_ctl capture__0(.capture(capture), .phi2(phi2_in), .sel(sel), 
      .out(read), .phi1(phi1_in));
  not (strong0, strong1) #(100) inv_0 (net_2, sel);
  not (strong0, strong1) #(100) inv_1 (net_0, TDI);
  jtag__shift_ctl shift_ct_0(.phi1_fb(phi1_fb), .phi2_fb(phi2_fb), .sel(sel), 
      .shift(shift), .phi1_out(phi1_out), .phi2_out(phi2_out), 
      .phi1_in(phi1_in), .phi2_in(phi2_in));
  jtag__tsinvBig tsinvBig_0(.Din(net_0), .en(sel), .enb(net_2), .Dout(TDO));
  jtag__update_ctl update_c_0(.sel(sel), .update(update), .out(write), 
      .phi2(phi2_in));
endmodule   
module redFour__NMOS_X_5_667_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply0 gnd;
  tranif1 #(100) NMOSf_0 (d, s, g);
endmodule   
module redFour__PMOS_X_2_833_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply1 vdd;
  tranif0 #(100) PMOSf_0 (d, s, g);
endmodule   
module jtag__tsinv(Din, Dout, en, enb);
  input Din;
  input Dout;
  input en;
  input enb;
  supply1 vdd;
  supply0 gnd;
  wire net_1, net_2;
  redFour__NMOS_X_5_667_Delay_100 NMOS_0(.g(Din), .d(net_1), .s(gnd));
  redFour__NMOS_X_5_667_Delay_100 NMOS_1(.g(en), .d(Dout), .s(net_1));
  redFour__PMOS_X_2_833_Delay_100 PMOS_0(.g(Din), .d(net_2), .s(vdd));
  redFour__PMOS_X_2_833_Delay_100 PMOS_1(.g(enb), .d(Dout), .s(net_2));
endmodule   
module jtag__mux2_phi2(Din0, Din1, phi2, sel, Dout);
  input Din0;
  input Din1;
  input phi2;
  input sel;
  output Dout;
  supply1 vdd;
  supply0 gnd;
  wire net_1, net_2, net_3, net_5, net_6;
  not (strong0, strong1) #(100) inv_0 (net_5, sel);
  not (strong0, strong1) #(100) inv_1 (net_1, net_6);
  not (strong0, strong1) #(100) inv_2 (Dout, net_3);
  scanChainFive__scanL scanL_0(.in(net_2), .out(net_3));
  scanChainFive__scanP scanP_0(.in(phi2), .src(net_1), .drn(net_2));
  jtag__tsinv tsinv_0(.Din(Din0), .Dout(net_6), .en(net_5), .enb(sel));
  jtag__tsinv tsinv_1(.Din(Din1), .Dout(net_6), .en(sel), .enb(net_5));
endmodule   
module jtag__scanAmp1w1648(in, out);
  input in;
  output out;
  supply1 vdd;
  supply0 gnd;
  wire net_0;
  tranif1 nmos_0(gnd, net_0, in);
  tranif1 nmos_1(gnd, out, net_0);
  tranif0 pmos_0(net_0, vdd, in);
  tranif0 pmos_1(out, vdd, net_0);
endmodule   
module redFour__nand2n_X_3_5_Delay_100_drive0_strong0_drive1_strong1(ina, inb, 
      out);
  input ina;
  input inb;
  output out;
  supply1 vdd;
  supply0 gnd;
  nand (strong0, strong1) #(100) nand2_0 (out, ina, inb);
endmodule   
module redFour__nand2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1(ina, inb, 
      out);
  input ina;
  input inb;
  output out;
  supply1 vdd;
  supply0 gnd;
  nand (strong0, strong1) #(100) nand2_0 (out, ina, inb);
endmodule   
module redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1(ina, inb, 
      out);
  input ina;
  input inb;
  output out;
  supply1 vdd;
  supply0 gnd;
  nor (strong0, strong1) #(100) nor2_0 (out, ina, inb);
endmodule   
module orangeTSMC180nm__wire_R_26m_100_C_0_025f(a);
  input a;
  supply0 gnd;
endmodule   
module orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100(a);
  input a;
  supply0 gnd;
  orangeTSMC180nm__wire_R_26m_100_C_0_025f wire_0(.a(a));
endmodule   
module jtag__o2a(inAa, inAb, inOb, out);
  input inAa;
  input inAb;
  input inOb;
  output out;
  supply1 vdd;
  supply0 gnd;
  wire net_0;
  nor (strong0, strong1) #(100) nor2_0 (net_0, inAa, inAb);
  redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_0(.ina(inOb), .inb(net_0), .out(out));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100 wire180_0(.a(net_0));
endmodule   
module orangeTSMC180nm__wire_R_26m_500_C_0_025f(a);
  input a;
  supply0 gnd;
endmodule   
module orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_500(a);
  input a;
  supply0 gnd;
  orangeTSMC180nm__wire_R_26m_500_C_0_025f wire_0(.a(a));
endmodule   
module jtag__slaveBit(din, phi2, slave);
  input din;
  input phi2;
  output slave;
  supply1 vdd;
  supply0 gnd;
  wire net_6, net_7;
  not (strong0, strong1) #(100) inv_0 (slave, net_7);
  scanChainFive__scanL scanL_0(.in(net_6), .out(net_7));
  scanChainFive__scanP scanP_0(.in(phi2), .src(din), .drn(net_6));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_500 wire180_0(.a(slave));
endmodule   
module redFour__NMOS_X_1_667_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply0 gnd;
  tranif1 #(100) NMOSf_0 (d, s, g);
endmodule   
module orangeTSMC180nm__wire_R_26m_750_C_0_025f(a);
  input a;
  supply0 gnd;
endmodule   
module orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_750(a);
  input a;
  supply0 gnd;
  orangeTSMC180nm__wire_R_26m_750_C_0_025f wire_0(.a(a));
endmodule   
module orangeTSMC180nm__wire_R_26m_1000_C_0_025f(a);
  input a;
  supply0 gnd;
endmodule   
module orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_1000(a);
  input a;
  supply0 gnd;
  orangeTSMC180nm__wire_R_26m_1000_C_0_025f wire_0(.a(a));
endmodule   
module jtag__stateBit(next, phi1, phi2, rst, master, slave, slaveBar);
  input next;
  input phi1;
  input phi2;
  input rst;
  output master;
  output slave;
  output slaveBar;
  supply1 vdd;
  supply0 gnd;
  wire net_12, net_13, net_14, net_17;
  redFour__NMOS_X_1_667_Delay_100 NMOS_0(.g(rst), .d(net_12), .s(gnd));
  not (strong0, strong1) #(100) inv_0 (slave, slaveBar);
  not (strong0, strong1) #(100) inv_1 (slaveBar, net_17);
  not (strong0, strong1) #(100) inv_2 (master, net_13);
  scanChainFive__scanL scanL_0(.in(net_12), .out(net_13));
  scanChainFive__scanL scanL_1(.in(net_14), .out(net_17));
  scanChainFive__scanP scanP_0(.in(phi1), .src(next), .drn(net_12));
  scanChainFive__scanP scanP_1(.in(phi2), .src(net_13), .drn(net_14));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_750 wire180_0(.a(master));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_1000 wire180_1(.a(slave));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_500 
      wire180_2(.a(slaveBar));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100 wire180_3(.a(next));
endmodule   
module redFour__PMOS_X_1_5_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply1 vdd;
  tranif0 #(100) PMOSf_0 (d, s, g);
endmodule   
module jtag__stateBitHI(next, phi1, phi2, rstb, master, slave, slaveBar);
  input next;
  input phi1;
  input phi2;
  input rstb;
  output master;
  output slave;
  output slaveBar;
  supply1 vdd;
  supply0 gnd;
  wire net_10, net_11, net_12, net_15;
  redFour__PMOS_X_1_5_Delay_100 PMOS_0(.g(rstb), .d(net_12), .s(vdd));
  not (strong0, strong1) #(100) inv_0 (slave, slaveBar);
  not (strong0, strong1) #(100) inv_1 (slaveBar, net_15);
  not (strong0, strong1) #(100) inv_2 (master, net_10);
  scanChainFive__scanL scanL_0(.in(net_12), .out(net_10));
  scanChainFive__scanL scanL_1(.in(net_11), .out(net_15));
  scanChainFive__scanP scanP_0(.in(phi1), .src(next), .drn(net_12));
  scanChainFive__scanP scanP_1(.in(phi2), .src(net_10), .drn(net_11));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_1000 wire180_0(.a(slave));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_500 
      wire180_1(.a(slaveBar));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100 wire180_2(.a(next));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_750 wire180_3(.a(master));
endmodule   
module orangeTSMC180nm__wire_R_26m_675_C_0_025f(a);
  input a;
  supply0 gnd;
endmodule   
module orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_675(a);
  input a;
  supply0 gnd;
  orangeTSMC180nm__wire_R_26m_675_C_0_025f wire_0(.a(a));
endmodule   
module orangeTSMC180nm__wire_R_26m_1500_C_0_025f(a);
  input a;
  supply0 gnd;
endmodule   
module orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_1500(a);
  input a;
  supply0 gnd;
  orangeTSMC180nm__wire_R_26m_1500_C_0_025f wire_0(.a(a));
endmodule   
module jtag__tapCtlJKL(TMS, TRSTb, phi1, phi2, CapDR, CapIR, Idle, PauseDR, 
      PauseIR, Reset, Reset_s, SelDR, SelIR, ShftDR, ShftIR, UpdDR, UpdIR, 
      X1DR, X1IR, X2DR, X2IR);
  input TMS;
  input TRSTb;
  input phi1;
  input phi2;
  output CapDR;
  output CapIR;
  output Idle;
  output PauseDR;
  output PauseIR;
  output Reset;
  output Reset_s;
  output SelDR;
  output SelIR;
  output ShftDR;
  output ShftIR;
  output UpdDR;
  output UpdIR;
  output X1DR;
  output X1IR;
  output X2DR;
  output X2IR;
  supply1 vdd;
  supply0 gnd;
  wire net_0, net_2, net_4, net_6, net_12, net_13, net_14, net_15, net_16;
  wire net_17, net_18, net_19, net_20, net_22, net_23, net_24, net_25, net_26;
  wire net_28, net_29, net_31, net_32, net_34, net_40, net_43, net_44, net_48;
  wire net_50, net_52, net_54, net_55, net_56, net_58, net_59, net_60, net_64;
  wire net_67, net_68, net_70, net_71, net_72, net_74, net_75, net_76, net_79;
  wire net_80, rst, stateBit_1_slave, stateBit_5_slaveBar, stateBit_6_slaveBar;
  wire stateBit_9_slaveBar, stateBit_10_slaveBar, stateBit_11_slave;
  wire stateBit_12_slave;
  not (strong0, strong1) #(100) inv_0 (rst, TRSTb);
  not (strong0, strong1) #(100) inv_1 (net_24, net_12);
  redFour__nand2n_X_3_5_Delay_100_drive0_strong0_drive1_strong1 
      nand2n_0(.ina(net_13), .inb(net_14), .out(net_0));
  redFour__nand2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nand2n_1(.ina(net_15), .inb(net_16), .out(net_4));
  redFour__nand2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nand2n_2(.ina(net_17), .inb(net_18), .out(net_2));
  redFour__nand2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nand2n_3(.ina(net_19), .inb(net_20), .out(net_6));
  redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_0(.ina(net_12), .inb(net_23), .out(net_22));
  redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_1(.ina(net_24), .inb(net_26), .out(net_25));
  redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_2(.ina(net_24), .inb(net_29), .out(net_28));
  redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_3(.ina(net_24), .inb(net_32), .out(net_31));
  redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_4(.ina(net_12), .inb(net_26), .out(net_34));
  jtag__o2a o2a_0(.inAa(net_2), .inAb(net_43), .inOb(net_12), .out(net_40));
  jtag__o2a o2a_1(.inAa(net_6), .inAb(net_0), .inOb(net_12), .out(net_44));
  jtag__o2a o2a_2(.inAa(net_50), .inAb(net_0), .inOb(net_24), .out(net_48));
  jtag__o2a o2a_3(.inAa(net_54), .inAb(net_55), .inOb(net_12), .out(net_52));
  jtag__o2a o2a_4(.inAa(net_58), .inAb(net_59), .inOb(net_12), .out(net_56));
  jtag__o2a o2a_5(.inAa(net_58), .inAb(net_43), .inOb(net_24), .out(net_60));
  jtag__o2a o2a_6(.inAa(net_54), .inAb(net_67), .inOb(net_24), .out(net_64));
  jtag__o2a o2a_7(.inAa(net_70), .inAb(net_71), .inOb(net_24), .out(net_68));
  jtag__o2a o2a_8(.inAa(net_74), .inAb(net_75), .inOb(net_24), .out(net_72));
  jtag__o2a o2a_9(.inAa(Reset_s), .inAb(net_79), .inOb(net_24), .out(net_76));
  jtag__o2a o2a_10(.inAa(net_4), .inAb(net_67), .inOb(net_12), .out(net_80));
  jtag__slaveBit slaveBit_0(.din(TMS), .phi2(phi2), .slave(net_12));
  jtag__stateBit stateBit_0(.next(net_25), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(SelIR), .slave(net_79), .slaveBar(net_23));
  jtag__stateBit stateBit_1(.next(net_48), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(SelDR), .slave(stateBit_1_slave), .slaveBar(net_26));
  jtag__stateBit stateBit_2(.next(net_34), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(CapDR), .slave(net_75), .slaveBar(net_16));
  jtag__stateBit stateBit_3(.next(net_22), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(CapIR), .slave(net_71), .slaveBar(net_18));
  jtag__stateBit stateBit_4(.next(net_44), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(Idle), .slave(net_50), .slaveBar(net_20));
  jtag__stateBit stateBit_5(.next(net_68), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(X1IR), .slave(net_58), .slaveBar(stateBit_5_slaveBar));
  jtag__stateBit stateBit_6(.next(net_72), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(X1DR), .slave(net_54), .slaveBar(stateBit_6_slaveBar));
  jtag__stateBit stateBit_7(.next(net_80), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(ShftDR), .slave(net_74), .slaveBar(net_15));
  jtag__stateBit stateBit_8(.next(net_40), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(ShftIR), .slave(net_70), .slaveBar(net_17));
  jtag__stateBit stateBit_9(.next(net_28), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(X2IR), .slave(net_43), .slaveBar(stateBit_9_slaveBar));
  jtag__stateBit stateBit_10(.next(net_31), .phi1(phi1), .phi2(phi2), 
      .rst(rst), .master(X2DR), .slave(net_67), 
      .slaveBar(stateBit_10_slaveBar));
  jtag__stateBit stateBit_11(.next(net_64), .phi1(phi1), .phi2(phi2), 
      .rst(rst), .master(UpdDR), .slave(stateBit_11_slave), 
      .slaveBar(net_14));
  jtag__stateBit stateBit_12(.next(net_60), .phi1(phi1), .phi2(phi2), 
      .rst(rst), .master(UpdIR), .slave(stateBit_12_slave), 
      .slaveBar(net_13));
  jtag__stateBit stateBit_13(.next(net_56), .phi1(phi1), .phi2(phi2), 
      .rst(rst), .master(PauseIR), .slave(net_59), .slaveBar(net_29));
  jtag__stateBit stateBit_14(.next(net_52), .phi1(phi1), .phi2(phi2), 
      .rst(rst), .master(PauseDR), .slave(net_55), .slaveBar(net_32));
  jtag__stateBitHI stateBit_15(.next(net_76), .phi1(phi1), .phi2(phi2), 
      .rstb(TRSTb), .master(Reset), .slave(Reset_s), .slaveBar(net_19));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100 wire180_0(.a(net_4));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100 wire180_1(.a(net_2));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100 wire180_2(.a(net_6));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_675 wire180_3(.a(net_0));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_1500 wire180_4(.a(rst));
endmodule   
module jtag__jtagControl(TCK, TDI, TDIx, TMS, TRSTb, phi1_fb, phi2_fb, Cap, 
      ExTest, SelBS, SelDR, Shft, TDOb, Upd, phi1, phi2);
  input TCK;
  input TDI;
  input TDIx;
  input TMS;
  input TRSTb;
  input phi1_fb;
  input phi2_fb;
  output Cap;
  output ExTest;
  output SelBS;
  output [12:0] SelDR;
  output Shft;
  output TDOb;
  output Upd;
  output phi1;
  output phi2;
  supply1 vdd;
  supply0 gnd;
  wire jtagScan_0_write, net_0, net_1, net_2, net_3, net_6, net_8, net_10;
  wire net_33, net_35, net_37, net_38, net_41, net_47, net_48, net_50, net_51;
  wire net_52, net_55, net_56, net_62, net_64, net_68, net_73, net_75, net_79;
  wire net_97, net_99, net_103, net_128, tapCtlJK_0_Idle, tapCtlJK_0_PauseDR;
  wire tapCtlJK_0_PauseIR, tapCtlJK_0_Reset, tapCtlJK_0_SelDR, tapCtlJK_0_SelIR;
  wire tapCtlJK_0_X1DR, tapCtlJK_0_X2DR, tapCtlJK_0_X2IR;
  wire [8:1] IR;
  wire [8:1] IRb;
  jtag__BR BR_0(.SDI(TDI), .phi1(net_68), .phi2(net_73), .read(net_99), 
      .SDO(net_97));
  jtag__IR IR_0(.SDI(TDI), .phi1(net_79), .phi2(net_75), .read(net_55), 
      .reset(net_56), .write(net_103), .IR(IR[8:1]), .IRb(IRb[8:1]), 
      .SDO(net_128));
  jtag__IRdecode IRdecode_0(.IR(IR[4:1]), .IRb(IRb[4:1]), .Bypass(net_41), 
      .ExTest(ExTest), .SamplePreload(net_47), .ScanPath(SelDR[12:0]));
  redFour__PMOSwk_X_0_222_Delay_100 PMOSwk_0(.g(gnd), .d(TDIx), .s(vdd));
  jtag__clockGen clockGen_0(.clk(TCK), .phi1_fb(phi1_fb), .phi2_fb(phi2_fb), 
      .phi1_out(net_10), .phi2_out(net_8));
  not (strong0, strong1) #(100) inv_0 (net_0, net_3);
  not (strong0, strong1) #(100) inv_1 (SelBS, net_48);
  not (strong0, strong1) #(100) inv_2 (net_6, net_50);
  not (strong0, strong1) #(100) inv_3 (Cap, net_37);
  not (strong0, strong1) #(100) inv_4 (Shft, net_51);
  not (strong0, strong1) #(100) inv_5 (net_51, net_52);
  not (strong0, strong1) #(100) inv_6 (Upd, net_38);
  jtag__jtagIRControl jtagIRCo_0(.capture(net_62), .phi1_fb(net_79), 
      .phi1_in(phi1), .phi2_fb(net_75), .phi2_in(phi2), .shift(net_2), 
      .update(net_64), .phi1_out(net_79), .phi2_out(net_75), .read(net_55), 
      .write(net_103));
  jtag__jtagScanControl jtagScan_0(.TDI(net_97), .capture(Cap), 
      .phi1_fb(net_68), .phi1_in(phi1), .phi2_fb(net_73), .phi2_in(phi2), 
      .sel(net_41), .shift(Shft), .update(gnd), .TDO(TDIx), .phi1_out(net_68), 
      .phi2_out(net_73), .read(net_99), .write(jtagScan_0_write));
  jtag__mux2_phi2 mux2_phi_0(.Din0(TDIx), .Din1(net_128), .phi2(phi2), 
      .sel(net_0), .Dout(net_50));
  nand (strong0, strong1) #(100) nand2_0 (net_37, IR[8], net_35);
  nand (strong0, strong1) #(100) nand2_1 (net_38, IR[7], net_33);
  nor (strong0, strong1) #(100) nor2_0 (net_3, net_1, net_2);
  nor (strong0, strong1) #(100) nor2_1 (net_48, net_47, ExTest);
  jtag__scanAmp1w1648 scanAmp1_0(.in(net_6), .out(TDOb));
  jtag__scanAmp1w1648 scanAmp1_1(.in(net_8), .out(phi2));
  jtag__scanAmp1w1648 scanAmp1_2(.in(net_10), .out(phi1));
  jtag__tapCtlJKL tapCtlJK_0(.TMS(TMS), .TRSTb(TRSTb), .phi1(phi1), 
      .phi2(phi2), .CapDR(net_35), .CapIR(net_62), .Idle(tapCtlJK_0_Idle), 
      .PauseDR(tapCtlJK_0_PauseDR), .PauseIR(tapCtlJK_0_PauseIR), 
      .Reset(tapCtlJK_0_Reset), .Reset_s(net_56), .SelDR(tapCtlJK_0_SelDR), 
      .SelIR(tapCtlJK_0_SelIR), .ShftDR(net_52), .ShftIR(net_2), 
      .UpdDR(net_33), .UpdIR(net_64), .X1DR(tapCtlJK_0_X1DR), .X1IR(net_1), 
      .X2DR(tapCtlJK_0_X2DR), .X2IR(tapCtlJK_0_X2IR));
endmodule   
module jtag__JTAGamp(leaf, root);
  input [8:1] leaf;
  input [5:1] root;
  supply1 vdd;
  supply0 gnd;
  jtag__scanAmp1w1648 toLeaf_5_(.in(root[5]), .out(leaf[5]));
  jtag__scanAmp1w1648 toLeaf_4_(.in(root[4]), .out(leaf[4]));
  jtag__scanAmp1w1648 toLeaf_3_(.in(root[3]), .out(leaf[3]));
  jtag__scanAmp1w1648 toLeaf_2_(.in(root[2]), .out(leaf[2]));
  jtag__scanAmp1w1648 toLeaf_1_(.in(root[1]), .out(leaf[1]));
endmodule   
module jtag__jtagScanCtlWBuf(TDI, cap, phi1, phi2, sel, shift, upd, TDO, 
      leaf);
  input TDI;
  input cap;
  input phi1;
  input phi2;
  input sel;
  input shift;
  input upd;
  output TDO;
  input [8:1] leaf;
  supply1 vdd;
  supply0 gnd;
  wire [5:2] a;
  jtag__JTAGamp JTAGamp_0(.leaf(leaf[8:1]), .root({a[5], a[4], a[3], a[2], 
      TDI}));
  jtag__jtagScanControl jtagScan_0(.TDI(leaf[8]), .capture(cap), 
      .phi1_fb(leaf[6]), .phi1_in(phi1), .phi2_fb(leaf[7]), .phi2_in(phi2), 
      .sel(sel), .shift(shift), .update(upd), .TDO(TDO), .phi1_out(a[3]), 
      .phi2_out(a[2]), .read(a[5]), .write(a[4]));
endmodule   
module jtag__jtagScanCtlGroup(TDI, capture, phi1_in, phi2_in, selBS, sel, 
      shift, update, TDO, BS, leaf0, leaf1, leaf2, leaf3, leaf4, leaf5, leaf6, 
      leaf7, leaf8, leaf9, leaf10, leaf11, leaf12);
  input TDI;
  input capture;
  input phi1_in;
  input phi2_in;
  input selBS;
  input [12:0] sel;
  input shift;
  input update;
  output TDO;
  input [8:1] BS;
  input [8:1] leaf0;
  input [8:1] leaf1;
  input [8:1] leaf2;
  input [8:1] leaf3;
  input [8:1] leaf4;
  input [8:1] leaf5;
  input [8:1] leaf6;
  input [8:1] leaf7;
  input [8:1] leaf8;
  input [8:1] leaf9;
  input [8:1] leaf10;
  input [8:1] leaf11;
  input [8:1] leaf12;
  supply1 vdd;
  supply0 gnd;
  jtag__jtagScanCtlWBuf jtagScan_1(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[0]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf0[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_2(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[10]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf10[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_3(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[12]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf12[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_4(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[11]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf11[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_5(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[9]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf9[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_6(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[8]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf8[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_7(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[6]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf6[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_8(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[5]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf5[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_9(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[4]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf4[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_10(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[3]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf3[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_11(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[2]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf2[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_12(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[1]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf1[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_13(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[7]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf7[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_16(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(selBS), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(BS[8:1]));
endmodule   
module jtag__jtagCentral_LEIGNORE_1(TCK, TDI, TMS, TRSTb, ExTest, TDOb, BS, 
      leaf0, leaf1, leaf2, leaf3, leaf4, leaf5, leaf6, leaf7, leaf8, leaf9, 
      leaf10, leaf11, leaf12);
  input TCK;
  input TDI;
  input TMS;
  input TRSTb;
  output ExTest;
  output TDOb;
  input [8:1] BS;
  input [8:1] leaf0;
  input [8:1] leaf1;
  input [8:1] leaf2;
  input [8:1] leaf3;
  input [8:1] leaf4;
  input [8:1] leaf5;
  input [8:1] leaf6;
  input [8:1] leaf7;
  input [8:1] leaf8;
  input [8:1] leaf9;
  input [8:1] leaf10;
  input [8:1] leaf11;
  input [8:1] leaf12;
  supply1 vdd;
  supply0 gnd;
  wire net_10, net_14, net_15, net_17, net_24, net_25, net_50;
  wire [0:12] net_6;
  jtag__jtagControl jtagCont_0(.TCK(TCK), .TDI(TDI), .TDIx(net_15), .TMS(TMS), 
      .TRSTb(TRSTb), .phi1_fb(net_24), .phi2_fb(net_10), .Cap(net_25), 
      .ExTest(ExTest), .SelBS(net_50), .SelDR({net_6[0], net_6[1], net_6[2], 
      net_6[3], net_6[4], net_6[5], net_6[6], net_6[7], net_6[8], net_6[9], 
      net_6[10], net_6[11], net_6[12]}), .Shft(net_17), .TDOb(TDOb), 
      .Upd(net_14), .phi1(net_24), .phi2(net_10));
  jtag__jtagScanCtlGroup jtagScan_0(.TDI(TDI), .capture(net_25), 
      .phi1_in(net_24), .phi2_in(net_10), .selBS(net_50), .sel({net_6[0], 
      net_6[1], net_6[2], net_6[3], net_6[4], net_6[5], net_6[6], net_6[7], 
      net_6[8], net_6[9], net_6[10], net_6[11], net_6[12]}), .shift(net_17), 
      .update(net_14), .TDO(net_15), .BS(BS[8:1]), .leaf0(leaf0[8:1]), 
      .leaf1(leaf1[8:1]), .leaf2(leaf2[8:1]), .leaf3(leaf3[8:1]), 
      .leaf4(leaf4[8:1]), .leaf5(leaf5[8:1]), .leaf6(leaf6[8:1]), 
      .leaf7(leaf7[8:1]), .leaf8(leaf8[8:1]), .leaf9(leaf9[8:1]), 
      .leaf10(leaf10[8:1]), .leaf11(leaf11[8:1]), .leaf12(leaf12[8:1]));
endmodule   
module scanFansFour__jtag_endcap(jtag);
  input [8:4] jtag;
endmodule   
module testCell(TCK, TDI, TMS, TRSTb, TDOb);
  input TCK;
  input TDI;
  input TMS;
  input TRSTb;
  output TDOb;
  supply1 vdd;
  supply0 gnd;
  wire jtagCent_0_ExTest;
  wire [4:0] net_5;
  wire [4:0] net_6;
  wire [4:0] net_7;
  wire [4:0] net_8;
  wire [4:0] net_9;
  wire [4:0] net_10;
  wire [4:0] net_11;
  wire [4:0] net_12;
  wire [4:0] net_13;
  wire [4:0] net_14;
  wire [4:0] net_15;
  wire [4:0] net_16;
  wire [4:0] net_17;
  wire [4:0] net_18;
  jtag__jtagCentral_LEIGNORE_1 jtagCent_0(.TCK(TCK), .TDI(TDI), .TMS(TMS), 
      .TRSTb(TRSTb), .ExTest(jtagCent_0_ExTest), .TDOb(TDOb), .BS({net_6[0], 
      net_6[1], net_6[2], net_6[3], net_6[4], net_6[2], net_6[1], net_6[0]}), 
      .leaf0({net_7[0], net_7[1], net_7[2], net_7[3], net_7[4], net_7[2], 
      net_7[1], net_7[0]}), .leaf1({net_18[0], net_18[1], net_18[2], net_18[3], 
      net_18[4], net_18[2], net_18[1], net_18[0]}), .leaf2({net_17[0], 
      net_17[1], net_17[2], net_17[3], net_17[4], net_17[2], net_17[1], 
      net_17[0]}), .leaf3({net_16[0], net_16[1], net_16[2], net_16[3], 
      net_16[4], net_16[2], net_16[1], net_16[0]}), .leaf4({net_15[0], 
      net_15[1], net_15[2], net_15[3], net_15[4], net_15[2], net_15[1], 
      net_15[0]}), .leaf5({net_14[0], net_14[1], net_14[2], net_14[3], 
      net_14[4], net_14[2], net_14[1], net_14[0]}), .leaf6({net_13[0], 
      net_13[1], net_13[2], net_13[3], net_13[4], net_13[2], net_13[1], 
      net_13[0]}), .leaf7({net_12[0], net_12[1], net_12[2], net_12[3], 
      net_12[4], net_12[2], net_12[1], net_12[0]}), .leaf8({net_11[0], 
      net_11[1], net_11[2], net_11[3], net_11[4], net_11[2], net_11[1], 
      net_11[0]}), .leaf9({net_10[0], net_10[1], net_10[2], net_10[3], 
      net_10[4], net_10[2], net_10[1], net_10[0]}), .leaf10({net_9[0], 
      net_9[1], net_9[2], net_9[3], net_9[4], net_9[2], net_9[1], net_9[0]}), 
      .leaf11({net_8[0], net_8[1], net_8[2], net_8[3], net_8[4], net_8[2], 
      net_8[1], net_8[0]}), .leaf12({net_5[0], net_5[1], net_5[2], net_5[3], 
      net_5[4], net_5[2], net_5[1], net_5[0]}));
  scanFansFour__jtag_endcap jtag_end_0(.jtag({net_5[0], net_5[1], net_5[2], 
      net_5[4], net_5[3]}));
  scanFansFour__jtag_endcap jtag_end_1(.jtag({net_8[0], net_8[1], net_8[2], 
      net_8[4], net_8[3]}));
  scanFansFour__jtag_endcap jtag_end_2(.jtag({net_9[0], net_9[1], net_9[2], 
      net_9[4], net_9[3]}));
  scanFansFour__jtag_endcap jtag_end_3(.jtag({net_10[0], net_10[1], net_10[2], 
      net_10[4], net_10[3]}));
  scanFansFour__jtag_endcap jtag_end_4(.jtag({net_11[0], net_11[1], net_11[2], 
      net_11[4], net_11[3]}));
  scanFansFour__jtag_endcap jtag_end_5(.jtag({net_12[0], net_12[1], net_12[2], 
      net_12[4], net_12[3]}));
  scanFansFour__jtag_endcap jtag_end_6(.jtag({net_13[0], net_13[1], net_13[2], 
      net_13[4], net_13[3]}));
  scanFansFour__jtag_endcap jtag_end_7(.jtag({net_14[0], net_14[1], net_14[2], 
      net_14[4], net_14[3]}));
  scanFansFour__jtag_endcap jtag_end_8(.jtag({net_15[0], net_15[1], net_15[2], 
      net_15[4], net_15[3]}));
  scanFansFour__jtag_endcap jtag_end_9(.jtag({net_16[0], net_16[1], net_16[2], 
      net_16[4], net_16[3]}));
  scanFansFour__jtag_endcap jtag_end_10(.jtag({net_17[0], net_17[1], net_17[2], 
      net_17[4], net_17[3]}));
  scanFansFour__jtag_endcap jtag_end_11(.jtag({net_18[0], net_18[1], net_18[2], 
      net_18[4], net_18[3]}));
  scanFansFour__jtag_endcap jtag_end_12(.jtag({net_7[0], net_7[1], net_7[2], 
      net_7[4], net_7[3]}));
  scanFansFour__jtag_endcap jtag_end_13(.jtag({net_6[0], net_6[1], net_6[2], 
      net_6[4], net_6[3]}));
endmodule   
(** * Basics: Functional Programming in Coq *)
(*
   [Admitted] is Coq's "escape hatch" that says accept this definition
   without proof.  We use it to mark the 'holes' in the development
   that should be completed as part of your homework exercises.  In
   practice, [Admitted] is useful when you're incrementally developing
   large proofs. *)
Definition admit {T: Type} : T.  Admitted.
(* ###################################################################### *)
(** * Introduction *)
(** The functional programming style brings programming closer to
    simple, everyday mathematics: If a procedure or method has no side
    effects, then pretty much all you need to understand about it is
    how it maps inputs to outputs -- that is, you can think of it as
    just a concrete method for computing a mathematical function.
    This is one sense of the word "functional" in "functional
    programming."  The direct connection between programs and simple
    mathematical objects supports both formal proofs of correctness
    and sound informal reasoning about program behavior.
    The other sense in which functional programming is "functional" is
    that it emphasizes the use of functions (or methods) as
    _first-class_ values -- i.e., values that can be passed as
    arguments to other functions, returned as results, stored in data
    structures, etc.  The recognition that functions can be treated as
    data in this way enables a host of useful and powerful idioms.
    Other common features of functional languages include _algebraic
    data types_ and _pattern matching_, which make it easy to construct
    and manipulate rich data structures, and sophisticated
    _polymorphic type systems_ that support abstraction and code
    reuse.  Coq shares all of these features.
    The first half of this chapter introduces the most essential
    elements of Coq's functional programming language.  The second
    half introduces some basic _tactics_ that can be used to prove
    simple properties of Coq programs.
*)
(* ###################################################################### *)
(** * Enumerated Types *)
(** One unusual aspect of Coq is that its set of built-in
    features is _extremely_ small.  For example, instead of providing
    the usual palette of atomic data types (booleans, integers,
    strings, etc.), Coq offers an extremely powerful mechanism for
    defining new data types from scratch -- so powerful that all these
    familiar types arise as instances.  
    Naturally, the Coq distribution comes with an extensive standard
    library providing definitions of booleans, numbers, and many
    common data structures like lists and hash tables.  But there is
    nothing magic or primitive about these library definitions: they
    are ordinary user code.  To illustrate this, we will explicitly
    recapitulate all the definitions we need in this course, rather
    than just getting them implicitly from the library.
    To see how this mechanism works, let's start with a very simple
    example. *)
(* ###################################################################### *)
(** ** Days of the Week *)
(** The following declaration tells Coq that we are defining
    a new set of data values -- a _type_. *)
Inductive day : Type :=
  | monday : day
  | tuesday : day
  | wednesday : day
  | thursday : day
  | friday : day
  | saturday : day
  | sunday : day.
(** The type is called [day], and its members are [monday],
    [tuesday], etc.  The second and following lines of the definition
    can be read "[monday] is a [day], [tuesday] is a [day], etc."
    Having defined [day], we can write functions that operate on
    days. *)
Definition next_weekday (d:day) : day :=
  match d with
  | monday    => tuesday
  | tuesday   => wednesday
  | wednesday => thursday
  | thursday  => friday
  | friday    => monday
  | saturday  => monday
  | sunday    => monday
  end.
(** One thing to note is that the argument and return types of
    this function are explicitly declared.  Like most functional
    programming languages, Coq can often figure out these types for
    itself when they are not given explicitly -- i.e., it performs
    some _type inference_ -- but we'll always include them to make
    reading easier. *)
(** Having defined a function, we should check that it works on
    some examples.  There are actually three different ways to do this
    in Coq.  
    First, we can use the command [Eval compute] to evaluate a
    compound expression involving [next_weekday].  *)
Eval compute in (next_weekday friday).
   (* ==> monday : day *)
Eval compute in (next_weekday (next_weekday saturday)).
   (* ==> tuesday : day *)
(** If you have a computer handy, this would be an excellent
    moment to fire up the Coq interpreter under your favorite IDE --
    either CoqIde or Proof General -- and try this for yourself.  Load
    this file ([Basics.v]) from the book's accompanying Coq sources,
    find the above example, submit it to Coq, and observe the
    result. *)
(** The keyword [compute] tells Coq precisely how to
    evaluate the expression we give it.  For the moment, [compute] is
    the only one we'll need; later on we'll see some alternatives that
    are sometimes useful. *)
(** Second, we can record what we _expect_ the result to be in
    the form of a Coq example: *)
Example test_next_weekday:
  (next_weekday (next_weekday saturday)) = tuesday.
(** This declaration does two things: it makes an
    assertion (that the second weekday after [saturday] is [tuesday]),
    and it gives the assertion a name that can be used to refer to it
    later. *)
(** Having made the assertion, we can also ask Coq to verify it,
    like this: *)
Proof. simpl. reflexivity.  Qed.
(** The details are not important for now (we'll come back to
    them in a bit), but essentially this can be read as "The assertion
    we've just made can be proved by observing that both sides of the
    equality evaluate to the same thing, after some simplification." *)
(** Third, we can ask Coq to _extract_, from our [Definition], a
    program in some other, more conventional, programming
    language (OCaml, Scheme, or Haskell) with a high-performance
    compiler.  This facility is very interesting, since it gives us a
    way to construct _fully certified_ programs in mainstream
    languages.  Indeed, this is one of the main uses for which Coq was
    developed.  We'll come back to this topic in later chapters.  More
    information can also be found in the Coq'Art book by Bertot and
    Casteran, as well as the Coq reference manual. *)
(* ###################################################################### *)
(** ** Booleans *)
(** In a similar way, we can define the standard type [bool] of
    booleans, with members [true] and [false]. *)
Inductive bool : Type :=
  | true : bool
  | false : bool.
(** Although we are rolling our own booleans here for the sake
    of building up everything from scratch, Coq does, of course,
    provide a default implementation of the booleans in its standard
    library, together with a multitude of useful functions and
    lemmas.  (Take a look at [Coq.Init.Datatypes] in the Coq library
    documentation if you're interested.)  Whenever possible, we'll
    name our own definitions and theorems so that they exactly
    coincide with the ones in the standard library. *)
(** Functions over booleans can be defined in the same way as
    above: *)
Definition negb (b:bool) : bool := 
  match b with
  | true => false
  | false => true
  end.
Definition andb (b1:bool) (b2:bool) : bool := 
  match b1 with 
  | true => b2 
  | false => false
  end.
Definition orb (b1:bool) (b2:bool) : bool := 
  match b1 with 
  | true => true
  | false => b2
  end.
(** The last two illustrate the syntax for multi-argument
    function definitions. *)
(** The following four "unit tests" constitute a complete
    specification -- a truth table -- for the [orb] function: *)
Example test_orb1:  (orb true  false) = true. 
Proof. reflexivity.  Qed.
Example test_orb2:  (orb false false) = false.
Proof. reflexivity.  Qed.
Example test_orb3:  (orb false true)  = true.
Proof. reflexivity.  Qed.
Example test_orb4:  (orb true  true)  = true.
Proof. reflexivity.  Qed.
(** (Note that we've dropped the [simpl] in the proofs.  It's not
    actually needed because [reflexivity] automatically performs
    simplification.) *)
(** _A note on notation_: In .v files, we use square brackets to
    delimit fragments of Coq code within comments; this convention,
    also used by the [coqdoc] documentation tool, keeps them visually
    separate from the surrounding text.  In the html version of the
    files, these pieces of text appear in a [different font]. *)
(** The values [Admitted] and [admit] can be used to fill
    a hole in an incomplete definition or proof.  We'll use them in the
    following exercises.  In general, your job in the exercises is 
    to replace [admit] or [Admitted] with real definitions or proofs. *)
(** **** Exercise: 1 star (nandb)  *)
(** Complete the definition of the following function, then make
    sure that the [Example] assertions below can each be verified by
    Coq.  *)
(** This function should return [true] if either or both of
    its inputs are [false]. *)
Definition nandb (b1:bool) (b2:bool) : bool :=
  negb (andb b1 b2).
(** Remove "[Admitted.]" and fill in each proof with 
    "[Proof. reflexivity. Qed.]" *)
Example test_nandb1:               (nandb true false) = true.
Proof. reflexivity. Qed.
Example test_nandb2:               (nandb false false) = true.
Proof. reflexivity. Qed.
Example test_nandb3:               (nandb false true) = true.
Proof. reflexivity. Qed.
Example test_nandb4:               (nandb true true) = false.
Proof. reflexivity. Qed.
(** [] *)
(** **** Exercise: 1 star (andb3)  *)
(** Do the same for the [andb3] function below. This function should
    return [true] when all of its inputs are [true], and [false]
    otherwise. *)
Definition andb3 (b1:bool) (b2:bool) (b3:bool) : bool :=
  andb (andb b1 b2) b3.
Example test_andb31:                 (andb3 true true true) = true.
Proof. reflexivity. Qed.
Example test_andb32:                 (andb3 false true true) = false.
Proof. reflexivity. Qed.
Example test_andb33:                 (andb3 true false true) = false.
Proof. reflexivity. Qed.
Example test_andb34:                 (andb3 true true false) = false.
Proof. reflexivity. Qed.
(** [] *)
(* ###################################################################### *)
(** ** Function Types *)
(** The [Check] command causes Coq to print the type of an
    expression.  For example, the type of [negb true] is [bool]. *)
Check true.
(* ===> true : bool *)
Check (negb true).
(* ===> negb true : bool *)
(** Functions like [negb] itself are also data values, just like
    [true] and [false].  Their types are called _function types_, and
    they are written with arrows. *)
Check negb.
(* ===> negb : bool -> bool *)
(** The type of [negb], written [bool -> bool] and pronounced
    "[bool] arrow [bool]," can be read, "Given an input of type
    [bool], this function produces an output of type [bool]."
    Similarly, the type of [andb], written [bool -> bool -> bool], can
    be read, "Given two inputs, both of type [bool], this function
    produces an output of type [bool]." *)
(* ###################################################################### *)
(** ** Numbers *)
(** _Technical digression_: Coq provides a fairly sophisticated
    _module system_, to aid in organizing large developments.  In this
    course we won't need most of its features, but one is useful: If
    we enclose a collection of declarations between [Module X] and
    [End X] markers, then, in the remainder of the file after the
    [End], these definitions will be referred to by names like [X.foo]
    instead of just [foo].  Here, we use this feature to introduce the
    definition of the type [nat] in an inner module so that it does
    not shadow the one from the standard library. *)
Module Playground1.
(** The types we have defined so far are examples of "enumerated
    types": their definitions explicitly enumerate a finite set of
    elements.  A more interesting way of defining a type is to give a
    collection of "inductive rules" describing its elements.  For
    example, we can define the natural numbers as follows: *)
Inductive nat : Type :=
  | O : nat
  | S : nat -> nat.
(** The clauses of this definition can be read: 
      - [O] is a natural number (note that this is the letter "[O]," not
        the numeral "[0]").
      - [S] is a "constructor" that takes a natural number and yields
        another one -- that is, if [n] is a natural number, then [S n]
        is too.
    Let's look at this in a little more detail.  
    Every inductively defined set ([day], [nat], [bool], etc.) is
    actually a set of _expressions_.  The definition of [nat] says how
    expressions in the set [nat] can be constructed:
    - the expression [O] belongs to the set [nat]; 
    - if [n] is an expression belonging to the set [nat], then [S n]
      is also an expression belonging to the set [nat]; and
    - expressions formed in these two ways are the only ones belonging
      to the set [nat].
    The same rules apply for our definitions of [day] and [bool]. The
    annotations we used for their constructors are analogous to the
    one for the [O] constructor, and indicate that each of those
    constructors doesn't take any arguments. *)
(** These three conditions are the precise force of the
    [Inductive] declaration.  They imply that the expression [O], the
    expression [S O], the expression [S (S O)], the expression
    [S (S (S O))], and so on all belong to the set [nat], while other
    expressions like [true], [andb true false], and [S (S false)] do
    not.
    We can write simple functions that pattern match on natural
    numbers just as we did above -- for example, the predecessor
    function: *)
Definition pred (n : nat) : nat :=
  match n with
    | O => O
    | S n' => n'
  end.
(** The second branch can be read: "if [n] has the form [S n']
    for some [n'], then return [n']."  *)
End Playground1.
Definition minustwo (n : nat) : nat :=
  match n with
    | O => O
    | S O => O
    | S (S n') => n'
  end.
(** Because natural numbers are such a pervasive form of data,
    Coq provides a tiny bit of built-in magic for parsing and printing
    them: ordinary arabic numerals can be used as an alternative to
    the "unary" notation defined by the constructors [S] and [O].  Coq
    prints numbers in arabic form by default: *)
Check (S (S (S (S O)))).
Eval compute in (minustwo 4).
(** The constructor [S] has the type [nat -> nat], just like the
    functions [minustwo] and [pred]: *)
Check S.
Check pred.
Check minustwo.
(** These are all things that can be applied to a number to yield a
    number.  However, there is a fundamental difference: functions
    like [pred] and [minustwo] come with _computation rules_ -- e.g.,
    the definition of [pred] says that [pred 2] can be simplified to
    [1] -- while the definition of [S] has no such behavior attached.
    Although it is like a function in the sense that it can be applied
    to an argument, it does not _do_ anything at all! *)
(** For most function definitions over numbers, pure pattern
    matching is not enough: we also need recursion.  For example, to
    check that a number [n] is even, we may need to recursively check
    whether [n-2] is even.  To write such functions, we use the
    keyword [Fixpoint]. *)
Fixpoint evenb (n:nat) : bool :=
  match n with
  | O        => true
  | S O      => false
  | S (S n') => evenb n'
  end.
(** We can define [oddb] by a similar [Fixpoint] declaration, but here
    is a simpler definition that will be a bit easier to work with: *)
Definition oddb (n:nat) : bool   :=   negb (evenb n).
Example test_oddb1:    (oddb (S O)) = true.
Proof. reflexivity.  Qed.
Example test_oddb2:    (oddb (S (S (S (S O))))) = false.
Proof. reflexivity.  Qed.
(** Naturally, we can also define multi-argument functions by
    recursion.  (Once again, we use a module to avoid polluting the
    namespace.) *)
Module Playground2.
Fixpoint plus (n : nat) (m : nat) : nat :=
  match n with
    | O => m
    | S n' => S (plus n' m)
  end.
(** Adding three to two now gives us five, as we'd expect. *)
Eval compute in (plus (S (S (S O))) (S (S O))).
(** The simplification that Coq performs to reach this conclusion can
    be visualized as follows: *)
(*  [plus (S (S (S O))) (S (S O))]    
==> [S (plus (S (S O)) (S (S O)))] by the second clause of the [match]
==> [S (S (plus (S O) (S (S O))))] by the second clause of the [match]
==> [S (S (S (plus O (S (S O)))))] by the second clause of the [match]
==> [S (S (S (S (S O))))]          by the first clause of the [match]
*)
(** As a notational convenience, if two or more arguments have
    the same type, they can be written together.  In the following
    definition, [(n m : nat)] means just the same as if we had written
    [(n : nat) (m : nat)]. *)
Fixpoint mult (n m : nat) : nat :=
  match n with
    | O => O
    | S n' => plus m (mult n' m)
  end.
Example test_mult1: (mult 3 3) = 9.
Proof. reflexivity.  Qed.
(** You can match two expressions at once by putting a comma
    between them: *)
Fixpoint minus (n m:nat) : nat :=
  match n, m with
  | O   , _    => O
  | S _ , O    => n
  | S n', S m' => minus n' m'
  end.
(** The _ in the first line is a _wildcard pattern_.  Writing _ in a
    pattern is the same as writing some variable that doesn't get used
    on the right-hand side.  This avoids the need to invent a bogus
    variable name. *)
End Playground2.
Fixpoint exp (base power : nat) : nat :=
  match power with
    | O => S O
    | S p => mult base (exp base p)
  end.
(** **** Exercise: 1 star (factorial)  *)
(** Recall the standard factorial function:
<<
    factorial(0)  =  1 
    factorial(n)  =  n * factorial(n-1)     (if n>0)
>>
    Translate this into Coq. *)
Fixpoint factorial (n:nat) : nat :=
  match n with
    | O => 1
    | S n' => mult n (factorial n')
  end.
Example test_factorial1:          (factorial 3) = 6.
Proof. reflexivity. Qed.
Example test_factorial2:          (factorial 5) = (mult 10 12).
Proof. reflexivity. Qed.
(** [] *)
(** We can make numerical expressions a little easier to read and
    write by introducing "notations" for addition, multiplication, and
    subtraction. *)
Notation "x + y" := (plus x y)  
                       (at level 50, left associativity) 
                       : nat_scope.
Notation "x - y" := (minus x y)  
                       (at level 50, left associativity) 
                       : nat_scope.
Notation "x * y" := (mult x y)  
                       (at level 40, left associativity) 
                       : nat_scope.
Check ((0 + 1) + 1).
(** (The [level], [associativity], and [nat_scope] annotations
   control how these notations are treated by Coq's parser.  The
   details are not important, but interested readers can refer to the
   "More on Notation" subsection in the "Advanced Material" section at
   the end of this chapter.) *)
(** Note that these do not change the definitions we've already
    made: they are simply instructions to the Coq parser to accept [x
    + y] in place of [plus x y] and, conversely, to the Coq
    pretty-printer to display [plus x y] as [x + y]. *)
(** When we say that Coq comes with nothing built-in, we really
    mean it: even equality testing for numbers is a user-defined
    operation! *)
(** The [beq_nat] function tests [nat]ural numbers for [eq]uality,
    yielding a [b]oolean.  Note the use of nested [match]es (we could
    also have used a simultaneous match, as we did in [minus].)  *)
Fixpoint beq_nat (n m : nat) : bool :=
  match n with
  | O => match m with
         | O => true
         | S m' => false
         end
  | S n' => match m with
            | O => false
            | S m' => beq_nat n' m'
            end
  end.
(** Similarly, the [ble_nat] function tests [nat]ural numbers for
    [l]ess-or-[e]qual, yielding a [b]oolean. *)
Fixpoint ble_nat (n m : nat) : bool :=
  match n with
  | O => true
  | S n' =>
      match m with
      | O => false
      | S m' => ble_nat n' m'
      end
  end.
Example test_ble_nat1:             (ble_nat 2 2) = true.
Proof. reflexivity.  Qed.
Example test_ble_nat2:             (ble_nat 2 4) = true.
Proof. reflexivity.  Qed.
Example test_ble_nat3:             (ble_nat 4 2) = false.
Proof. reflexivity.  Qed.
(** **** Exercise: 2 stars (blt_nat)  *)
(** The [blt_nat] function tests [nat]ural numbers for [l]ess-[t]han,
    yielding a [b]oolean.  Instead of making up a new [Fixpoint] for
    this one, define it in terms of a previously defined function. *)
Definition blt_nat (n m : nat) : bool :=
  ble_nat (S n) m.
Example test_blt_nat1:             (blt_nat 2 2) = false.
Proof. reflexivity. Qed.
Example test_blt_nat2:             (blt_nat 2 4) = true.
Proof. reflexivity. Qed.
Example test_blt_nat3:             (blt_nat 4 2) = false.
Proof. reflexivity. Qed.
(** [] *)
(* ###################################################################### *)
(** * Proof by Simplification *)
(** Now that we've defined a few datatypes and functions, let's
    turn to the question of how to state and prove properties of their
    behavior.  Actually, in a sense, we've already started doing this:
    each [Example] in the previous sections makes a precise claim
    about the behavior of some function on some particular inputs.
    The proofs of these claims were always the same: use [reflexivity] 
    to check that both sides of the [=] simplify to identical values. 
    (By the way, it will be useful later to know that
    [reflexivity] actually does somewhat more simplification than [simpl] 
    does -- for example, it tries "unfolding" defined terms, replacing them with
    their right-hand sides.  The reason for this difference is that,
    when reflexivity succeeds, the whole goal is finished and we don't
    need to look at whatever expanded expressions [reflexivity] has
    found; by contrast, [simpl] is used in situations where we may
    have to read and understand the new goal, so we would not want it
    blindly expanding definitions.) 
    The same sort of "proof by simplification" can be used to prove
    more interesting properties as well.  For example, the fact that
    [0] is a "neutral element" for [+] on the left can be proved
    just by observing that [0 + n] reduces to [n] no matter what
    [n] is, a fact that can be read directly off the definition of [plus].*)
Theorem plus_O_n : forall n : nat, 0 + n = n.
Proof.
  intros n. reflexivity.  Qed.
(** (_Note_: You may notice that the above statement looks
    different in the original source file and the final html output. In Coq
    files, we write the [forall] universal quantifier using the
    "_forall_" reserved identifier. This gets printed as an
    upside-down "A", the familiar symbol used in logic.)  *)
(** The form of this theorem and proof are almost exactly the
    same as the examples above; there are just a few differences.
    First, we've used the keyword [Theorem] instead of
    [Example].  Indeed, the difference is purely a matter of
    style; the keywords [Example] and [Theorem] (and a few others,
    including [Lemma], [Fact], and [Remark]) mean exactly the same
    thing to Coq.
    Secondly, we've added the quantifier [forall n:nat], so that our
    theorem talks about _all_ natural numbers [n].  In order to prove
    theorems of this form, we need to to be able to reason by
    _assuming_ the existence of an arbitrary natural number [n].  This
    is achieved in the proof by [intros n], which moves the quantifier
    from the goal to a "context" of current assumptions. In effect, we
    start the proof by saying "OK, suppose [n] is some arbitrary number."
    The keywords [intros], [simpl], and [reflexivity] are examples of
    _tactics_.  A tactic is a command that is used between [Proof] and
    [Qed] to tell Coq how it should check the correctness of some
    claim we are making.  We will see several more tactics in the rest
    of this lecture, and yet more in future lectures. *)
(** We could try to prove a similar theorem about [plus] *)
Theorem plus_n_O : forall n, n + 0 = n.
(** However, unlike the previous proof, [simpl] doesn't do anything in
    this case *)
Proof.
  simpl. (* Doesn't do anything! *)
Abort.
(** (Can you explain why this happens?  Step through both proofs with
    Coq and notice how the goal and context change.) *)
Theorem plus_1_l : forall n:nat, 1 + n = S n. 
Proof.
  intros n. reflexivity.  Qed.
Theorem mult_0_l : forall n:nat, 0 * n = 0.
Proof.
  intros n. reflexivity.  Qed.
(** The [_l] suffix in the names of these theorems is
    pronounced "on the left." *)
(* ###################################################################### *)
(** * Proof by Rewriting *)
(** Here is a slightly more interesting theorem: *)
Theorem plus_id_example : forall n m:nat,
  n = m -> 
  n + n = m + m.
(** Instead of making a completely universal claim about all numbers
    [n] and [m], this theorem talks about a more specialized property
    that only holds when [n = m].  The arrow symbol is pronounced
    "implies."
    As before, we need to be able to reason by assuming the existence
    of some numbers [n] and [m].  We also need to assume the hypothesis
    [n = m]. The [intros] tactic will serve to move all three of these
    from the goal into assumptions in the current context. 
    Since [n] and [m] are arbitrary numbers, we can't just use
    simplification to prove this theorem.  Instead, we prove it by
    observing that, if we are assuming [n = m], then we can replace
    [n] with [m] in the goal statement and obtain an equality with the
    same expression on both sides.  The tactic that tells Coq to
    perform this replacement is called [rewrite]. *)
Proof.
  intros n m.   (* move both quantifiers into the context *)
  intros H.     (* move the hypothesis into the context *)
  rewrite -> H. (* Rewrite the goal using the hypothesis *)
  reflexivity.  Qed.
(** The first line of the proof moves the universally quantified
    variables [n] and [m] into the context.  The second moves the
    hypothesis [n = m] into the context and gives it the (arbitrary)
    name [H].  The third tells Coq to rewrite the current goal ([n + n
    = m + m]) by replacing the/ left side of the equality hypothesis
    [H] with the right side.
    (The arrow symbol in the [rewrite] has nothing to do with
    implication: it tells Coq to apply the rewrite from left to right.
    To rewrite from right to left, you can use [rewrite <-].  Try
    making this change in the above proof and see what difference it
    makes in Coq's behavior.) *)
(** **** Exercise: 1 star (plus_id_exercise)  *)
(** Remove "[Admitted.]" and fill in the proof. *)
Theorem plus_id_exercise : forall n m o : nat,
  n = m -> m = o -> n + m = m + o.
Proof.
  intros n m o H1 H2.
  rewrite H1. rewrite <- H2.
  reflexivity.
Qed.
(** [] *)
(** As we've seen in earlier examples, the [Admitted] command
    tells Coq that we want to skip trying to prove this theorem and
    just accept it as a given.  This can be useful for developing
    longer proofs, since we can state subsidiary facts that we believe
    will be useful for making some larger argument, use [Admitted] to
    accept them on faith for the moment, and continue thinking about
    the larger argument until we are sure it makes sense; then we can
    go back and fill in the proofs we skipped.  Be careful, though:
    every time you say [Admitted] (or [admit]) you are leaving a door
    open for total nonsense to enter Coq's nice, rigorous, formally
    checked world! *)
(** We can also use the [rewrite] tactic with a previously proved
    theorem instead of a hypothesis from the context. *)
Theorem mult_0_plus : forall n m : nat,
  (0 + n) * m = n * m.
Proof.
  intros n m.
  rewrite -> plus_O_n.
  reflexivity.  Qed.
(** **** Exercise: 2 stars (mult_S_1)  *)
Theorem mult_S_1 : forall n m : nat,
  m = S n -> 
  m * (1 + n) = m * m.
Proof.
  intros n m H. simpl. rewrite <- H.
  reflexivity.
Qed.
(** [] *)
(* ###################################################################### *)
(** * Proof by Case Analysis *) 
(** Of course, not everything can be proved by simple
    calculation: In general, unknown, hypothetical values (arbitrary
    numbers, booleans, lists, etc.) can block the calculation.  
    For example, if we try to prove the following fact using the 
    [simpl] tactic as above, we get stuck. *)
Theorem plus_1_neq_0_firsttry : forall n : nat,
  beq_nat (n + 1) 0 = false.
Proof.
  intros n. 
  simpl.  (* does nothing! *)
Abort.
(** The reason for this is that the definitions of both
    [beq_nat] and [+] begin by performing a [match] on their first
    argument.  But here, the first argument to [+] is the unknown
    number [n] and the argument to [beq_nat] is the compound
    expression [n + 1]; neither can be simplified.
    What we need is to be able to consider the possible forms of [n]
    separately.  If [n] is [O], then we can calculate the final result
    of [beq_nat (n + 1) 0] and check that it is, indeed, [false].
    And if [n = S n'] for some [n'], then, although we don't know
    exactly what number [n + 1] yields, we can calculate that, at
    least, it will begin with one [S], and this is enough to calculate
    that, again, [beq_nat (n + 1) 0] will yield [false].
    The tactic that tells Coq to consider, separately, the cases where
    [n = O] and where [n = S n'] is called [destruct]. *)
Theorem plus_1_neq_0 : forall n : nat,
  beq_nat (n + 1) 0 = false.
Proof.
  intros n. destruct n as [| n'].
    reflexivity.
    reflexivity.  Qed.
(** The [destruct] generates _two_ subgoals, which we must then
    prove, separately, in order to get Coq to accept the theorem as
    proved.  (No special command is needed for moving from one subgoal
    to the other.  When the first subgoal has been proved, it just
    disappears and we are left with the other "in focus.")  In this
    proof, each of the subgoals is easily proved by a single use of
    [reflexivity].
    The annotation "[as [| n']]" is called an _intro pattern_.  It
    tells Coq what variable names to introduce in each subgoal.  In
    general, what goes between the square brackets is a _list_ of
    lists of names, separated by [|].  Here, the first component is
    empty, since the [O] constructor is nullary (it doesn't carry any
    data).  The second component gives a single name, [n'], since [S]
    is a unary constructor.
    The [destruct] tactic can be used with any inductively defined
    datatype.  For example, we use it here to prove that boolean
    negation is involutive -- i.e., that negation is its own
    inverse. *)
Theorem negb_involutive : forall b : bool,
  negb (negb b) = b.
Proof.
  intros b. destruct b.
    reflexivity.
    reflexivity.  Qed.
(** Note that the [destruct] here has no [as] clause because
    none of the subcases of the [destruct] need to bind any variables,
    so there is no need to specify any names.  (We could also have
    written [as [|]], or [as []].)  In fact, we can omit the [as]
    clause from _any_ [destruct] and Coq will fill in variable names
    automatically.  Although this is convenient, it is arguably bad
    style, since Coq often makes confusing choices of names when left
    to its own devices. *)
(** **** Exercise: 1 star (zero_nbeq_plus_1)  *)
Theorem zero_nbeq_plus_1 : forall n : nat,
  beq_nat 0 (n + 1) = false.
Proof.
  intros n.
  destruct n as [| n'].
  simpl. reflexivity.
  simpl. reflexivity.
Qed.
(** [] *)
(* ###################################################################### *)
(** * More Exercises *)
(** **** Exercise: 2 stars (boolean_functions)  *)
(** Use the tactics you have learned so far to prove the following 
    theorem about boolean functions. *)
Theorem identity_fn_applied_twice : 
  forall (f : bool -> bool), 
  (forall (x : bool), f x = x) ->
  forall (b : bool), f (f b) = b.
Proof.
  intros f H b.
  rewrite H. rewrite H. reflexivity.
Qed.
(** Now state and prove a theorem [negation_fn_applied_twice] similar
    to the previous one but where the second hypothesis says that the
    function [f] has the property that [f x = negb x].*)
Theorem negation_fn_applied_twice :
  forall (f : bool -> bool),
    (forall (x : bool), f x = negb x) ->
    forall (b : bool), f (f b) = b.
Proof.
  intros f H b.
  rewrite H. rewrite H.
  rewrite negb_involutive.
  reflexivity.
Qed.
(** [] *)
(** **** Exercise: 2 stars (andb_eq_orb)  *)
(** Prove the following theorem.  (You may want to first prove a
    subsidiary lemma or two. Alternatively, remember that you do
    not have to introduce all hypotheses at the same time.) *)
Lemma andb_true :
  forall (b : bool),
    andb b true = true -> b = true.
Proof.
  intros b H.
  destruct b. reflexivity.
  inversion H.
Qed.
Lemma orb_true :
  forall (b : bool),
    orb b true = true.
Proof.
  intros b. destruct b; reflexivity.
Qed.
Lemma andb_true_b :
  forall (b : bool),
    andb b true = b.
Proof.
  intros b.
  destruct b; reflexivity.
Qed.
Lemma orb_false_b :
  forall (b : bool),
    orb b false = b.
Proof.
  intros b. destruct b; reflexivity.
Qed.
Theorem andb_false :
  forall (b : bool),
    andb b false = false.
Proof.
  intros b. destruct b ; reflexivity.
Qed.
Theorem andb_eq_orb : 
  forall (b c : bool),
  (andb b c = orb b c) ->
  b = c.
Proof.
  intros b c H.
  destruct c.
  rewrite <- orb_true with (b := b).
  rewrite <- H. rewrite andb_true_b. reflexivity.
  rewrite <- andb_false with (b := b).
  rewrite H. rewrite orb_false_b. reflexivity.
Qed.
(** [] *)
(** **** Exercise: 3 stars (binary)  *)
(** Consider a different, more efficient representation of natural
    numbers using a binary rather than unary system.  That is, instead
    of saying that each natural number is either zero or the successor
    of a natural number, we can say that each binary number is either
      - zero,
      - twice a binary number, or
      - one more than twice a binary number.
    (a) First, write an inductive definition of the type [bin]
        corresponding to this description of binary numbers. 
    (Hint: Recall that the definition of [nat] from class,
    Inductive nat : Type :=
      | O : nat
      | S : nat -> nat.
    says nothing about what [O] and [S] "mean."  It just says "[O] is
    in the set called [nat], and if [n] is in the set then so is [S
    n]."  The interpretation of [O] as zero and [S] as successor/plus
    one comes from the way that we _use_ [nat] values, by writing
    functions to do things with them, proving things about them, and
    so on.  Your definition of [bin] should be correspondingly simple;
    it is the functions you will write next that will give it
    mathematical meaning.)
    (b) Next, write an increment function [incr] for binary numbers, 
        and a function [bin_to_nat] to convert binary numbers to unary numbers.
    (c) Write five unit tests [test_bin_incr1], [test_bin_incr2], etc.
        for your increment and binary-to-unary functions. Notice that 
        incrementing a binary number and then converting it to unary 
        should yield the same result as first converting it to unary and 
        then incrementing. 
 *)
Inductive bin : Type :=
| Ob : bin
| Tb : bin -> bin
| STb : bin -> bin.
Fixpoint incr (n: bin) : bin :=
  match n with
    | Ob => STb Ob
    | Tb n => STb n
    | STb n => Tb (incr n)
  end.
Fixpoint bin_to_nat (n : bin) : nat :=
  match n with
    | Ob => O
    | Tb n => 2 * (bin_to_nat n)
    | STb n => 2 * (bin_to_nat n) + 1
  end.
Lemma plus_1_S : forall n : nat, n + 1 = S n.
Proof.
  intros n.
  induction n. simpl. reflexivity.
  simpl. rewrite IHn. reflexivity.
Qed.
Lemma plus_O : forall n : nat, n + 0 = n.
  intros n. induction n. reflexivity. simpl. rewrite IHn. reflexivity.
Qed.
Lemma S_equal : forall n m : nat, S n = S m <-> n = m.
Proof.
  intros n m.
  split. intros H. inversion H. reflexivity.
  intros H. rewrite H. reflexivity.
Qed.
Lemma S_equal_l : forall n m : nat, S n = S m -> n = m.
Proof.
  intros n m H. inversion H. reflexivity.
Qed.
Lemma S_equal_r : forall n m : nat, n = m -> S n = S m.
  intros n m H. rewrite H. reflexivity.
Qed.
Lemma plus_SS : forall n m : nat, S n + S m = S (S (n + m)).
Proof.
  intros n. induction n as [|n'].
  intros m. simpl. reflexivity.
  intros m. simpl. apply S_equal. rewrite <- IHn'. simpl. reflexivity.
Qed.
Theorem incr_bin_nat :
  forall n : bin,
    bin_to_nat (incr n) = S (bin_to_nat n).
Proof.
  intros n.
  induction n as [| n' | n'].
  (* n = Ob *) simpl. reflexivity.
  (* n = Tb n' *) simpl. rewrite plus_1_S. reflexivity.
  (* n = STb n' *)
  simpl. rewrite IHn'. 
  rewrite plus_1_S. rewrite plus_O. rewrite plus_O. rewrite plus_SS. reflexivity.
Qed.
(** [] *)
(* ###################################################################### *)
(** * More on Notation (Advanced) *)
(** In general, sections marked Advanced are not needed to follow the
    rest of the book, except possibly other Advanced sections.  On a
    first reading, you might want to skim these sections so that you
    know what's there for future reference. *)
Notation "x + y" := (plus x y)  
                       (at level 50, left associativity) 
                       : nat_scope.
Notation "x * y" := (mult x y)  
                       (at level 40, left associativity) 
                       : nat_scope.
(** For each notation-symbol in Coq we can specify its _precedence level_
    and its _associativity_. The precedence level n can be specified by the
    keywords [at level n] and it is helpful to disambiguate
    expressions containing different symbols. The associativity is helpful
    to disambiguate expressions containing more occurrences of the same 
    symbol. For example, the parameters specified above for [+] and [*]
    say that the expression [1+2*3*4] is a shorthand for the expression
    [(1+((2*3)*4))]. Coq uses precedence levels from 0 to 100, and 
    _left_, _right_, or _no_ associativity.
    Each notation-symbol in Coq is also active in a _notation scope_.  
    Coq tries to guess what scope you mean, so when you write [S(O*O)] 
    it guesses [nat_scope], but when you write the cartesian
    product (tuple) type [bool*bool] it guesses [type_scope].
    Occasionally you have to help it out with percent-notation by
    writing [(x*y)%nat], and sometimes in Coq's feedback to you it
    will use [%nat] to indicate what scope a notation is in.
    Notation scopes also apply to numeral notation (3,4,5, etc.), so you
    may sometimes see [0%nat] which means [O], or [0%Z] which means the
    Integer zero.
*)
(** * [Fixpoint] and Structural Recursion (Advanced) *)
Fixpoint plus' (n : nat) (m : nat) : nat :=
  match n with
    | O => m
    | S n' => S (plus' n' m)
  end.
(** When Coq checks this definition, it notes that [plus'] is
    "decreasing on 1st argument."  What this means is that we are
    performing a _structural recursion_ over the argument [n] -- i.e.,
    that we make recursive calls only on strictly smaller values of
    [n].  This implies that all calls to [plus'] will eventually
    terminate.  Coq demands that some argument of _every_ [Fixpoint]
    definition is "decreasing".
    This requirement is a fundamental feature of Coq's design: In
    particular, it guarantees that every function that can be defined
    in Coq will terminate on all inputs.  However, because Coq's
    "decreasing analysis" is not very sophisticated, it is sometimes
    necessary to write functions in slightly unnatural ways. *)
(** **** Exercise: 2 stars, optional (decreasing)  *)
(** To get a concrete sense of this, find a way to write a sensible
    [Fixpoint] definition (of a simple function on numbers, say) that
    _does_ terminate on all inputs, but that Coq will reject because
    of this restriction. *)
(* FILL IN HERE *)
(** [] *)
(** $Date: 2014-12-31 15:31:47 -0500 (Wed, 31 Dec 2014) $ *)
module redFour__NMOSwk_X_1_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply0 gnd;
  rtranif1 #(100) NMOSfwk_0 (d, s, g);
endmodule   
module redFour__PMOSwk_X_0_833_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply1 vdd;
  rtranif0 #(100) PMOSfwk_0 (d, s, g);
endmodule   
module scanChainFive__scanL(in, out);
  input in;
  output out;
  supply1 vdd;
  supply0 gnd;
  wire net_4, net_7;
  redFour__NMOSwk_X_1_Delay_100 NMOSwk_0(.g(out), .d(in), .s(net_7));
  redFour__NMOSwk_X_1_Delay_100 NMOSwk_1(.g(out), .d(net_7), .s(gnd));
  redFour__PMOSwk_X_0_833_Delay_100 PMOSwk_0(.g(out), .d(net_4), .s(vdd));
  redFour__PMOSwk_X_0_833_Delay_100 PMOSwk_1(.g(out), .d(in), .s(net_4));
  not (strong0, strong1) #(100) invV_0 (out, in);
endmodule   
module redFour__NMOS_X_6_667_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply0 gnd;
  tranif1 #(100) NMOSf_0 (d, s, g);
endmodule   
module redFour__PMOS_X_3_333_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply1 vdd;
  tranif0 #(100) PMOSf_0 (d, s, g);
endmodule   
module scanChainFive__scanP(in, src, drn);
  input in;
  input src;
  output drn;
  supply1 vdd;
  supply0 gnd;
  wire net_1;
  redFour__NMOS_X_6_667_Delay_100 NMOS_0(.g(in), .d(drn), .s(src));
  redFour__PMOS_X_3_333_Delay_100 PMOS_0(.g(net_1), .d(drn), .s(src));
  not (strong0, strong1) #(0) inv_0 (net_1, in);
endmodule   
module scanChainFive__scanRL(phi1, phi2, rd, sin, sout);
  input phi1;
  input phi2;
  input rd;
  input sin;
  output sout;
  supply1 vdd;
  supply0 gnd;
  wire net_0, net_2, net_3;
  scanChainFive__scanL foo1(.in(net_2), .out(net_3));
  scanChainFive__scanL foo2(.in(net_0), .out(sout));
  scanChainFive__scanP scanP_0(.in(rd), .src(vdd), .drn(net_0));
  scanChainFive__scanP scanP_1(.in(phi1), .src(net_3), .drn(net_0));
  scanChainFive__scanP scanP_2(.in(phi2), .src(sin), .drn(net_2));
endmodule   
module jtag__BR(SDI, phi1, phi2, read, SDO);
  input SDI;
  input phi1;
  input phi2;
  input read;
  output SDO;
  supply1 vdd;
  supply0 gnd;
  scanChainFive__scanRL scanRL_0(.phi1(phi1), .phi2(phi2), .rd(read), 
      .sin(SDI), .sout(SDO));
endmodule   
module scanChainFive__scanIRH(mclr, phi1, phi2, rd, sin, wr, dout, doutb, 
      sout);
  input mclr;
  input phi1;
  input phi2;
  input rd;
  input sin;
  input wr;
  output dout;
  output doutb;
  output sout;
  supply1 vdd;
  supply0 gnd;
  wire net_2, net_4, net_6, net_7;
  scanChainFive__scanL foo1(.in(net_6), .out(net_7));
  scanChainFive__scanL foo2(.in(net_2), .out(sout));
  scanChainFive__scanL foo3(.in(net_4), .out(doutb));
  not (strong0, strong1) #(100) invLT_0 (dout, doutb);
  scanChainFive__scanP scanP_0(.in(wr), .src(sout), .drn(net_4));
  scanChainFive__scanP scanP_1(.in(rd), .src(gnd), .drn(net_2));
  scanChainFive__scanP scanP_2(.in(mclr), .src(vdd), .drn(net_4));
  scanChainFive__scanP scanP_3(.in(phi1), .src(net_7), .drn(net_2));
  scanChainFive__scanP scanP_4(.in(phi2), .src(sin), .drn(net_6));
endmodule   
module scanChainFive__scanIRL(mclr, phi1, phi2, rd, sin, wr, dout, doutb, 
      sout);
  input mclr;
  input phi1;
  input phi2;
  input rd;
  input sin;
  input wr;
  output dout;
  output doutb;
  output sout;
  supply1 vdd;
  supply0 gnd;
  wire net_2, net_3, net_4, net_6;
  scanChainFive__scanL foo1(.in(net_2), .out(net_3));
  scanChainFive__scanL foo2(.in(net_4), .out(sout));
  scanChainFive__scanL foo3(.in(net_6), .out(doutb));
  not (strong0, strong1) #(100) invLT_0 (dout, doutb);
  scanChainFive__scanP scanP_0(.in(rd), .src(vdd), .drn(net_4));
  scanChainFive__scanP scanP_1(.in(mclr), .src(vdd), .drn(net_6));
  scanChainFive__scanP scanP_2(.in(wr), .src(sout), .drn(net_6));
  scanChainFive__scanP scanP_3(.in(phi1), .src(net_3), .drn(net_4));
  scanChainFive__scanP scanP_4(.in(phi2), .src(sin), .drn(net_2));
endmodule   
module jtag__IR(SDI, phi1, phi2, read, reset, write, IR, IRb, SDO);
  input SDI;
  input phi1;
  input phi2;
  input read;
  input reset;
  input write;
  output [8:1] IR;
  output [8:1] IRb;
  output SDO;
  supply1 vdd;
  supply0 gnd;
  wire net_1, net_2, net_3, net_4, net_5, net_6, net_7;
  scanChainFive__scanIRH scanIRH_0(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_1), .wr(write), .dout(IR[1]), .doutb(IRb[1]), 
      .sout(SDO));
  scanChainFive__scanIRL scanIRL_0(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_3), .wr(write), .dout(IR[7]), .doutb(IRb[7]), 
      .sout(net_2));
  scanChainFive__scanIRL scanIRL_1(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_5), .wr(write), .dout(IR[5]), .doutb(IRb[5]), 
      .sout(net_4));
  scanChainFive__scanIRL scanIRL_2(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_2), .wr(write), .dout(IR[6]), .doutb(IRb[6]), 
      .sout(net_5));
  scanChainFive__scanIRL scanIRL_3(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_7), .wr(write), .dout(IR[3]), .doutb(IRb[3]), 
      .sout(net_6));
  scanChainFive__scanIRL scanIRL_4(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_6), .wr(write), .dout(IR[2]), .doutb(IRb[2]), 
      .sout(net_1));
  scanChainFive__scanIRL scanIRL_5(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(net_4), .wr(write), .dout(IR[4]), .doutb(IRb[4]), 
      .sout(net_7));
  scanChainFive__scanIRL scanIRL_6(.mclr(reset), .phi1(phi1), .phi2(phi2), 
      .rd(read), .sin(SDI), .wr(write), .dout(IR[8]), .doutb(IRb[8]), 
      .sout(net_3));
endmodule   
module redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1(ina, inb, 
      out);
  input ina;
  input inb;
  output out;
  supply1 vdd;
  supply0 gnd;
  nor (strong0, strong1) #(100) nor2_0 (out, ina, inb);
endmodule   
module jtag__IRdecode(IR, IRb, Bypass, ExTest, SamplePreload, ScanPath);
  input [4:1] IR;
  input [4:1] IRb;
  output Bypass;
  output ExTest;
  output SamplePreload;
  output [12:0] ScanPath;
  supply1 vdd;
  supply0 gnd;
  wire H00, H01, H10, H11, L00, L01, L10, L11, net_19, net_21, net_23, net_25;
  wire net_26, net_27, net_28, net_29, net_30, net_31, net_32, net_33, net_34;
  wire net_35, net_36, net_37;
  not (strong0, strong1) #(100) inv_0 (Bypass, net_19);
  not (strong0, strong1) #(100) inv_1 (SamplePreload, net_21);
  not (strong0, strong1) #(100) inv_2 (ExTest, net_23);
  not (strong0, strong1) #(100) inv_3 (ScanPath[12], net_25);
  not (strong0, strong1) #(100) inv_4 (ScanPath[11], net_26);
  not (strong0, strong1) #(100) inv_5 (ScanPath[10], net_27);
  not (strong0, strong1) #(100) inv_6 (ScanPath[9], net_28);
  not (strong0, strong1) #(100) inv_7 (ScanPath[8], net_29);
  not (strong0, strong1) #(100) inv_8 (ScanPath[7], net_30);
  not (strong0, strong1) #(100) inv_9 (ScanPath[6], net_31);
  not (strong0, strong1) #(100) inv_10 (ScanPath[5], net_32);
  not (strong0, strong1) #(100) inv_11 (ScanPath[4], net_33);
  not (strong0, strong1) #(100) inv_12 (ScanPath[3], net_34);
  not (strong0, strong1) #(100) inv_13 (ScanPath[2], net_35);
  not (strong0, strong1) #(100) inv_14 (ScanPath[1], net_36);
  not (strong0, strong1) #(100) inv_15 (ScanPath[0], net_37);
  nand (strong0, strong1) #(100) nand2_0 (net_19, L11, H11);
  nand (strong0, strong1) #(100) nand2_1 (net_21, L10, H11);
  nand (strong0, strong1) #(100) nand2_2 (net_23, L01, H11);
  nand (strong0, strong1) #(100) nand2_3 (net_25, L00, H11);
  nand (strong0, strong1) #(100) nand2_4 (net_26, L11, H10);
  nand (strong0, strong1) #(100) nand2_5 (net_27, L10, H10);
  nand (strong0, strong1) #(100) nand2_6 (net_28, L01, H10);
  nand (strong0, strong1) #(100) nand2_7 (net_29, L00, H10);
  nand (strong0, strong1) #(100) nand2_8 (net_30, L11, H01);
  nand (strong0, strong1) #(100) nand2_9 (net_31, L10, H01);
  nand (strong0, strong1) #(100) nand2_10 (net_32, L01, H01);
  nand (strong0, strong1) #(100) nand2_11 (net_33, L00, H01);
  nand (strong0, strong1) #(100) nand2_12 (net_34, L11, H00);
  nand (strong0, strong1) #(100) nand2_13 (net_35, L10, H00);
  nand (strong0, strong1) #(100) nand2_14 (net_36, L01, H00);
  nand (strong0, strong1) #(100) nand2_15 (net_37, L00, H00);
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_0(.ina(IR[1]), .inb(IR[2]), .out(L00));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_1(.ina(IRb[1]), .inb(IR[2]), .out(L01));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_2(.ina(IR[1]), .inb(IRb[2]), .out(L10));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_3(.ina(IRb[1]), .inb(IRb[2]), .out(L11));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_4(.ina(IR[3]), .inb(IR[4]), .out(H00));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_5(.ina(IRb[3]), .inb(IR[4]), .out(H01));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_6(.ina(IR[3]), .inb(IRb[4]), .out(H10));
  redFour__nor2n_X_3_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_7(.ina(IRb[3]), .inb(IRb[4]), .out(H11));
endmodule   
module redFour__PMOSwk_X_0_222_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply1 vdd;
  rtranif0 #(100) PMOSfwk_0 (d, s, g);
endmodule   
module jtag__clockGen(clk, phi1_fb, phi2_fb, phi1_out, phi2_out);
  input clk;
  input phi1_fb;
  input phi2_fb;
  output phi1_out;
  output phi2_out;
  supply1 vdd;
  supply0 gnd;
  wire net_0, net_1, net_3, net_4, net_6;
  not (strong0, strong1) #(100) inv_0 (phi2_out, net_3);
  not (strong0, strong1) #(100) inv_1 (phi1_out, net_6);
  not (strong0, strong1) #(100) inv_2 (net_4, clk);
  not (strong0, strong1) #(100) invLT_0 (net_0, phi1_fb);
  not (strong0, strong1) #(100) invLT_1 (net_1, phi2_fb);
  nand (strong0, strong1) #(100) nand2_0 (net_3, net_0, net_4);
  nand (strong0, strong1) #(100) nand2_1 (net_6, net_1, clk);
endmodule   
module jtag__capture_ctl(capture, phi2, sel, out, phi1);
  input capture;
  input phi2;
  input sel;
  output out;
  input phi1;
  supply1 vdd;
  supply0 gnd;
  wire net_1, net_2, net_3, net_4;
  scanChainFive__scanL foo(.in(net_2), .out(net_3));
  not (strong0, strong1) #(100) inv_0 (net_1, capture);
  not (strong0, strong1) #(100) inv_1 (out, net_4);
  nand (strong0, strong1) #(100) nand3_0 (net_4, sel, net_3, phi1);
  scanChainFive__scanP scanP_0(.in(phi2), .src(net_1), .drn(net_2));
endmodule   
module jtag__shift_ctl(phi1_fb, phi2_fb, sel, shift, phi1_out, phi2_out, 
      phi1_in, phi2_in);
  input phi1_fb;
  input phi2_fb;
  input sel;
  input shift;
  output phi1_out;
  output phi2_out;
  input phi1_in;
  input phi2_in;
  supply1 vdd;
  supply0 gnd;
  wire net_1, net_2, net_3, net_4, net_7;
  jtag__clockGen clockGen_0(.clk(net_7), .phi1_fb(phi1_fb), .phi2_fb(phi2_fb), 
      .phi1_out(phi1_out), .phi2_out(phi2_out));
  scanChainFive__scanL foo(.in(net_2), .out(net_3));
  not (strong0, strong1) #(100) inv_0 (net_7, net_4);
  not (strong0, strong1) #(100) inv_1 (net_1, shift);
  nand (strong0, strong1) #(100) nand3_0 (net_4, sel, net_3, phi1_in);
  scanChainFive__scanP scanP_0(.in(phi2_in), .src(net_1), .drn(net_2));
endmodule   
module jtag__update_ctl(sel, update, out, phi2);
  input sel;
  input update;
  output out;
  input phi2;
  supply1 vdd;
  supply0 gnd;
  wire net_1;
  not (strong0, strong1) #(100) inv_0 (out, net_1);
  nand (strong0, strong1) #(100) nand3_0 (net_1, sel, update, phi2);
endmodule   
module jtag__jtagIRControl(capture, phi1_fb, phi1_in, phi2_fb, phi2_in, shift, 
      update, phi1_out, phi2_out, read, write);
  input capture;
  input phi1_fb;
  input phi1_in;
  input phi2_fb;
  input phi2_in;
  input shift;
  input update;
  output phi1_out;
  output phi2_out;
  output read;
  output write;
  supply1 vdd;
  supply0 gnd;
  jtag__capture_ctl capture__0(.capture(capture), .phi2(phi2_in), .sel(vdd), 
      .out(read), .phi1(phi1_in));
  jtag__shift_ctl shift_ct_0(.phi1_fb(phi1_fb), .phi2_fb(phi2_fb), .sel(vdd), 
      .shift(shift), .phi1_out(phi1_out), .phi2_out(phi2_out), 
      .phi1_in(phi1_in), .phi2_in(phi2_in));
  jtag__update_ctl update_c_0(.sel(vdd), .update(update), .out(write), 
      .phi2(phi2_in));
endmodule   
module redFour__NMOS_X_8_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply0 gnd;
  tranif1 #(100) NMOSf_0 (d, s, g);
endmodule   
module redFour__PMOS_X_4_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply1 vdd;
  tranif0 #(100) PMOSf_0 (d, s, g);
endmodule   
module jtag__tsinvBig(Din, en, enb, Dout);
  input Din;
  input en;
  input enb;
  output Dout;
  supply1 vdd;
  supply0 gnd;
  wire net_13, net_14, net_22, net_23;
  redFour__NMOS_X_8_Delay_100 NMOS_0(.g(Din), .d(net_13), .s(gnd));
  redFour__NMOS_X_8_Delay_100 NMOS_1(.g(en), .d(Dout), .s(net_13));
  redFour__NMOS_X_8_Delay_100 NMOS_2(.g(en), .d(Dout), .s(net_23));
  redFour__NMOS_X_8_Delay_100 NMOS_3(.g(Din), .d(net_23), .s(gnd));
  redFour__PMOS_X_4_Delay_100 PMOS_0(.g(enb), .d(Dout), .s(net_14));
  redFour__PMOS_X_4_Delay_100 PMOS_1(.g(Din), .d(net_14), .s(vdd));
  redFour__PMOS_X_4_Delay_100 PMOS_2(.g(enb), .d(Dout), .s(net_22));
  redFour__PMOS_X_4_Delay_100 PMOS_3(.g(Din), .d(net_22), .s(vdd));
endmodule   
module jtag__jtagScanControl(TDI, capture, phi1_fb, phi1_in, phi2_fb, phi2_in, 
      sel, shift, update, TDO, phi1_out, phi2_out, read, write);
  input TDI;
  input capture;
  input phi1_fb;
  input phi1_in;
  input phi2_fb;
  input phi2_in;
  input sel;
  input shift;
  input update;
  output TDO;
  output phi1_out;
  output phi2_out;
  output read;
  output write;
  supply1 vdd;
  supply0 gnd;
  wire net_0, net_2;
  jtag__capture_ctl capture__0(.capture(capture), .phi2(phi2_in), .sel(sel), 
      .out(read), .phi1(phi1_in));
  not (strong0, strong1) #(100) inv_0 (net_2, sel);
  not (strong0, strong1) #(100) inv_1 (net_0, TDI);
  jtag__shift_ctl shift_ct_0(.phi1_fb(phi1_fb), .phi2_fb(phi2_fb), .sel(sel), 
      .shift(shift), .phi1_out(phi1_out), .phi2_out(phi2_out), 
      .phi1_in(phi1_in), .phi2_in(phi2_in));
  jtag__tsinvBig tsinvBig_0(.Din(net_0), .en(sel), .enb(net_2), .Dout(TDO));
  jtag__update_ctl update_c_0(.sel(sel), .update(update), .out(write), 
      .phi2(phi2_in));
endmodule   
module redFour__NMOS_X_5_667_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply0 gnd;
  tranif1 #(100) NMOSf_0 (d, s, g);
endmodule   
module redFour__PMOS_X_2_833_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply1 vdd;
  tranif0 #(100) PMOSf_0 (d, s, g);
endmodule   
module jtag__tsinv(Din, Dout, en, enb);
  input Din;
  input Dout;
  input en;
  input enb;
  supply1 vdd;
  supply0 gnd;
  wire net_1, net_2;
  redFour__NMOS_X_5_667_Delay_100 NMOS_0(.g(Din), .d(net_1), .s(gnd));
  redFour__NMOS_X_5_667_Delay_100 NMOS_1(.g(en), .d(Dout), .s(net_1));
  redFour__PMOS_X_2_833_Delay_100 PMOS_0(.g(Din), .d(net_2), .s(vdd));
  redFour__PMOS_X_2_833_Delay_100 PMOS_1(.g(enb), .d(Dout), .s(net_2));
endmodule   
module jtag__mux2_phi2(Din0, Din1, phi2, sel, Dout);
  input Din0;
  input Din1;
  input phi2;
  input sel;
  output Dout;
  supply1 vdd;
  supply0 gnd;
  wire net_1, net_2, net_3, net_5, net_6;
  not (strong0, strong1) #(100) inv_0 (net_5, sel);
  not (strong0, strong1) #(100) inv_1 (net_1, net_6);
  not (strong0, strong1) #(100) inv_2 (Dout, net_3);
  scanChainFive__scanL scanL_0(.in(net_2), .out(net_3));
  scanChainFive__scanP scanP_0(.in(phi2), .src(net_1), .drn(net_2));
  jtag__tsinv tsinv_0(.Din(Din0), .Dout(net_6), .en(net_5), .enb(sel));
  jtag__tsinv tsinv_1(.Din(Din1), .Dout(net_6), .en(sel), .enb(net_5));
endmodule   
module jtag__scanAmp1w1648(in, out);
  input in;
  output out;
  supply1 vdd;
  supply0 gnd;
  wire net_0;
  tranif1 nmos_0(gnd, net_0, in);
  tranif1 nmos_1(gnd, out, net_0);
  tranif0 pmos_0(net_0, vdd, in);
  tranif0 pmos_1(out, vdd, net_0);
endmodule   
module redFour__nand2n_X_3_5_Delay_100_drive0_strong0_drive1_strong1(ina, inb, 
      out);
  input ina;
  input inb;
  output out;
  supply1 vdd;
  supply0 gnd;
  nand (strong0, strong1) #(100) nand2_0 (out, ina, inb);
endmodule   
module redFour__nand2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1(ina, inb, 
      out);
  input ina;
  input inb;
  output out;
  supply1 vdd;
  supply0 gnd;
  nand (strong0, strong1) #(100) nand2_0 (out, ina, inb);
endmodule   
module redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1(ina, inb, 
      out);
  input ina;
  input inb;
  output out;
  supply1 vdd;
  supply0 gnd;
  nor (strong0, strong1) #(100) nor2_0 (out, ina, inb);
endmodule   
module orangeTSMC180nm__wire_R_26m_100_C_0_025f(a);
  input a;
  supply0 gnd;
endmodule   
module orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100(a);
  input a;
  supply0 gnd;
  orangeTSMC180nm__wire_R_26m_100_C_0_025f wire_0(.a(a));
endmodule   
module jtag__o2a(inAa, inAb, inOb, out);
  input inAa;
  input inAb;
  input inOb;
  output out;
  supply1 vdd;
  supply0 gnd;
  wire net_0;
  nor (strong0, strong1) #(100) nor2_0 (net_0, inAa, inAb);
  redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_0(.ina(inOb), .inb(net_0), .out(out));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100 wire180_0(.a(net_0));
endmodule   
module orangeTSMC180nm__wire_R_26m_500_C_0_025f(a);
  input a;
  supply0 gnd;
endmodule   
module orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_500(a);
  input a;
  supply0 gnd;
  orangeTSMC180nm__wire_R_26m_500_C_0_025f wire_0(.a(a));
endmodule   
module jtag__slaveBit(din, phi2, slave);
  input din;
  input phi2;
  output slave;
  supply1 vdd;
  supply0 gnd;
  wire net_6, net_7;
  not (strong0, strong1) #(100) inv_0 (slave, net_7);
  scanChainFive__scanL scanL_0(.in(net_6), .out(net_7));
  scanChainFive__scanP scanP_0(.in(phi2), .src(din), .drn(net_6));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_500 wire180_0(.a(slave));
endmodule   
module redFour__NMOS_X_1_667_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply0 gnd;
  tranif1 #(100) NMOSf_0 (d, s, g);
endmodule   
module orangeTSMC180nm__wire_R_26m_750_C_0_025f(a);
  input a;
  supply0 gnd;
endmodule   
module orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_750(a);
  input a;
  supply0 gnd;
  orangeTSMC180nm__wire_R_26m_750_C_0_025f wire_0(.a(a));
endmodule   
module orangeTSMC180nm__wire_R_26m_1000_C_0_025f(a);
  input a;
  supply0 gnd;
endmodule   
module orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_1000(a);
  input a;
  supply0 gnd;
  orangeTSMC180nm__wire_R_26m_1000_C_0_025f wire_0(.a(a));
endmodule   
module jtag__stateBit(next, phi1, phi2, rst, master, slave, slaveBar);
  input next;
  input phi1;
  input phi2;
  input rst;
  output master;
  output slave;
  output slaveBar;
  supply1 vdd;
  supply0 gnd;
  wire net_12, net_13, net_14, net_17;
  redFour__NMOS_X_1_667_Delay_100 NMOS_0(.g(rst), .d(net_12), .s(gnd));
  not (strong0, strong1) #(100) inv_0 (slave, slaveBar);
  not (strong0, strong1) #(100) inv_1 (slaveBar, net_17);
  not (strong0, strong1) #(100) inv_2 (master, net_13);
  scanChainFive__scanL scanL_0(.in(net_12), .out(net_13));
  scanChainFive__scanL scanL_1(.in(net_14), .out(net_17));
  scanChainFive__scanP scanP_0(.in(phi1), .src(next), .drn(net_12));
  scanChainFive__scanP scanP_1(.in(phi2), .src(net_13), .drn(net_14));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_750 wire180_0(.a(master));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_1000 wire180_1(.a(slave));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_500 
      wire180_2(.a(slaveBar));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100 wire180_3(.a(next));
endmodule   
module redFour__PMOS_X_1_5_Delay_100(g, d, s);
  input g;
  input d;
  input s;
  supply1 vdd;
  tranif0 #(100) PMOSf_0 (d, s, g);
endmodule   
module jtag__stateBitHI(next, phi1, phi2, rstb, master, slave, slaveBar);
  input next;
  input phi1;
  input phi2;
  input rstb;
  output master;
  output slave;
  output slaveBar;
  supply1 vdd;
  supply0 gnd;
  wire net_10, net_11, net_12, net_15;
  redFour__PMOS_X_1_5_Delay_100 PMOS_0(.g(rstb), .d(net_12), .s(vdd));
  not (strong0, strong1) #(100) inv_0 (slave, slaveBar);
  not (strong0, strong1) #(100) inv_1 (slaveBar, net_15);
  not (strong0, strong1) #(100) inv_2 (master, net_10);
  scanChainFive__scanL scanL_0(.in(net_12), .out(net_10));
  scanChainFive__scanL scanL_1(.in(net_11), .out(net_15));
  scanChainFive__scanP scanP_0(.in(phi1), .src(next), .drn(net_12));
  scanChainFive__scanP scanP_1(.in(phi2), .src(net_10), .drn(net_11));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_1000 wire180_0(.a(slave));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_500 
      wire180_1(.a(slaveBar));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100 wire180_2(.a(next));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_750 wire180_3(.a(master));
endmodule   
module orangeTSMC180nm__wire_R_26m_675_C_0_025f(a);
  input a;
  supply0 gnd;
endmodule   
module orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_675(a);
  input a;
  supply0 gnd;
  orangeTSMC180nm__wire_R_26m_675_C_0_025f wire_0(.a(a));
endmodule   
module orangeTSMC180nm__wire_R_26m_1500_C_0_025f(a);
  input a;
  supply0 gnd;
endmodule   
module orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_1500(a);
  input a;
  supply0 gnd;
  orangeTSMC180nm__wire_R_26m_1500_C_0_025f wire_0(.a(a));
endmodule   
module jtag__tapCtlJKL(TMS, TRSTb, phi1, phi2, CapDR, CapIR, Idle, PauseDR, 
      PauseIR, Reset, Reset_s, SelDR, SelIR, ShftDR, ShftIR, UpdDR, UpdIR, 
      X1DR, X1IR, X2DR, X2IR);
  input TMS;
  input TRSTb;
  input phi1;
  input phi2;
  output CapDR;
  output CapIR;
  output Idle;
  output PauseDR;
  output PauseIR;
  output Reset;
  output Reset_s;
  output SelDR;
  output SelIR;
  output ShftDR;
  output ShftIR;
  output UpdDR;
  output UpdIR;
  output X1DR;
  output X1IR;
  output X2DR;
  output X2IR;
  supply1 vdd;
  supply0 gnd;
  wire net_0, net_2, net_4, net_6, net_12, net_13, net_14, net_15, net_16;
  wire net_17, net_18, net_19, net_20, net_22, net_23, net_24, net_25, net_26;
  wire net_28, net_29, net_31, net_32, net_34, net_40, net_43, net_44, net_48;
  wire net_50, net_52, net_54, net_55, net_56, net_58, net_59, net_60, net_64;
  wire net_67, net_68, net_70, net_71, net_72, net_74, net_75, net_76, net_79;
  wire net_80, rst, stateBit_1_slave, stateBit_5_slaveBar, stateBit_6_slaveBar;
  wire stateBit_9_slaveBar, stateBit_10_slaveBar, stateBit_11_slave;
  wire stateBit_12_slave;
  not (strong0, strong1) #(100) inv_0 (rst, TRSTb);
  not (strong0, strong1) #(100) inv_1 (net_24, net_12);
  redFour__nand2n_X_3_5_Delay_100_drive0_strong0_drive1_strong1 
      nand2n_0(.ina(net_13), .inb(net_14), .out(net_0));
  redFour__nand2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nand2n_1(.ina(net_15), .inb(net_16), .out(net_4));
  redFour__nand2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nand2n_2(.ina(net_17), .inb(net_18), .out(net_2));
  redFour__nand2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nand2n_3(.ina(net_19), .inb(net_20), .out(net_6));
  redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_0(.ina(net_12), .inb(net_23), .out(net_22));
  redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_1(.ina(net_24), .inb(net_26), .out(net_25));
  redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_2(.ina(net_24), .inb(net_29), .out(net_28));
  redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_3(.ina(net_24), .inb(net_32), .out(net_31));
  redFour__nor2n_X_1_25_Delay_100_drive0_strong0_drive1_strong1 
      nor2n_4(.ina(net_12), .inb(net_26), .out(net_34));
  jtag__o2a o2a_0(.inAa(net_2), .inAb(net_43), .inOb(net_12), .out(net_40));
  jtag__o2a o2a_1(.inAa(net_6), .inAb(net_0), .inOb(net_12), .out(net_44));
  jtag__o2a o2a_2(.inAa(net_50), .inAb(net_0), .inOb(net_24), .out(net_48));
  jtag__o2a o2a_3(.inAa(net_54), .inAb(net_55), .inOb(net_12), .out(net_52));
  jtag__o2a o2a_4(.inAa(net_58), .inAb(net_59), .inOb(net_12), .out(net_56));
  jtag__o2a o2a_5(.inAa(net_58), .inAb(net_43), .inOb(net_24), .out(net_60));
  jtag__o2a o2a_6(.inAa(net_54), .inAb(net_67), .inOb(net_24), .out(net_64));
  jtag__o2a o2a_7(.inAa(net_70), .inAb(net_71), .inOb(net_24), .out(net_68));
  jtag__o2a o2a_8(.inAa(net_74), .inAb(net_75), .inOb(net_24), .out(net_72));
  jtag__o2a o2a_9(.inAa(Reset_s), .inAb(net_79), .inOb(net_24), .out(net_76));
  jtag__o2a o2a_10(.inAa(net_4), .inAb(net_67), .inOb(net_12), .out(net_80));
  jtag__slaveBit slaveBit_0(.din(TMS), .phi2(phi2), .slave(net_12));
  jtag__stateBit stateBit_0(.next(net_25), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(SelIR), .slave(net_79), .slaveBar(net_23));
  jtag__stateBit stateBit_1(.next(net_48), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(SelDR), .slave(stateBit_1_slave), .slaveBar(net_26));
  jtag__stateBit stateBit_2(.next(net_34), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(CapDR), .slave(net_75), .slaveBar(net_16));
  jtag__stateBit stateBit_3(.next(net_22), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(CapIR), .slave(net_71), .slaveBar(net_18));
  jtag__stateBit stateBit_4(.next(net_44), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(Idle), .slave(net_50), .slaveBar(net_20));
  jtag__stateBit stateBit_5(.next(net_68), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(X1IR), .slave(net_58), .slaveBar(stateBit_5_slaveBar));
  jtag__stateBit stateBit_6(.next(net_72), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(X1DR), .slave(net_54), .slaveBar(stateBit_6_slaveBar));
  jtag__stateBit stateBit_7(.next(net_80), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(ShftDR), .slave(net_74), .slaveBar(net_15));
  jtag__stateBit stateBit_8(.next(net_40), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(ShftIR), .slave(net_70), .slaveBar(net_17));
  jtag__stateBit stateBit_9(.next(net_28), .phi1(phi1), .phi2(phi2), .rst(rst), 
      .master(X2IR), .slave(net_43), .slaveBar(stateBit_9_slaveBar));
  jtag__stateBit stateBit_10(.next(net_31), .phi1(phi1), .phi2(phi2), 
      .rst(rst), .master(X2DR), .slave(net_67), 
      .slaveBar(stateBit_10_slaveBar));
  jtag__stateBit stateBit_11(.next(net_64), .phi1(phi1), .phi2(phi2), 
      .rst(rst), .master(UpdDR), .slave(stateBit_11_slave), 
      .slaveBar(net_14));
  jtag__stateBit stateBit_12(.next(net_60), .phi1(phi1), .phi2(phi2), 
      .rst(rst), .master(UpdIR), .slave(stateBit_12_slave), 
      .slaveBar(net_13));
  jtag__stateBit stateBit_13(.next(net_56), .phi1(phi1), .phi2(phi2), 
      .rst(rst), .master(PauseIR), .slave(net_59), .slaveBar(net_29));
  jtag__stateBit stateBit_14(.next(net_52), .phi1(phi1), .phi2(phi2), 
      .rst(rst), .master(PauseDR), .slave(net_55), .slaveBar(net_32));
  jtag__stateBitHI stateBit_15(.next(net_76), .phi1(phi1), .phi2(phi2), 
      .rstb(TRSTb), .master(Reset), .slave(Reset_s), .slaveBar(net_19));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100 wire180_0(.a(net_4));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100 wire180_1(.a(net_2));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_100 wire180_2(.a(net_6));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_675 wire180_3(.a(net_0));
  orangeTSMC180nm__wire180_width_3_layer_1_LEWIRE_1_1500 wire180_4(.a(rst));
endmodule   
module jtag__jtagControl(TCK, TDI, TDIx, TMS, TRSTb, phi1_fb, phi2_fb, Cap, 
      ExTest, SelBS, SelDR, Shft, TDOb, Upd, phi1, phi2);
  input TCK;
  input TDI;
  input TDIx;
  input TMS;
  input TRSTb;
  input phi1_fb;
  input phi2_fb;
  output Cap;
  output ExTest;
  output SelBS;
  output [12:0] SelDR;
  output Shft;
  output TDOb;
  output Upd;
  output phi1;
  output phi2;
  supply1 vdd;
  supply0 gnd;
  wire jtagScan_0_write, net_0, net_1, net_2, net_3, net_6, net_8, net_10;
  wire net_33, net_35, net_37, net_38, net_41, net_47, net_48, net_50, net_51;
  wire net_52, net_55, net_56, net_62, net_64, net_68, net_73, net_75, net_79;
  wire net_97, net_99, net_103, net_128, tapCtlJK_0_Idle, tapCtlJK_0_PauseDR;
  wire tapCtlJK_0_PauseIR, tapCtlJK_0_Reset, tapCtlJK_0_SelDR, tapCtlJK_0_SelIR;
  wire tapCtlJK_0_X1DR, tapCtlJK_0_X2DR, tapCtlJK_0_X2IR;
  wire [8:1] IR;
  wire [8:1] IRb;
  jtag__BR BR_0(.SDI(TDI), .phi1(net_68), .phi2(net_73), .read(net_99), 
      .SDO(net_97));
  jtag__IR IR_0(.SDI(TDI), .phi1(net_79), .phi2(net_75), .read(net_55), 
      .reset(net_56), .write(net_103), .IR(IR[8:1]), .IRb(IRb[8:1]), 
      .SDO(net_128));
  jtag__IRdecode IRdecode_0(.IR(IR[4:1]), .IRb(IRb[4:1]), .Bypass(net_41), 
      .ExTest(ExTest), .SamplePreload(net_47), .ScanPath(SelDR[12:0]));
  redFour__PMOSwk_X_0_222_Delay_100 PMOSwk_0(.g(gnd), .d(TDIx), .s(vdd));
  jtag__clockGen clockGen_0(.clk(TCK), .phi1_fb(phi1_fb), .phi2_fb(phi2_fb), 
      .phi1_out(net_10), .phi2_out(net_8));
  not (strong0, strong1) #(100) inv_0 (net_0, net_3);
  not (strong0, strong1) #(100) inv_1 (SelBS, net_48);
  not (strong0, strong1) #(100) inv_2 (net_6, net_50);
  not (strong0, strong1) #(100) inv_3 (Cap, net_37);
  not (strong0, strong1) #(100) inv_4 (Shft, net_51);
  not (strong0, strong1) #(100) inv_5 (net_51, net_52);
  not (strong0, strong1) #(100) inv_6 (Upd, net_38);
  jtag__jtagIRControl jtagIRCo_0(.capture(net_62), .phi1_fb(net_79), 
      .phi1_in(phi1), .phi2_fb(net_75), .phi2_in(phi2), .shift(net_2), 
      .update(net_64), .phi1_out(net_79), .phi2_out(net_75), .read(net_55), 
      .write(net_103));
  jtag__jtagScanControl jtagScan_0(.TDI(net_97), .capture(Cap), 
      .phi1_fb(net_68), .phi1_in(phi1), .phi2_fb(net_73), .phi2_in(phi2), 
      .sel(net_41), .shift(Shft), .update(gnd), .TDO(TDIx), .phi1_out(net_68), 
      .phi2_out(net_73), .read(net_99), .write(jtagScan_0_write));
  jtag__mux2_phi2 mux2_phi_0(.Din0(TDIx), .Din1(net_128), .phi2(phi2), 
      .sel(net_0), .Dout(net_50));
  nand (strong0, strong1) #(100) nand2_0 (net_37, IR[8], net_35);
  nand (strong0, strong1) #(100) nand2_1 (net_38, IR[7], net_33);
  nor (strong0, strong1) #(100) nor2_0 (net_3, net_1, net_2);
  nor (strong0, strong1) #(100) nor2_1 (net_48, net_47, ExTest);
  jtag__scanAmp1w1648 scanAmp1_0(.in(net_6), .out(TDOb));
  jtag__scanAmp1w1648 scanAmp1_1(.in(net_8), .out(phi2));
  jtag__scanAmp1w1648 scanAmp1_2(.in(net_10), .out(phi1));
  jtag__tapCtlJKL tapCtlJK_0(.TMS(TMS), .TRSTb(TRSTb), .phi1(phi1), 
      .phi2(phi2), .CapDR(net_35), .CapIR(net_62), .Idle(tapCtlJK_0_Idle), 
      .PauseDR(tapCtlJK_0_PauseDR), .PauseIR(tapCtlJK_0_PauseIR), 
      .Reset(tapCtlJK_0_Reset), .Reset_s(net_56), .SelDR(tapCtlJK_0_SelDR), 
      .SelIR(tapCtlJK_0_SelIR), .ShftDR(net_52), .ShftIR(net_2), 
      .UpdDR(net_33), .UpdIR(net_64), .X1DR(tapCtlJK_0_X1DR), .X1IR(net_1), 
      .X2DR(tapCtlJK_0_X2DR), .X2IR(tapCtlJK_0_X2IR));
endmodule   
module jtag__JTAGamp(leaf, root);
  input [8:1] leaf;
  input [5:1] root;
  supply1 vdd;
  supply0 gnd;
  jtag__scanAmp1w1648 toLeaf_5_(.in(root[5]), .out(leaf[5]));
  jtag__scanAmp1w1648 toLeaf_4_(.in(root[4]), .out(leaf[4]));
  jtag__scanAmp1w1648 toLeaf_3_(.in(root[3]), .out(leaf[3]));
  jtag__scanAmp1w1648 toLeaf_2_(.in(root[2]), .out(leaf[2]));
  jtag__scanAmp1w1648 toLeaf_1_(.in(root[1]), .out(leaf[1]));
endmodule   
module jtag__jtagScanCtlWBuf(TDI, cap, phi1, phi2, sel, shift, upd, TDO, 
      leaf);
  input TDI;
  input cap;
  input phi1;
  input phi2;
  input sel;
  input shift;
  input upd;
  output TDO;
  input [8:1] leaf;
  supply1 vdd;
  supply0 gnd;
  wire [5:2] a;
  jtag__JTAGamp JTAGamp_0(.leaf(leaf[8:1]), .root({a[5], a[4], a[3], a[2], 
      TDI}));
  jtag__jtagScanControl jtagScan_0(.TDI(leaf[8]), .capture(cap), 
      .phi1_fb(leaf[6]), .phi1_in(phi1), .phi2_fb(leaf[7]), .phi2_in(phi2), 
      .sel(sel), .shift(shift), .update(upd), .TDO(TDO), .phi1_out(a[3]), 
      .phi2_out(a[2]), .read(a[5]), .write(a[4]));
endmodule   
module jtag__jtagScanCtlGroup(TDI, capture, phi1_in, phi2_in, selBS, sel, 
      shift, update, TDO, BS, leaf0, leaf1, leaf2, leaf3, leaf4, leaf5, leaf6, 
      leaf7, leaf8, leaf9, leaf10, leaf11, leaf12);
  input TDI;
  input capture;
  input phi1_in;
  input phi2_in;
  input selBS;
  input [12:0] sel;
  input shift;
  input update;
  output TDO;
  input [8:1] BS;
  input [8:1] leaf0;
  input [8:1] leaf1;
  input [8:1] leaf2;
  input [8:1] leaf3;
  input [8:1] leaf4;
  input [8:1] leaf5;
  input [8:1] leaf6;
  input [8:1] leaf7;
  input [8:1] leaf8;
  input [8:1] leaf9;
  input [8:1] leaf10;
  input [8:1] leaf11;
  input [8:1] leaf12;
  supply1 vdd;
  supply0 gnd;
  jtag__jtagScanCtlWBuf jtagScan_1(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[0]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf0[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_2(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[10]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf10[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_3(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[12]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf12[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_4(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[11]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf11[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_5(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[9]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf9[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_6(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[8]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf8[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_7(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[6]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf6[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_8(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[5]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf5[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_9(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[4]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf4[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_10(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[3]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf3[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_11(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[2]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf2[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_12(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[1]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf1[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_13(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(sel[7]), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(leaf7[8:1]));
  jtag__jtagScanCtlWBuf jtagScan_16(.TDI(TDI), .cap(capture), .phi1(phi1_in), 
      .phi2(phi2_in), .sel(selBS), .shift(shift), .upd(update), .TDO(TDO), 
      .leaf(BS[8:1]));
endmodule   
module jtag__jtagCentral_LEIGNORE_1(TCK, TDI, TMS, TRSTb, ExTest, TDOb, BS, 
      leaf0, leaf1, leaf2, leaf3, leaf4, leaf5, leaf6, leaf7, leaf8, leaf9, 
      leaf10, leaf11, leaf12);
  input TCK;
  input TDI;
  input TMS;
  input TRSTb;
  output ExTest;
  output TDOb;
  input [8:1] BS;
  input [8:1] leaf0;
  input [8:1] leaf1;
  input [8:1] leaf2;
  input [8:1] leaf3;
  input [8:1] leaf4;
  input [8:1] leaf5;
  input [8:1] leaf6;
  input [8:1] leaf7;
  input [8:1] leaf8;
  input [8:1] leaf9;
  input [8:1] leaf10;
  input [8:1] leaf11;
  input [8:1] leaf12;
  supply1 vdd;
  supply0 gnd;
  wire net_10, net_14, net_15, net_17, net_24, net_25, net_50;
  wire [0:12] net_6;
  jtag__jtagControl jtagCont_0(.TCK(TCK), .TDI(TDI), .TDIx(net_15), .TMS(TMS), 
      .TRSTb(TRSTb), .phi1_fb(net_24), .phi2_fb(net_10), .Cap(net_25), 
      .ExTest(ExTest), .SelBS(net_50), .SelDR({net_6[0], net_6[1], net_6[2], 
      net_6[3], net_6[4], net_6[5], net_6[6], net_6[7], net_6[8], net_6[9], 
      net_6[10], net_6[11], net_6[12]}), .Shft(net_17), .TDOb(TDOb), 
      .Upd(net_14), .phi1(net_24), .phi2(net_10));
  jtag__jtagScanCtlGroup jtagScan_0(.TDI(TDI), .capture(net_25), 
      .phi1_in(net_24), .phi2_in(net_10), .selBS(net_50), .sel({net_6[0], 
      net_6[1], net_6[2], net_6[3], net_6[4], net_6[5], net_6[6], net_6[7], 
      net_6[8], net_6[9], net_6[10], net_6[11], net_6[12]}), .shift(net_17), 
      .update(net_14), .TDO(net_15), .BS(BS[8:1]), .leaf0(leaf0[8:1]), 
      .leaf1(leaf1[8:1]), .leaf2(leaf2[8:1]), .leaf3(leaf3[8:1]), 
      .leaf4(leaf4[8:1]), .leaf5(leaf5[8:1]), .leaf6(leaf6[8:1]), 
      .leaf7(leaf7[8:1]), .leaf8(leaf8[8:1]), .leaf9(leaf9[8:1]), 
      .leaf10(leaf10[8:1]), .leaf11(leaf11[8:1]), .leaf12(leaf12[8:1]));
endmodule   
module scanFansFour__jtag_endcap(jtag);
  input [8:4] jtag;
endmodule   
module testCell(TCK, TDI, TMS, TRSTb, TDOb);
  input TCK;
  input TDI;
  input TMS;
  input TRSTb;
  output TDOb;
  supply1 vdd;
  supply0 gnd;
  wire jtagCent_0_ExTest;
  wire [4:0] net_5;
  wire [4:0] net_6;
  wire [4:0] net_7;
  wire [4:0] net_8;
  wire [4:0] net_9;
  wire [4:0] net_10;
  wire [4:0] net_11;
  wire [4:0] net_12;
  wire [4:0] net_13;
  wire [4:0] net_14;
  wire [4:0] net_15;
  wire [4:0] net_16;
  wire [4:0] net_17;
  wire [4:0] net_18;
  jtag__jtagCentral_LEIGNORE_1 jtagCent_0(.TCK(TCK), .TDI(TDI), .TMS(TMS), 
      .TRSTb(TRSTb), .ExTest(jtagCent_0_ExTest), .TDOb(TDOb), .BS({net_6[0], 
      net_6[1], net_6[2], net_6[3], net_6[4], net_6[2], net_6[1], net_6[0]}), 
      .leaf0({net_7[0], net_7[1], net_7[2], net_7[3], net_7[4], net_7[2], 
      net_7[1], net_7[0]}), .leaf1({net_18[0], net_18[1], net_18[2], net_18[3], 
      net_18[4], net_18[2], net_18[1], net_18[0]}), .leaf2({net_17[0], 
      net_17[1], net_17[2], net_17[3], net_17[4], net_17[2], net_17[1], 
      net_17[0]}), .leaf3({net_16[0], net_16[1], net_16[2], net_16[3], 
      net_16[4], net_16[2], net_16[1], net_16[0]}), .leaf4({net_15[0], 
      net_15[1], net_15[2], net_15[3], net_15[4], net_15[2], net_15[1], 
      net_15[0]}), .leaf5({net_14[0], net_14[1], net_14[2], net_14[3], 
      net_14[4], net_14[2], net_14[1], net_14[0]}), .leaf6({net_13[0], 
      net_13[1], net_13[2], net_13[3], net_13[4], net_13[2], net_13[1], 
      net_13[0]}), .leaf7({net_12[0], net_12[1], net_12[2], net_12[3], 
      net_12[4], net_12[2], net_12[1], net_12[0]}), .leaf8({net_11[0], 
      net_11[1], net_11[2], net_11[3], net_11[4], net_11[2], net_11[1], 
      net_11[0]}), .leaf9({net_10[0], net_10[1], net_10[2], net_10[3], 
      net_10[4], net_10[2], net_10[1], net_10[0]}), .leaf10({net_9[0], 
      net_9[1], net_9[2], net_9[3], net_9[4], net_9[2], net_9[1], net_9[0]}), 
      .leaf11({net_8[0], net_8[1], net_8[2], net_8[3], net_8[4], net_8[2], 
      net_8[1], net_8[0]}), .leaf12({net_5[0], net_5[1], net_5[2], net_5[3], 
      net_5[4], net_5[2], net_5[1], net_5[0]}));
  scanFansFour__jtag_endcap jtag_end_0(.jtag({net_5[0], net_5[1], net_5[2], 
      net_5[4], net_5[3]}));
  scanFansFour__jtag_endcap jtag_end_1(.jtag({net_8[0], net_8[1], net_8[2], 
      net_8[4], net_8[3]}));
  scanFansFour__jtag_endcap jtag_end_2(.jtag({net_9[0], net_9[1], net_9[2], 
      net_9[4], net_9[3]}));
  scanFansFour__jtag_endcap jtag_end_3(.jtag({net_10[0], net_10[1], net_10[2], 
      net_10[4], net_10[3]}));
  scanFansFour__jtag_endcap jtag_end_4(.jtag({net_11[0], net_11[1], net_11[2], 
      net_11[4], net_11[3]}));
  scanFansFour__jtag_endcap jtag_end_5(.jtag({net_12[0], net_12[1], net_12[2], 
      net_12[4], net_12[3]}));
  scanFansFour__jtag_endcap jtag_end_6(.jtag({net_13[0], net_13[1], net_13[2], 
      net_13[4], net_13[3]}));
  scanFansFour__jtag_endcap jtag_end_7(.jtag({net_14[0], net_14[1], net_14[2], 
      net_14[4], net_14[3]}));
  scanFansFour__jtag_endcap jtag_end_8(.jtag({net_15[0], net_15[1], net_15[2], 
      net_15[4], net_15[3]}));
  scanFansFour__jtag_endcap jtag_end_9(.jtag({net_16[0], net_16[1], net_16[2], 
      net_16[4], net_16[3]}));
  scanFansFour__jtag_endcap jtag_end_10(.jtag({net_17[0], net_17[1], net_17[2], 
      net_17[4], net_17[3]}));
  scanFansFour__jtag_endcap jtag_end_11(.jtag({net_18[0], net_18[1], net_18[2], 
      net_18[4], net_18[3]}));
  scanFansFour__jtag_endcap jtag_end_12(.jtag({net_7[0], net_7[1], net_7[2], 
      net_7[4], net_7[3]}));
  scanFansFour__jtag_endcap jtag_end_13(.jtag({net_6[0], net_6[1], net_6[2], 
      net_6[4], net_6[3]}));
endmodule   
