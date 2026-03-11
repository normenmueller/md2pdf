# TikZ Example

```{.tikz width=0.5\linewidth height=4cm scale=0.8 caption="Fit Test" label="fig:fit-test" placement="ht"}
\usepackage{tikz-cd}
\usetikzlibrary{fit,positioning}

\begin{document}
\begin{tikzpicture}
  \node (a) {A};
  \node (b) [right=of a] {B};
  \node[draw, fit=(a)(b)] (box) {};
\end{tikzpicture}
\end{document}
```

```tikz {scale=0.6}
\begin{tikzpicture}[>=Stealth]
  \node (x) at (0,0) {X};
  \node (y) at (2,0) {Y};
  \draw[->] (x) -- (y);
\end{tikzpicture}
```
