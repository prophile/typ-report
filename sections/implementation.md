Implementation
==============

\todo{Organise this section}

Idempotent
----------

For consistency as mentioned elsewhere\todo{explain where} in this report,
accumulation needs not just monoids on values, but idempotent monoids. There is
no typeclass for idempotent monoids anywhere within Haskell's standard
libraries\footnote{That is to say, libraries included with GHC or the Haskell
Platform}.

As a result, I wrote the typeclass as well as its common instances and factored
them out to a separate library, which then was published on Haskell's package
index, Hackage\cite{hackage:idempotent}.

