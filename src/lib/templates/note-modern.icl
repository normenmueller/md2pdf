% -----------------------------------
% Encodings
% -----------------------------------

\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}

% -----------------------------------
% Fonts & Icons
% -----------------------------------

\usepackage[scaled=0.96]{helvet}
\usepackage{courier}
\renewcommand{\familydefault}{\sfdefault}
\linespread{1.07}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0.5em}
\setlength{\marginparwidth}{26mm}
\setlength{\marginparsep}{6mm}
\addtolength{\textwidth}{0.8cm}
\addtolength{\oddsidemargin}{-0.4cm}
\addtolength{\evensidemargin}{-0.4cm}

% https://vavreckova.zam.slu.cz/didact/symbols/symboly/s_pifont_dvips.pdf?utm_source=chatgpt.com
\usepackage{pifont}
% https://markov.htwsaar.de/tex-archive/fonts/fontawesome5/doc/fontawesome5.pdf
\usepackage{fontawesome5}

\newcommand{\iconTldr}{\ding{228}}
\newcommand{\iconNote}{\ding{45}}
\newcommand{\iconInfo}{\faInfoCircle}
\newcommand{\iconHint}{\ding{43}}
\newcommand{\iconIHint}{\faExclamation}
\newcommand{\iconHelp}{\faLifeRing}
\newcommand{\iconQuestion}{\faQuestionCircle}
\newcommand{\iconQuote}{\ding{125}}
\newcommand{\iconTodo}{\faSquare[regular]}
\newcommand{\iconCheck}{\ding{51}}
\newcommand{\iconWater}{{\bfseries$\sim$}}
\newcommand{\iconCross}{\ding{55}}
\newcommand{\iconWarning}{\faExclamationTriangle}
\newcommand{\iconCWarning}{\faBolt}
\newcommand{\iconDanger}{\faSkullCrossbones}
\newcommand{\iconBug}{\faBug}
\newcommand{\iconDefinition}{\faBook}
\newcommand{\iconTerminus}{\faTag}
\newcommand{\iconAddendum}{\faPlusSquare}
\newcommand{\iconExample}{\faFlask}

% Alternative font: Noto Color Emoji
%\usepackage{fontspec}
%\newfontfamily\emoji{Apple Color Emoji}[Renderer=Harfbuzz]

\usepackage{soul}
\usepackage[normalem]{ulem}

% -----------------------------------
% The Multicol package
% -----------------------------------

\usepackage{multicol}

% -----------------------------------
% The Caption package
% -----------------------------------

\usepackage{caption}

% -----------------------------------
% The ToC package
% -----------------------------------

\usepackage{tocloft}
\setlength{\cftbeforesecskip}{1pt}     % spacing before \section entries
\setlength{\cftbeforesubsecskip}{0pt}  % spacing before \subsection entries
\makeatletter
\@ifpackageloaded{babel}{%
  \addto\captionsgerman{\renewcommand{\contentsname}{Inhaltsverzeichnis}}
  \addto\captionsngerman{\renewcommand{\contentsname}{Inhaltsverzeichnis}}
}{}
\makeatother
\usepackage[explicit]{titlesec}

