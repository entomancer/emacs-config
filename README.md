# A Clojure-friendly Emacs configuration

Originally based on the `book1` branch of
[emacs-for-clojure](https://github.com/flyingmachine/emacs-for-clojure),
substantially rebuilt for Emacs 29+/30+/31.

New to Emacs? Start with
[this introductory tutorial](http://www.braveclojure.com/basic-emacs/), then
come back for the keybinding tables below.

---

## Requirements

| | | |
|---|---|---|
| **Emacs 29 or newer** | required | `use-package` and `eglot` are built in from 29 |
| `git` | required | for `magit`, and for building tree-sitter grammars |
| a C compiler (`cc`) | required | for building tree-sitter grammars |
| `rg` (ripgrep) | recommended | powers `C-c s` project search |
| `clojure-lsp` | for Clojure | static analysis and linting — see below |
| `lein` or the `clj` CLI + a JDK | for Clojure | for the REPL and classpath resolution |
| `basedpyright` or `pyright` | recommended for Python | LSP completion, hover and navigation — see below |
| `ruff` | recommended for Python | linting (via flymake) and format-on-save |
| `autoconf`, `automake`, `libtool`, `pkg-config` | required for Jupyter | build the `zmq` module's dynamic library — see below |
| A running Jupyter kernelspec (e.g. `pip install ipykernel`) | required for Jupyter | something for `jupyter-run-repl` to connect to |

Installing `basedpyright` and `ruff` (or via `pip install --user`/Homebrew if
you don't have `uv`):

```bash
uv tool install basedpyright
uv tool install ruff
```

Without either, Python files still edit fine — eglot falls back to `pyright`,
then to `pylsp` if that's on `PATH`, and ruff's flymake/format-on-save
integration simply stays quiet if `ruff` is missing.

Installing the Jupyter build toolchain (Homebrew shown; use your package
manager otherwise):

```bash
brew install autoconf automake libtool pkg-config
```

The `jupyter` package's `zmq` dependency is a C module. It first tries to
download a prebuilt binary matching your machine; if none matches (true for
current Apple Silicon at the time of writing), it falls back to building one
itself from a vendored copy of `libzmq`, which needs the four tools above
plus `git` and a C compiler (both already required). The build happens
automatically the first time a `zmq` function is called — expect a pause
(under a minute) the first time you start a REPL or run a Jupyter org-babel
block. Without a matching kernelspec (`jupyter kernelspec list` should show
at least one), `jupyter-run-repl` has nothing to connect to; installing
`ipykernel` into whichever Python environment you want to use, then running
`python -m ipykernel install --user`, registers one.

Installing `clojure-lsp` (Linux x86-64; adjust the asset name for other
platforms, or use your package manager):

```bash
TAG=2026.07.06-14.34.19
BASE=https://github.com/clojure-lsp/clojure-lsp/releases/download/$TAG
curl -sSL -O $BASE/clojure-lsp-native-static-linux-amd64.zip
unzip -o clojure-lsp-native-static-linux-amd64.zip
install -m 755 clojure-lsp ~/.local/bin/clojure-lsp
```

`~/.local/bin` must be on your `PATH`.

## Installing

1. Quit Emacs.
2. Move any existing `~/.emacs` or `~/.emacs.d` out of the way.
3. Put this directory at `~/.emacs.d`.
4. Start Emacs. Packages install themselves on first launch — it will take a
   minute and print a lot. Restart afterwards.

## Layout

`init.el` is a bootstrap only: package archives, `use-package`, load order,
and `custom-file`. Everything else lives in `customizations/`:

| File | Contents |
|------|----------|
| `shell-integration.el` | Inherits shell `PATH` on macOS |
| `navigation.el` | Minibuffer completion: vertico, orderless, marginalia, consult |
| `completion.el` | In-buffer completion popup: corfu, cape |
| `ui.el` | Theme, fonts, frame, chrome |
| `editing.el` | General editing behavior and keys |
| `structural-editing.el` | smartparens, everywhere |
| `git.el` | magit |
| `misc.el` | Odds and ends |
| `elisp-editing.el` | eldoc for lisp modes |
| `setup-clojure.el` | clojure-mode, CIDER, eglot/clojure-lsp |
| `setup-js.el` | JavaScript, HTML, tagedit |
| `setup-python.el` | python-ts-mode, eglot/basedpyright, pet, ruff |
| `setup-jupyter.el` | jupyter REPL + org-babel `jupyter-python` blocks |
| `markdown.el` | `markdown-ts-mode` |
| `custom.el` | Written by `M-x customize` — do not hand-edit |

Every package is declared in exactly one `use-package` block. There is no
separate package list to keep in sync.

---

## What's installed

### Completion

| Package | What it does |
|---------|--------------|
| **vertico** | Vertical candidate list in the minibuffer |
| **orderless** | Type fragments in any order — `buf kill` finds `kill-buffer` |
| **marginalia** | Docstrings, keybindings and file info in the margin |
| **consult** | Enhanced commands with live preview |
| **corfu** | The completion popup that appears as you type in a buffer |
| **cape** | Extra completion sources for corfu (file paths, words, keywords) |

vertico handles the *minibuffer*; corfu handles *in-buffer* completion. They
share orderless matching, so the same fragment-in-any-order search works in
both.

### Editing

| Package | What it does |
|---------|--------------|
| **smartparens** | Structural editing — see below. Strict in lisp, relaxed elsewhere |
| **rainbow-delimiters** | Colour-codes nesting depth in Clojure buffers |
| **tagedit** | Edit HTML tags as if they were expressions |
| **valign** | Visually aligns Markdown table columns without touching the file |

### Clojure

| Package | What it does |
|---------|--------------|
| **clojure-ts-mode** | The major mode, using Emacs' built-in tree-sitter parser |
| **clojure-mode** | The older regexp-based mode. Kept as a CIDER dependency and as the fallback when no grammar is available |
| **clojure-mode-extra-font-locking** | Extra `clojure.core` highlighting. Applies to `clojure-mode` only — `clojure-ts-mode` font-locks via tree-sitter, so this affects the fallback path alone |
| **cider** | REPL integration: eval, debug, test |
| **eglot** (built in) | LSP client, talks to `clojure-lsp` |

### Python

| Package | What it does |
|---------|--------------|
| **python** (built in) | `python-mode` and `python-ts-mode` both live here — see below |
| **eglot** (built in) | LSP client. Prefers `basedpyright`, then `pyright`, then `pylsp` |
| **pet** | Detects the project's virtualenv (uv, poetry, pdm, pipenv, conda, plain `venv`) and points eglot and `run-python` at its executables |
| **flymake-ruff** | Ruff lint diagnostics via flymake, alongside eglot's type diagnostics |
| **ruff-format** | Formats the buffer with `ruff format` on save |

### Jupyter

| Package | What it does |
|---------|--------------|
| **jupyter** | REPL (`jupyter-run-repl`) and org-babel `jupyter-LANG` source blocks, talking to a kernel directly over ZMQ |
| **zmq** | ZMQ bindings — a C module, built on first use. See Requirements above |

### Other

| Package | What it does |
|---------|--------------|
| **magit** | Git interface. Worth learning — it is the best reason to use Emacs |
| **exec-path-from-shell** | macOS only; installs only on macOS |

Emacs built-ins configured here: `project` (`C-x p`), `savehist`, `saveplace`,
`recentf`, `ibuffer`, `hippie-exp`, `flymake` (via eglot), `eldoc`,
`markdown-ts-mode`, `python.el`, `org` (babel only — no other org-mode config).

---

## Keybindings

### Finding things

| Key | Command |
|-----|---------|
| `C-x b` | Switch buffer — also lists recent files and bookmarks |
| `C-s` | Search this buffer, with live preview |
| `M-s l` | Same thing (the standard consult binding) |
| `C-c s` | Search the whole project (needs `rg`) |
| `M-g g` | Go to line |
| `M-g i` | Jump to a definition or heading in this file |
| `C-x C-b` | Classic buffer list |
| `C-x p f` | Find a file in the current project |
| `C-x p g` | Grep the current project |

`C-r` is still classic backward incremental search, and `C-M-s` / `C-M-r` are
plain (non-regexp) isearch.

### Editing

| Key | Command |
|-----|---------|
| `M-/` | Expand the word at point from the buffer, kill ring or lisp symbols |
| `C-;` | Comment or uncomment the current line |
| `C-x g` | **magit** — git status |

### In the completion popup

| Key | Action |
|-----|--------|
| `TAB` / `S-TAB` | Next / previous candidate |
| `RET` | Insert the selected candidate |
| `M-SPC` | Type a space without dismissing the popup (for orderless) |
| `M-h` | Show documentation for the selected candidate |
| `M-t` | Toggle the documentation panel |
| `M-g` | Jump to the candidate's source location |

### Structural editing (smartparens)

Active in **every** buffer. These are the ones that make it worthwhile:

| Key | Action |
|-----|--------|
| `C-<right>` | **Slurp** — pull the next expression *into* the parens |
| `C-<left>` | **Barf** — push the last expression *out* of the parens |
| `M-D` | **Splice** — remove the surrounding parens, keep the contents |
| `M-<delete>` | **Unwrap** the following expression |
| `C-M-f` / `C-M-b` | Move over a whole expression |
| `C-M-u` | Climb out to the enclosing expression |
| `C-M-d` | Descend into an expression |
| `C-M-k` / `C-M-w` | Kill / copy an expression |
| `C-M-SPC` | Mark an expression |
| `C-S-d` / `C-S-a` | Jump to the beginning / end of the current expression |
| `M-F` / `M-B` | Move by symbol |

Slurp and barf are the two that make the whole idea click — they let you
reshape code without ever touching an individual paren.

In `.el` and `.clj` files, **strict mode** is on: you cannot delete a paren if
it would unbalance the file. It feels like the editor is fighting you for about
a day, then you stop noticing. Everywhere else — JavaScript, HTML, prose —
deletion behaves normally.

`M-<backspace>` is kept as delete-previous-word, rather than smartparens'
default of backward-unwrap.

### Clojure

| Key | Command |
|-----|---------|
| `C-c M-j` | **Start a REPL** (`cider-jack-in-clj`) |
| `C-c M-c` | Connect to a running REPL |
| `C-c C-z` | Jump to the REPL buffer (and back) |
| `C-c C-k` | Load the current buffer into the REPL |
| `C-c C-e` | Evaluate the expression before point |
| `C-c C-c` | Evaluate the top-level form at point |
| `C-c C-d` | Documentation menu |
| `C-c C-t` | Test menu |
| `C-c M-n` | Namespace menu |
| `C-c C-q` | Quit the REPL |
| `C-c M-o` | Clear the REPL buffer (in the REPL) |
| `M-.` / `M-,` | Jump to definition / jump back |

### LSP (works with no REPL running)

| Command | Purpose |
|---------|---------|
| `M-.` | Jump to definition |
| `M-x xref-find-references` | Every use of a var across the project |
| `M-x eglot-rename` | Project-wide rename |
| `M-x eglot-code-actions` | Quick fixes, e.g. add a missing `require` |
| `M-x eglot-events-buffer` | Inspect raw LSP traffic when debugging |

The LSP table above applies to Python too — same eglot, same commands.

### Python

These are `python-mode'`s own bindings, already in place; nothing here is
custom.

| Key | Command |
|-----|---------|
| `C-c C-p` | **Start a REPL** (`run-python`) |
| `C-c C-z` | Jump to the REPL buffer (and back) |
| `C-c C-c` | Send the whole buffer to the REPL |
| `C-c C-r` | Send the active region to the REPL |
| `C-c C-e` | Send the current statement |
| `C-c C-b` | Send the current block |
| `C-M-x` | Send the top-level definition at point |

### Jupyter

`M-x jupyter-run-repl` prompts for a kernel name and opens a REPL buffer —
there's no keybinding for it, since starting a kernel isn't something you do
from inside a buffer the way `C-c C-p` is for `run-python`.

Once a buffer is associated with a REPL (`M-x jupyter-repl-associate-buffer`),
`jupyter-repl-interaction-mode` is active there and **shadows** the
`python-mode` bindings above — `C-c C-c` sends the region to Jupyter instead
of to the plain inferior-Python process, for instance.

| Key | Command |
|-----|---------|
| `C-M-x` | Evaluate the top-level definition at point |
| `M-i` | Inspect the symbol at point (opens `*Help*`) |
| `C-c C-b` | Evaluate the whole buffer |
| `C-c C-c` | Evaluate the region, or the current line if none is active |
| `C-c C-i` | Interrupt the kernel |
| `C-c C-r` | Restart the kernel |
| `C-c C-s` | Open a REPL scratch buffer |
| `C-c C-o` | Remove evaluation-result overlays |
| `C-c M-:` | Evaluate an arbitrary string |

In the REPL buffer itself: `M-n` / `M-p` for history, `C-s` / `C-s C-r` to
search it.

---

## Working with Clojure

Two systems run side by side, and it helps to know which is answering.

**CIDER** talks to a live REPL. It is runtime-accurate, sees through macros,
and knows about vars defined at runtime — but only while connected.

**clojure-lsp** statically analyses files on disk. It works with no REPL, sees
the whole project including namespaces you have not loaded, and provides
find-references, project-wide rename, and clj-kondo linting.

They are wired so that **CIDER answers when a REPL is connected, and
clojure-lsp answers otherwise**. This needs no thought from you: each CIDER
handler declines when there is no REPL, and the LSP picks up the slack.

In practice: open a `.clj` file and navigation, references and linting work
immediately. Run `C-c M-j` to start a REPL, and completion and documentation
quietly upgrade to runtime-accurate answers.

Linting is passive. clj-kondo (bundled inside clojure-lsp) underlines unused
bindings, wrong arities, shadowed names and bad `require`s as you type.

### tree-sitter

Clojure files open in `clojure-ts-mode`, which parses with Emacs' built-in
tree-sitter rather than regular expressions. That means more accurate
font-locking, indentation and expression navigation, especially in files that
confuse regexp-based parsing.

The switch is done with `major-mode-remap-alist`, guarded on grammar
availability — on a machine where the Clojure grammar has not been built, files
quietly open in the older `clojure-mode` instead of erroring. Grammars build
themselves on first use (they need `git` and a C compiler on `PATH`);
`M-x clojure-ts-reinstall-grammars` rebuilds or upgrades them.

Note that `clojure-ts-mode` derives from `prog-mode`, **not** from
`clojure-mode`, so `clojure-mode-hook` does not run in these buffers. This
config attaches its hooks to both modes. If you add a Clojure hook of your own,
hook `clojure-ts-mode` — or both.

**First run in a project is slow.** clojure-lsp resolves the classpath by
shelling out to `lein classpath` and then indexes everything, which can take
30-60 seconds. It runs in the background, so you can keep working, and results
are cached in `.lsp/.cache` inside the project — **add that to the project's
`.gitignore`.**

---

## Working with Python

Three tools divide the work, and unlike Clojure's CIDER/clojure-lsp pair,
they don't compete for the same question, so there is no arbitration to know
about — each just needs to already have the right executable path, which is
pet's job.

**eglot**, talking to `basedpyright` (or whichever fallback is on `PATH` — see
Requirements), gives completion, hover, jump-to-definition and type
diagnostics from static analysis.

**ruff** lints as you type, via flymake, and reformats the buffer on save.
Its diagnostics appear in the same fringe/margin as eglot's type errors —
flymake merges any number of backends, so both just show up together.

**pet** finds the project's virtualenv — however it was made: `uv`, `poetry`,
`pdm`, `pipenv`, `conda`, or a plain `python -m venv` — and points
`python-shell-interpreter`, eglot and ruff at that venv's binaries instead of
whatever Python happens to be first on `PATH`. This runs automatically;
there's nothing to invoke by hand. If a project's virtualenv isn't being
picked up, `M-x pet-verify-setup` in that buffer reports what pet found.
**pet does not create virtualenvs** — make one (`uv venv`, `python -m venv
.venv`, ...) and install dependencies into it first, and pet will find it.

Open a `.py` file and all three are live immediately — no equivalent of
CIDER's "start a REPL first" step. `run-python` (`C-c C-p`) is there too, for
actually executing code, but nothing else depends on it being running.

### tree-sitter

Python files open in `python-ts-mode` when the grammar is available, the same
`major-mode-remap-alist` + grammar-availability guard `setup-clojure.el` uses
for `clojure-ts-mode` — on a machine without the grammar built, files quietly
open in the regexp-based `python-mode` instead of an unhighlighted buffer.

One difference from Clojure: `python-mode` and `python-ts-mode` both derive
from the same `python-base-mode`, so `python-base-mode-hook` genuinely runs
for either — there's no need to attach hooks to both modes separately the way
`clojure-ts-mode` and `clojure-mode` require.

Grammars don't build themselves here (`treesit-auto-install-grammar` is
`never` — see Things worth knowing, below), and python.el only registers
python's grammar *recipe* once python.el itself has loaded — which happens
the first time you open a `.py` file. So: open any Python file once, then

```
M-x treesit-install-language-grammar RET python RET
```

to build it (needs `git` and a C compiler on `PATH`, same as Clojure's).
Restart Emacs afterwards for the remap to take effect.

---

## Working with Jupyter

Two frontends, both talking to a kernel directly over ZMQ rather than
through a Jupyter server — see the Keybindings section above for the full
command tables.

**`M-x jupyter-run-repl`** starts a kernel and opens a REPL buffer — code
in, rich output (images, LaTeX, HTML) back, same idea as `run-python` but
kernel-backed. `M-x jupyter-repl-associate-buffer` wires an existing Python
buffer to a running REPL so `C-c C-c` etc. send there instead.

**Org-babel `jupyter-python` source blocks** turn a `.org` file into a
literate notebook: code, prose and results (including inline plots) live in
the same document. Requires a `:session` header argument — see the
docstring of `org-babel-execute:jupyter-python` or jupyter's own README for
the full syntax. The first time you execute *any* babel source block in a
session, org asks whether to trust evaluating it — that's a standard
org-babel safety default (`org-confirm-babel-evaluate`), not specific to
Jupyter.

### Kernels don't know about `pet`

Unlike eglot and ruff (see Working with Python, above), a Jupyter kernel is
a separate process, not a buffer-local tool path — `pet` has no way to
influence which Python a kernel uses, because the kernel is chosen *before*
any buffer exists. A project's virtualenv only becomes available as a kernel
choice once you've registered it with `ipykernel` from inside that venv:

```bash
uv run --with ipykernel python -m ipykernel install --user --name=myproject
```

`jupyter kernelspec list` shows what's registered; `myproject` then appears
as a kernel-name option to `jupyter-run-repl` and as a `:kernel` header
argument value in org-babel blocks.

### No `.ipynb` file editing

This setup deliberately stops at the REPL and org-babel. Opening and editing
an actual `.ipynb` file as a notebook buffer is a different, harder problem,
and Emacs's answer to it is weak: the historical package, `ein`, is
self-described by its own maintainer as unmaintained ("crippled undo", no
LSP-like features) and points to an experimental successor,
[xjupyter](https://github.com/commercial-emacs/xjupyter), that isn't on
MELPA and ships no usage documentation — too immature to wire in
responsibly here.

If you need to actually edit an existing `.ipynb`'s content, the practical
option is [jupytext](https://jupytext.readthedocs.io/), which pairs a
notebook with a plain `.py` file (`# %%` cell markers) kept in sync on
save — that `.py` file gets everything `setup-python.el` already provides
(eglot, ruff, tree-sitter). It's a separate tool, not wired into this
config: `pip install jupytext`, then `jupytext --set-formats ipynb,py:percent
notebook.ipynb` to pair one, or `jupytext --sync` to resync after editing.

---

## Markdown

`.md` files open in `markdown-ts-mode`, which ships with Emacs 31. It gives
tree-sitter font-locking, heading folding, inline images and table editing, and
`visual-line-mode` is enabled so prose wraps at the window edge.

| Key | Action |
|-----|--------|
| `TAB` | Fold / unfold the section at point |
| `C-c C-x C-m` | Toggle markup hiding — hides the `**`, `_`, `#` clutter |
| `C-c C-x C-v` | Toggle inline images |
| `C-c C-c` | Toggle a `- [ ]` checkbox |
| `C-c C-n` / `C-c C-p` | Next / previous heading |
| `C-c C-u` | Up to the parent heading |
| `M-<up>` / `M-<down>` | Move the whole subtree |
| `M-<left>` / `M-<right>` | Promote / demote a heading |
| `M-g i` | Jump to any heading (imenu) |

For reading rather than editing, **`M-x markdown-ts-view-mode`** is a read-only
view with markup already hidden and images shown, navigable with plain `n`,
`p` and `u`.

### Tables

Two mechanisms, and they do different things:

- **valign** aligns table columns *visually*, using pixel-width display
  properties. The file on disk is never modified, so ragged Markdown source
  still displays as a neat table and no diff appears. It also handles
  proportional fonts and wide characters, which space padding cannot. Enabled
  automatically in both `markdown-ts-mode` and `markdown-ts-view-mode` — but
  **only on a graphical display**; valign is inert under `emacs -nw`, so the
  hook checks `display-graphic-p` first to avoid a message on every buffer.
  View mode particularly needs it: that mode sets
  `markdown-ts-enable-table-mode` to nil, so valign is the only thing aligning
  tables while you read.
- **`M-x markdown-ts-table-align-table`** aligns by *rewriting the buffer*,
  padding cells with spaces. Use it when you want the source itself aligned —
  for a file others will read as plain text. It also runs automatically while
  navigating cells (`markdown-ts-table-auto-align`). Note it produces `|Key |`
  rather than `| Key |`.

Table editing commands live on `C-c` bindings in `markdown-ts-mode-map`:
insert, clone, delete and move rows and columns, transpose, and export to
CSV/TSV (`markdown-ts-table-export-table-csv`).

Emacs itself calls this mode experimental — "a number of unresolved issues,
therefore Emacs does not yet enable it by default" — which is why it does not
claim `.md` on its own and this config does it explicitly. If it gives you
trouble, the mature third-party alternative is a one-line swap documented at the
top of `customizations/markdown.el`.

---

## Things worth knowing

**`C-s` is not isearch.** It runs `consult-line`, which searches the whole
buffer with a preview list rather than incrementally. `C-r` is still classic
backward isearch if you want the old behavior.

**Compiler warnings on first launch after installing a package.** Emacs
natively compiles new packages once, and many packages emit warnings from their
own source. They are harmless and do not come back. To silence them for future
installs, add to `init.el`:

```elisp
(setq native-comp-async-report-warnings-errors 'silent)
```

**Tree-sitter grammars never install themselves.** `treesit-auto-install-grammar`
is set to `never`. This matters because `markdown-ts-mode` highlights fenced code
blocks using each language's own tree-sitter mode: with the default `ask`,
opening a `.md` file containing a ` ```bash ` fence prompts to install the bash
grammar — and in a daemon or batch session that blocks forever waiting for an
answer. With `never`, a code block whose grammar is missing just falls back to
ordinary font-lock. Install grammars deliberately instead:

```
M-x treesit-install-language-grammar
M-x markdown-ts-mode-install-parsers    ; markdown + markdown-inline
M-x clojure-ts-reinstall-grammars       ; clojure and friends
M-x treesit-install-language-grammar RET python RET   ; after opening a .py file once
```

Currently installed: `clojure`, `markdown`, `markdown-inline`, `regex`,
`bash`, `python`.

**`:if` does not prevent `:ensure`.** If you add a platform-specific package,
guard the whole `use-package` form with `when`, not `:if` — `:ensure` runs
outside the conditional that `:if` produces, and will install the package on
every platform. See `shell-integration.el` for the pattern.

**`:custom` values on deferred packages apply on load, not at startup.**
`use-package` applies them through a custom theme, so a variable can read as
void until you first open a matching file. This is correct behavior, but
surprising if you check from `*scratch*`.

**Custom has its own file.** Anything set through `M-x customize` lands in
`customizations/custom.el`. Do not hand-edit it, and do not add
`custom-set-variables` blocks anywhere else — Emacs only honours one.

---

## Customizing

To add a package, write a `use-package` block in whichever file fits. It
installs itself on next launch:

```elisp
(use-package some-package
  :bind ("C-c x" . some-command)   ; also defers loading until first use
  :hook (prog-mode . some-mode)
  :custom
  (some-variable t))
```

Use `:hook`, `:bind`, `:mode` or `:commands` wherever you can — each one
creates an autoload, so the package does not load until it is actually needed.
Add `:ensure nil` for anything built into Emacs, and `:demand t` for packages
with no natural trigger.

To change where something lives, edit the `load` list at the bottom of
`init.el`. Order matters in one place: `navigation.el` sets `completion-styles`,
which `completion.el` builds on.

Drop hand-downloaded `.el` files into `vendor/` to put them on the load path.

## Version control

This directory is a git repository. Generated state — `elpa/`, `eln-cache/`,
`tree-sitter/`, `backups/` and the various state files — is ignored, because
packages reinstall themselves from the `use-package` declarations and grammars
rebuild on first use. So a clone plus one launch reproduces the whole setup.

`M-x package-autoremove` is safe to run: `customizations/custom.el` tracks the
packages this config declares, and everything else in `elpa/` is a dependency
of one of them.
