Background
==========

Functional Reactive Programming was originally developed in
1997 by Elliott and Hudak\cite{frAnimation}. It has since been
developed in a number of different libraries and systems.

Microsoft created a system for their C#\cite{lang:csharp} language
based on FRP concepts called the Reactive Extensions, or `Rx`\cite{rx}.
This was then later ported to JavaScript\cite{lang:javascript} under
the name `RxJS`.

There are other FRP libraries for JavaScript, including
`Bacon.js`\cite{ws:bacon}.

FRP has been implemented in domain-specific langauges for a variety
of applications, including applications on the web. `Elm`\cite{ws:elm}
is one example of such a language, as is `Flapjax`\cite{flapjax}.

In Haskell\cite{lang:haskell}, the language on which I will focus
for most of the rest of this report, there is a veritable smorgasbord
of different implementations. Based on the original types as described
by Elliott and Hudak\cite{frAnimation} and later revisited by Elliott
in his paper "Push-Pull Functional Reactive Programming"\cite{pushPull},
one finds Elliott's own `reactive`\cite{hackage:reactive} library,
as well `reactive-banana`\cite{hackage:reactive-banana} and
`sodium`\cite{hackage:sodium}.

Following a slightly different route, there are a number of libraries
using Arrowised FRP (AFRP)\cite{afrp}\cite{arrowsRobots}, which is
heavily based on Hughes arrows\cite{arrows}.
`netwire`\cite{hackage:netwire} and `Yampa`\cite{hackage:yampa} are
probably the best known of these libraries.

Hughes Arrows
-------------

In 2000, Hughes introduced Arrows\cite{arrows}. Arrows are a generalised type
for computation, more powerful than applicative functors but less powerful than
monads\cite{applicatives}. A basic arrow, implementing the `Arrow` typeclass,
can be considered a cartesian monoidal category with a functor from
`Hask`[^mon]. The `Arrow` typeclass as originally given by Hughes is given in
Figure\ \ref{fig:hughesTypeclass}, and the current typeclass hierarchy
implemented by Paterson is given in Figure\ \ref{fig:patersonTypeclass}.

[^mon]: `arr` gives the functor from `Hask`, `>>>` and `arr id` are the
composition and identities as a category, and `first` permits products.

\begin{figure}
\begin{lstlisting}
class Arrow a where
  (>>>) :: a b c -> a c d -> a b d
  first :: a b c -> a (b, d) (c, d)
  arr :: (b -> c) -> a b c
\end{lstlisting}

\caption{The \texttt{Arrow} typeclass, \`{a} la Hughes.}
\label{fig:hughesTypeclass}
\end{figure}

\begin{figure}
\begin{lstlisting}
class Category a where
  id :: a b b
  (.) :: a c d -> a b c -> a b d

class (Category a) => Arrow a where
  arr :: (b -> c) -> a b c
  first :: a b c -> a (b, d) (c, d)

(>>>) = flip (.)
\end{lstlisting}

\caption{The \texttt{Arrow} and \texttt{Category} typeclasses, \`{a} la
Paterson.}
\label{fig:patersonTypeclass}
\end{figure}

`Hask` itself is an `Arrow`, with `arr` as the identity; there is also the
`Kleisli` data type for constructing the Kleisli category from a monad, which is
also necessarily an `Arrow`\cite{kleisli}.

Hughes arrows are further generalised with five typeclasses which have `Arrow`
as a superclass: `ArrowZero` and `ArrowPlus` which between them add a monoid
structure to Arrows akin to `MonadPlus`, `ArrowLoop` which adds a form of
recursion to arrows, and `ArrowChoice` and `ArrowApply` which respectively give
arrows with coproducts and exponentials. Instances of the `ArrowApply` typeclass
are equivalent to monads.

The use of arrows in Haskell is simplified by arrow notation. Arrow notation is
a language extension with syntactic sugar for arrows\cite{arrowNotation},
simplifying programming with arrows in much the same way that
`do`-notation\cite{lang:haskell} simplifies programming with monads.

Arrows have been used for dataflow languages\cite{arrowNotation}, XML
processing\cite{hxt}, annotating IO with static information\cite{applicatives},
and functional reactive programming\cite{afrp}.

"Traditional" FRP
-----------------

The traditional model of FRP as introduced by Hudak and Elliott --
or, at least, the discrete variant -- uses two types, described in
Figure\ \ref{fig:tfrpRS}\cite{pushPull}. In this context, `Future`
refers to some notion of a value which will appear at a future point
in time, analogous to promises\cite{promises}.

\begin{figure}

\begin{lstlisting}
data Reactive a = a `Stepper` Event a
newtype Event a = Event (Future (Reactive a))
\end{lstlisting}

\caption{Traditional FRP Reactives and Signals.}
\label{fig:tfrpRS}
\end{figure}

There are two important observations to make here. Firstly, the
shape of `Reactive` betrays a underlying structure: it is the cofree
comonad\cite{cofree} on futures. The instance for the `Functor`
typeclass for `Reactive` as described by Elliott is matched by this
definition[^par].  When there is a monoid (`Alternative`) structure
on the functor, the cofree comonad construction also yields an
instance for `Monad` -- and by extension `Applicative` -- which
also conforms to Elliott's definition.

[^par]: This is unsurprising -- a Haskell data type can have at most one valid
instance for Functor\cite{parametricFunctor}.

Secondly, if `Future` is representable[^rep] (represented by some
type `i`) then `Signal` is a Mealy machine\cite{elliottMealy} and
`Reactive` is a Moore machine\cite{hackage:free}, both of which
have their values of `a` as the output alphabet and values of `i`
as the input alphabet.

[^rep]: Isomorphic to `(->) r` for some `r`. The type `r` is said to *represent*
the functor.

The `Applicative` instance for `Reactive` derives from the `Monad`
instance via the usual
mechanism\cite{applicatives}\cite{denotationalDesign}, and therein
lies the issue with glitches and traditional reactives: the monad
instance from the monoid on Future inevitably leads to a cascade
of outputs for each input. This phenomenon is known as the Brock-Ackerman
anomaly\cite{brockAckerman}.

The monad instance, as mentioned, derives from a monoid on `Future`:
a monoid which represents the "first" event of a pair of events. A
future is in essence an occurrence of an event, that is, the product
of the data it carries with time.

There are two things to immediately note about the monoid. Firstly,
that the monoid must be *idempotent*. Were one to ask which came
first of two of the same occurrence, one would not expect any answer
other than that of the very occurrence. Secondly, neither of the
arguments to the monoid operation should have any bias towards it,
which would make the monoid unfair: that is to say, the monoid
should be *commutative*.

Behaviours
----------

Elliott describes a type `Behaviour a` which has the semantics of
a function from times to `a`\cite{pushPull}. It is not uncommon for
times to be taken as real numbers. If we restrict times to the
natural numbers to model discrete points of time rather than
continuous time, however, `Behaviour a` (being represented by the
natural numbers) is then isomorphic to an infinite stream of
`a`\cite{streamRep}. Restriction to the discrete case, however,
removes most of the motivation for the "pull" part of Elliott's
"push-pull" model, so these `Behaviour`s are no more interesting
than `Reactive`s.