%% Make "clones" of the commands
%\let\originalparagraph\paragraph
%\let\originalsubparagraph\subparagraph
%
%% Redefine the commands using the "clones"
%\renewcommand{\paragraph}[1]{\originalparagraph{#1}\hfill}
%\renewcommand{\subparagraph}[1]{\originalsubparagraph{#1}\hfill}

% -----------------------------------
% The Enum package
% -----------------------------------

\usepackage{enumitem}

% -----------------------------------
% The TikZ Package
% -----------------------------------

\usepackage{tikz}
\usepackage{tikz-cd}
\usetikzlibrary{arrows, arrows.meta, automata, calc, positioning, shapes.geometric, shapes.multipart, fit}

% -----------------------------------
% The Hyperref package
% -----------------------------------

\usepackage{hyperref}

\hypersetup{bookmarksdepth=5}

% -----------------------------------
% The Listings Package
% -----------------------------------

\usepackage{listings}
\lstset{
  inputencoding=utf8,
  basicstyle=\ttfamily\small,
  breaklines=true,
  frame=single,
  literate=
    {ä}{{\"a}}1
    {ö}{{\"o}}1
    {ü}{{\"u}}1
    {Ä}{{\"A}}1
    {Ö}{{\"O}}1
    {Ü}{{\"U}}1
    {ß}{{\ss}}1
}
\providecommand{\passthrough}[1]{#1}

\usepackage{float}
\floatstyle{plain}
\newfloat{codelisting}{htbp}{lol}
\floatname{codelisting}{Listing}

% -----------------------------------
% The Graphic Packages
% -----------------------------------

\usepackage{graphicx}

\usepackage{wrapfig}
\setlength{\intextsep}{0.5\baselineskip} % Distance between image and text at top/bottom
\setlength{\columnsep}{1em}              % Distance between image and text

% -----------------------------------
% The Xcolor Packages
% -----------------------------------

\usepackage[table,x11names]{xcolor}
\definecolor{lnPrimary}{RGB}{211,47,47}
\definecolor{lnAccent}{RGB}{255,193,7}
\definecolor{lnMuted}{gray}{0.45}
\definecolor{lnInk}{RGB}{28,31,38}
\color{lnInk}

\titleformat{\section}
  {\Large\bfseries\color{lnPrimary}}
  {\colorbox{lnPrimary!15}{\makebox[2.6em][c]{\thesection}}}
  {0.7em}
  {#1}
\titleformat{\subsection}
  {\large\bfseries\color{lnPrimary!85!black}}
  {\color{lnMuted}\thesubsection}
  {0.6em}
  {#1}
\titleformat{\subsubsection}
  {\normalsize\bfseries\color{lnPrimary!65!black}}
  {\color{lnMuted}\thesubsubsection}
  {0.6em}
  {#1}
\titleformat{\paragraph}[block]
  {\normalsize\bfseries\color{lnPrimary!65!black}}
  {\color{lnMuted}\theparagraph}
  {0.6em}
  {#1}
\titleformat{\subparagraph}[block]
  {\normalsize\bfseries\color{lnPrimary!65!black}}
  {\color{lnMuted}\thesubparagraph}
  {0.6em}
  {#1}
\titlespacing*{\section}{0pt}{2.2ex plus .5ex minus .2ex}{0.8ex}
\titlespacing*{\subsection}{0pt}{1.7ex plus .4ex minus .2ex}{0.6ex}
\titlespacing*{\subsubsection}{0pt}{1.3ex plus .3ex minus .2ex}{0.5ex}
\titlespacing*{\paragraph}{0pt}{1.1ex plus .3ex minus .2ex}{0.55ex}
\titlespacing*{\subparagraph}{0pt}{1.0ex plus .3ex minus .2ex}{0.5ex}
\hypersetup{
  colorlinks=true,
  linkcolor=lnPrimary,
  urlcolor=lnPrimary!75!black,
  citecolor=lnPrimary
}

% -----------------------------------
% Mark/highlight styling
% -----------------------------------

% Tune these to shrink/expand the highlight band.
\newcommand{\mdPdfMarkDepth}{0.3ex}
\newcommand{\mdPdfMarkHeight}{2.2ex}
\newcommand{\mdPdfMarkOverlap}{0pt}
\newcommand{\mdPdfMarkRaise}{0.1ex}

\makeatletter
\renewcommand{\SOUL@hlpreamble}{%
  \setul{\mdPdfMarkDepth}{\mdPdfMarkHeight}%
  \setuloverlap{\mdPdfMarkOverlap}%
  \let\SOUL@stcolor\SOUL@hlcolor
  \SOUL@stpreamble
}

\DeclareRobustCommand{\mdPdfMark}[2]{%
  \begingroup
    \def\mdPdfMarkHex{#1}%
    \edef\mdPdfMarkName{mdPdfMark\mdPdfMarkHex}%
    \expandafter\@ifundefined\expandafter{color@\mdPdfMarkName}{%
      \expandafter\definecolor\expandafter{\mdPdfMarkName}{HTML}{\mdPdfMarkHex}%
    }{}%
    \sethlcolor{\mdPdfMarkName}%
    \def\SOUL@ulunderline##1{{%
      \setbox\z@\hbox{##1}%
      \SOUL@dimen=\wd\z@
      \SOUL@dimeni=\SOUL@uloverlap
      \advance\SOUL@dimen2\SOUL@dimeni
      \rlap{%
        \null
        \kern-\SOUL@dimeni
        \raise\mdPdfMarkRaise\hbox{%
          \SOUL@ulcolor{\SOUL@ulleaders\hskip\SOUL@dimen\kern\z@}%
        }%
      }%
      \unhcopy\z@
    }}%
    \hl{#2}%
  \endgroup
}
\makeatother

% Light gray
\definecolor{ocGryBack}{HTML}{F8F8FB}
\definecolor{ocGryFrame}{HTML}{C7C7D1}
\definecolor{ocGryTitle}{HTML}{2E2E3A}

% Light yellow
\definecolor{ocYelBack}{HTML}{FFFBE8}
\definecolor{ocYelFrame}{HTML}{FFE39A}
\definecolor{ocYelTitle}{HTML}{B38A2C}

% Light orange
\definecolor{ocOrgBack}{HTML}{FFF4E5}
\definecolor{ocOrgFrame}{HTML}{FFC28C}
\definecolor{ocOrgTitle}{HTML}{BF6B30}

% Light red
\definecolor{ocRedBack}{HTML}{FDECEE}
\definecolor{ocRedFrame}{HTML}{F5A5A8}
\definecolor{ocRedTitle}{HTML}{B4555A}

% Strong red
\definecolor{ocRed2Back}{HTML}{FFE9E9}
\definecolor{ocRed2Frame}{HTML}{E67373}
\definecolor{ocRed2Title}{HTML}{7F3434}

% Light green
\definecolor{ocGreBack}{HTML}{EEFBF1}
\definecolor{ocGreFrame}{HTML}{A4E4B0}
\definecolor{ocGreTitle}{HTML}{4F9963}

% Light cyan
\definecolor{ocCynBack}{HTML}{E7FAFF}
\definecolor{ocCynFrame}{HTML}{8ED5E6}
\definecolor{ocCynTitle}{HTML}{3A92A3}

% Light pink
\definecolor{ocPinBack}{HTML}{FDF1FF}
\definecolor{ocPinFrame}{HTML}{EB9CFF}
\definecolor{ocPinTitle}{HTML}{7A2F9B}

% Light lavender
\definecolor{ocLavBack}{HTML}{F4EEFF}
\definecolor{ocLavFrame}{HTML}{BFA6FF}
\definecolor{ocLavTitle}{HTML}{4A38A9}

% Light blue
\definecolor{ocBluBack}{HTML}{EEF4FF}
\definecolor{ocBluFrame}{HTML}{A6C3FF}
\definecolor{ocBluTitle}{HTML}{2F548E}

% -----------------------------------
% Table styling (Pandoc tables)
% -----------------------------------

\usepackage{booktabs}   % Pandoc uses this for LaTeX tables
\usepackage{colortbl}   % optional; \rowcolor works with xcolor[table]
\usepackage{etoolbox}   % for environment hooks

% Colors for tables
\definecolor{TableHeader}{RGB}{251,239,239} % header background
\definecolor{TableRowOdd}{RGB}{255,249,246} % odd rows
\definecolor{TableRowEven}{RGB}{255,255,255} % even rows
\definecolor{TableLine}{RGB}{230,198,198}   % rule color

% Line style (top/mid/bottom rules)
\arrayrulecolor{TableLine}
\setlength{\arrayrulewidth}{0.3pt}

% Header row: grey background
\let\oldtoprule\toprule
\renewcommand{\toprule}{%
  \oldtoprule
  \rowcolor{TableHeader}%
}

% Zebra striping for body rows in longtable
\AtBeginEnvironment{longtable}{%
  % avoid paragraph spacing inside p{} columns (prevents "phantom" blank rows)
  \setlength{\parskip}{0pt}%
  % start striping at row 2 (header row stays explicitly coloured)
  \rowcolors{2}{TableRowOdd}{TableRowEven}%
}
\makeatletter
% Stop striping before \bottomrule to avoid a shaded "phantom" row.
\pretocmd{\endlastfoot}{\hiderowcolors}{}{}
\makeatother
\AtEndEnvironment{longtable}{%
  % reset striping
  \hiderowcolors%
}

% -----------------------------------
% The TColor Box Package
% -----------------------------------

\usepackage[most]{tcolorbox}

\newtcolorbox{mdblockquote}{
  breakable,
  enhanced,
  sharp corners,
  colback=lnPrimary!4!white,
  colframe=lnPrimary!45!black,
  boxrule=0.25pt,
  borderline west={1.8pt}{0pt}{lnPrimary},
  left=2.6mm,
  right=2.6mm,
  top=1.3mm,
  bottom=1.3mm
}

\renewenvironment{quote}
  {\list{}{\leftmargin=5mm \rightmargin=5mm}\item\relax\begin{mdblockquote}\itshape}
  {\end{mdblockquote}\endlist}

% -----------------------------------
% The Awesome Boxes Package
% -----------------------------------

\usepackage{awesomebox}

% -----------------------------------
% The Appendix package
% -----------------------------------

\usepackage[toc,page]{appendix}

% -----------------------------------
% The usual math stuff
% -----------------------------------

\usepackage{wasysym}
\usepackage{amsthm,mathrsfs,thmtools}

\theoremstyle{plain} \newtheorem{terminus}{Terminus}[section]
\theoremstyle{plain} \newtheorem{definition}{Definition}[section]
\theoremstyle{plain} \newtheorem{theorem}{Theorem}[section]

\newcommand\graph[1]{\ensuremath{\mathscr{#1}}}
\newcommand\category[1]{\ensuremath{\mathcal{#1}}}
\newcommand\rel[1]{\ensuremath{\mathit{#1}}}
\newcommand\type[1]{\ensuremath{\mathnormal{#1}}}

\newcommand{\fullcir}{\CIRCLE}
\newcommand{\halfcir}{\LEFTcircle}
\newcommand{\emptycir}{\Circle}
\newcommand{\invtri}{\ensuremath{\blacktriangledown}}
