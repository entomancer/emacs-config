;;; setup-python.el --- Python editing  -*- lexical-binding: t; -*-

;;; Commentary:
;; eglot (LSP) + pet (virtualenv detection) + ruff (lint & format), the same
;; division of labour as Clojure's CIDER/clojure-lsp split but simpler: Python
;; has no REPL-vs-static-analysis arbitration to do, because `python-mode'
;; ships its own inferior-Python REPL (`run-python' and friends) with nothing
;; to wire up.
;;
;; Unlike Clojure, tree-sitter and regexp-based editing live in the SAME
;; package here -- python.el defines both `python-mode' and `python-ts-mode'
;; -- so there is only one `use-package' form for the major mode, not two.

;;; Code:

;; ---------------------------------------------------------------------------
;; python / python-ts-mode
;; ---------------------------------------------------------------------------
(use-package python
  :ensure nil                          ; built into Emacs
  :init
  ;; Emacs 31's python.el registers (python-mode . python-ts-mode) into the
  ;; new `treesit-major-mode-remap-alist' unconditionally, on every startup,
  ;; regardless of whether the grammar is actually built -- that alist is
  ;; just a registry; nothing reads it unless the user opts in via
  ;; `treesit-enabled-modes', so on its own it does nothing.  If a grammar
  ;; genuinely is missing, `python-ts-mode' itself degrades badly rather than
  ;; falling back: it never sets `font-lock-defaults' outside its treesit
  ;; branch, so an unguarded remap would silently trade regexp highlighting
  ;; for none.  Guarding here, directly on `major-mode-remap-alist' -- the
  ;; alist `set-auto-mode' actually consults -- is the same pattern
  ;; `clojure-ts-mode' uses in setup-clojure.el, and it must happen in
  ;; `:init', before the first .py file triggers `set-auto-mode'.
  (when (and (fboundp 'treesit-language-available-p)
             (treesit-language-available-p 'python))
    (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode)))
  ;; `python-mode' and `python-ts-mode' both derive from `python-base-mode'
  ;; (unlike `clojure-ts-mode', which only derives from `prog-mode'), so
  ;; `python-base-mode-hook' genuinely runs for both -- one hook covers
  ;; everything below instead of the two separate entries Clojure needs.
  :hook ((python-base-mode . subword-mode)  ; M-f / M-b stop at PascalCase
         (python-base-mode . eglot-ensure)))

;; ---------------------------------------------------------------------------
;; eglot: prefer a modern type-checking server over whatever's on PATH
;; ---------------------------------------------------------------------------
;; eglot already ships a long alternation list for Python (pylsp, pyright,
;; basedpyright, ruff server, ty, pyrefly, jedi-language-server, ...) and
;; connects to whichever it finds first. Left alone, that means the editing
;; experience quietly depends on what happens to already be on PATH -- e.g.
;; the jedi-based `pylsp' that ships with Anaconda. Pin it explicitly
;; instead, the same way clojure-lsp is a named requirement rather than
;; "whatever's on PATH": basedpyright first (faster, more actively
;; developed), plain pyright next, `pylsp' last as a no-install-required
;; fallback. `add-to-list' prepends, so this entry is tried before the
;; built-in default one further down `eglot-server-programs'.
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `((python-mode python-ts-mode)
                 . ,(eglot-alternatives
                     '(("basedpyright-langserver" "--stdio")
                       ("pyright-langserver" "--stdio")
                       "pylsp")))))

;; ---------------------------------------------------------------------------
;; pet: find the right venv, automatically
;; ---------------------------------------------------------------------------
;; Unlike Clojure's classpath (resolved once per project by clojure-lsp
;; shelling out to `lein classpath'), Python's "which interpreter, which
;; packages" question is answered by a venv that can be named and placed
;; differently by every tool -- uv, poetry, pdm, pipenv, conda, or a bare
;; `python -m venv'. `pet-mode' detects whichever one a project uses and
;; points `python-shell-interpreter' and eglot at its binaries, buffer-
;; locally, so LSP completion and `run-python' both see the project's actual
;; dependencies instead of whatever Python happens to be first on PATH.
;;
;; `-10' runs this ahead of the other hooks on `python-base-mode-hook'
;; (default depth 0) -- eglot, flymake-ruff and ruff-format-on-save-mode
;; below all need pet's buffer-local paths already in place before they look
;; for an executable. This is pet's own documented setup incantation, not
;; use-package sugar, since :hook has no way to express a depth.
(use-package pet
  :init
  (add-hook 'python-base-mode-hook #'pet-mode -10))

;; ---------------------------------------------------------------------------
;; ruff: linting (via flymake) and formatting
;; ---------------------------------------------------------------------------
;; ruff replaces flake8 + isort + black-the-linter-part with one fast binary.
;; It runs alongside eglot's own diagnostics rather than instead of them --
;; flymake merges any number of backends -- so basedpyright's type errors and
;; ruff's style/lint findings appear together with no arbitration needed
;; (unlike Clojure's completion-at-point, where only one backend can answer
;; at a time).
(use-package flymake-ruff
  :hook (python-base-mode . flymake-ruff-load)
  :config
  ;; pet doesn't know about flymake-ruff -- it's not in pet's supported-
  ;; package list, only `ruff-format' is -- so point it at the venv's ruff
  ;; by hand, the same way pet's own manual-setup examples do for the
  ;; packages it doesn't cover automatically.
  (defun my/flymake-ruff-use-pet-executable ()
    "Point flymake-ruff at the `ruff' resolved by `pet' for this venv."
    (when-let* ((ruff (pet-executable-find "ruff")))
      (setq-local flymake-ruff-program ruff)))
  (add-hook 'python-base-mode-hook #'my/flymake-ruff-use-pet-executable))

;; `ruff-format-on-save-mode' is a `reformatter'-generated minor mode; pet
;; DOES know about `ruff-format' and already points `ruff-format-command' at
;; the venv's ruff as part of `pet-mode' above, so no bridging function is
;; needed here the way flymake-ruff needed one.
(use-package ruff-format
  :hook (python-base-mode . ruff-format-on-save-mode))

(provide 'setup-python)
;;; setup-python.el ends here
