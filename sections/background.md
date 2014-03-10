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
as well Apfelmus's `reactive-banana`\cite{hackage:reactive-banana}
and Blackheath's `sodium`\cite{hackage:sodium}.

Following a slightly different route, there are a number of libraries
using Arrowised FRP (AFRP)\cite{afrp}\cite{arrowsRobots}, which is
heavily based on Hughes arrows\cite{arrows}.
`netwire`\cite{hackage:netwire} and `Yampa`\cite{hackage:yampa} are
probably the best known of these libraries.

Hughes Arrows
-------------

In 2000, Hughes introduced Hughes Arrows\cite{arrows}. 

