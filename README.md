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

### Clojure

| Package | What it does |
|---------|--------------|
| **clojure-ts-mode** | The major mode, using Emacs' built-in tree-sitter parser |
| **clojure-mode** | The older regexp-based mode. Kept as a CIDER dependency and as the fallback when no grammar is available |
| **clojure-mode-extra-font-locking** | Extra `clojure.core` highlighting. Applies to `clojure-mode` only — `clojure-ts-mode` font-locks via tree-sitter, so this affects the fallback path alone |
| **cider** | REPL integration: eval, debug, test |
| **eglot** (built in) | LSP client, talks to `clojure-lsp` |

### Other

| Package | What it does |
|---------|--------------|
| **magit** | Git interface. Worth learning — it is the best reason to use Emacs |
| **exec-path-from-shell** | macOS only; installs only on macOS |

Emacs built-ins configured here: `project` (`C-x p`), `savehist`, `saveplace`,
`recentf`, `ibuffer`, `hippie-exp`, `flymake` (via eglot), `eldoc`,
`markdown-ts-mode`.

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
```

Currently installed: `clojure`, `markdown`, `markdown-inline`, `regex`, `bash`.

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
