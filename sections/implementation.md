Implementation
==============

\label{chap:impl}

Most of the operations of the Wire type are the operations of the basic arrow
typeclasses. Wire is also an arrow transformer and an instance of the
`ArrowCircuit` typeclass\cite{automatonArrows}.

Beyond its typeclasses, given in Figure\ \ref{fig:wireTypeclasses}, `Wire` also
admits two other operations: `stepWire` and `accumulate`.

\begin{figure}

\begin{itemize}
 \item `Category` if the underlying arrow has an `Arrow` instance
 \item `Arrow` if the underlying arrow has an `Arrow` instance
 \item `ArrowChoice` if the underlying arrow has an `ArrowChoice` instance
 \item `ArrowZero` if the underlying arrow has an `ArrowZero` instance
 \item `ArrowPlus` if the underlying arrow has an `ArrowPlus` instance
 \item `ArrowTransformer` if the underlying arrow has an `Arrow` instance
\end{itemize}

\caption{The typeclasses of the \texttt{Wire} type.}
\label{fig:wireTypeclasses}
\end{figure}

Idempotent
----------

For consistency as mentioned elsewhere\todo{explain where} in this report,
accumulation needs not just monoids on values, but idempotent monoids. There is
no typeclass for idempotent monoids anywhere within Haskell's standard
libraries[^1].

[^1]: That is to say, libraries included with GHC or the Haskell platform.

As a result, I wrote the typeclass as well as its common instances and factored
them out to a separate library, which then was published on Haskell's package
index, Hackage\cite{hackage:idempotent} (see \ref{sub:hackage}).

Improving Arrows
----------------

Certain arrows are relatively heavyweight. This often stretches to
arrows which are created from the `arr` and `id` functions both of
which could be expected to be cheap, and certainly one might imagine
that they could be folded together.

Additionally, there are a number of typeclasses that all arrows
satisfy, but which it is tedious to enumerate for every arrow
implemented -- `Functor`, `Profunctor`\cite{hackage:profunctors},
`Strong` and `Applicative`\cite{applicatives} for all arrows as
well as `Alternative` (and `Monoid`, following the precedent set
by Paterson in the `arrows` package\cite{hackage:arrows}) for arrows
satisfying `ArrowPlus`, `Choice` for arrows satisfying `ArrowChoice`,
and others.

I introduced an arrow wrapper, `ImproveArrow`, which wraps any
existing arrow while providing cheap `arr` and `id` which are
necessarily fused, and providing the set of instances mentioned
above. As with the idempotent package, this was then published on
Hackage\cite{hackage:arrow-improve}. It is in some ways analogous
to the `CoYoneda`\cite{hackage:kan-extensions} type as it applies
to Functors, in that it folds mappings into single functions, albeit
mappings via composition and `arr` rather than `fmap`.

Practical Concerns
------------------

From a practical point of view, the development -- both of the main
implementation itself as well as the support libraries discussed above -- was
done using a number of tools.

### git

`git` is a distributed version control system\cite{ws:git}. It was written by Linus Torvalds to replace the BitKeeper source control system
for Linux\cite{gitTorvalds}, and is now used in a number of large projects and
by a number of large organisations\cite{ws:git}, including the University of
Southampton\cite{ws:sotonGit}.

I opted to use it as a matter of personal familiarity over other distributed
version control systems, although above centralised version control systems due
to a need to work in locations without access to the Internet.

### GitHub

\label{sub:github}

`GitHub` is a hosting service for `git` repositories\cite{ws:github}. As a large
company\cite{githubLargeBlog}\cite{githubLargeWSJ}, a certain degree of trust is
established for their not collapsing and losing data. For this reason, I opted
for them for hosting of the `git` repositories I used, although naturally I kept
mirrors within ECS.

### QuickCheck

QuickCheck is a property-based testing tool for Haskell\cite{quickcheck}. I used
it in the `idempotent` library to test the idempotence properties on each of the
instances, as well as the monoid properties of the `Min` and `Max` extrema
newtypes.

### Travis CI

Travis is a continous integration tool\cite{ws:travis}. It is tightly coupled to
GitHub\cite{ws:travisDocs}. I used it for automated builds and tests for all
parts of the project.

### Cabal

Cabal is a system for building and packaging Haskell libraries and
programs\cite{ws:cabal}. The various components I implemented each include the
necessary metadata[^meta] to be built and installed using Cabal.

[^meta]: The key files being `Setup.hs` and the main `.cabal` file which
contains the package metadata and build instructions\cite{ws:cabalUserGuide}.

### Haddock

Haddock is a documentation generation system for Haskell\cite{haddock},
analogous to Doxygen\cite{ws:doxygen} or Javadoc\cite{ws:javadoc}. Both the
`idempotent` and `arrow-improve` packages have Haddock documentation for all
exported modules, declarations and values.

### Hackage

\label{sub:hackage}

Hackage is a Haskell-specific package database\cite{ws:hackage}. It is analogous
to `npm`\cite{ws:npm} or PyPI\cite{ws:pypi}.

