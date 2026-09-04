;;; setup-clojure.el --- Clojure editing + CIDER  -*- lexical-binding: t; -*-
;;; Code:

;; ---------------------------------------------------------------------------
;; clojure-mode: major mode for Clojure source
;; ---------------------------------------------------------------------------
;; Colour-codes nesting depth.  Declared here rather than only referenced from
;; another package's :hook, so that something actually installs it.
(use-package rainbow-delimiters
  :hook ((clojure-mode    . rainbow-delimiters-mode)
         (clojure-ts-mode . rainbow-delimiters-mode)))

(use-package clojure-mode
  :hook ((clojure-mode . smartparens-strict-mode)
         ;; subword-mode lets M-f / M-b stop at CamelCase boundaries,
         ;; which helps when working with Java interop names.
         (clojure-mode . subword-mode)))

;; Extra syntax highlighting for clojure.core and friends.  It has no config of
;; its own; loading it after clojure-mode is the whole integration.
(use-package clojure-mode-extra-font-locking
  :after clojure-mode
  :demand t)

;; ---------------------------------------------------------------------------
;; clojure-ts-mode: the tree-sitter major mode
;; ---------------------------------------------------------------------------
;; Uses Emacs' built-in tree-sitter parser instead of clojure-mode's regexp
;; machinery, which gives more accurate font-locking, indentation and
;; navigation.  clojure-mode stays installed: CIDER depends on it, and it is
;; the fallback when a tree-sitter grammar is unavailable.
;;
;; Grammars install themselves on first use, because `clojure-ts-ensure-grammars'
;; defaults to t; the package builds them with git and a C compiler, both of
;; which must be on PATH.  To (re)build them by hand, or to upgrade them after
;; a clojure-ts-mode update:  M-x clojure-ts-reinstall-grammars
;;
;; NOTE: no `:after clojure-mode' here.  `major-mode-remap-alist' has to be
;; populated before the first .clj file is opened, and `set-auto-mode' consults
;; it at that moment.  Deferring :init until clojure-mode loads is too late --
;; clojure-mode loads *because* the file was opened, by which point the remap
;; has already been missed.
(use-package clojure-ts-mode
  :init
  ;; `major-mode-remap-alist' is the Emacs 29+ idiom for tree-sitter modes:
  ;; `auto-mode-alist' keeps pointing at clojure-mode and the remap happens at
  ;; mode-activation time.  Guarding on grammar availability means a machine
  ;; without the grammar quietly falls back to clojure-mode rather than
  ;; erroring on every .clj file.
  (when (and (fboundp 'treesit-language-available-p)
             (treesit-language-available-p 'clojure))
    (dolist (remap '((clojure-mode       . clojure-ts-mode)
                     (clojurescript-mode . clojure-ts-clojurescript-mode)
                     (clojurec-mode      . clojure-ts-clojurec-mode)))
      (add-to-list 'major-mode-remap-alist remap)))
  ;; These hooks duplicate the clojure-mode ones on purpose.  clojure-ts-mode
  ;; derives from `prog-mode', NOT from clojure-mode, so `clojure-mode-hook'
  ;; does not run in these buffers -- verified by inspection, not assumed.
  ;; The package calls `derived-mode-add-parents' so that
  ;; (derived-mode-p 'clojure-mode) still answers t, which is what CIDER and
  ;; `my/clojure-eldoc-first-wins' below rely on, but that affects predicates
  ;; only, not hook execution.
  ;;
  ;; clojure-ts-clojurescript-mode and clojure-ts-clojurec-mode derive from
  ;; clojure-ts-mode, so they inherit everything below.
  :hook ((clojure-ts-mode . eglot-ensure)
         (clojure-ts-mode . subword-mode)
         (clojure-ts-mode . smartparens-strict-mode)))

;; ---------------------------------------------------------------------------
;; CIDER: the Clojure REPL / nREPL integration
;; ---------------------------------------------------------------------------
(use-package cider
  :hook (cider-mode . eldoc-mode)   ; minibuffer docs for the form at point
  :custom
  ;; Go to the REPL buffer when it finishes connecting.
  (cider-repl-pop-to-buffer-on-connect t)
  ;; Don't print the help banner in the REPL on each connect.
  (cider-repl-display-help-banner nil)
  ;; Pretty-print evaluation results in the REPL.
  (cider-repl-use-pretty-printing t)
  ;; On error, show the error buffer and switch to it.
  (cider-show-error-buffer t)
  (cider-auto-select-error-buffer t)
  :config
  ;; A couple of REPL keybindings from the book1 config.  In use-package
  ;; these belong in a :bind on cider-repl-mode-map, which also removes the
  ;; need for the old (eval-after-load 'cider ...) wrapper.
  ;; Adjust or remove to taste.
  :bind (:map cider-repl-mode-map
              ("C-c M-o" . cider-repl-clear-buffer)))

;; ---------------------------------------------------------------------------
;; eglot + clojure-lsp: static analysis alongside CIDER's runtime tooling
;; ---------------------------------------------------------------------------
;; CIDER answers from a live REPL (runtime-accurate, sees through macros);
;; clojure-lsp answers from static analysis of files on disk (works with no
;; REPL, sees the whole project, and brings clj-kondo linting, find-references
;; and project-wide rename).  Both offer completion, eldoc and xref.
;;
;; Arbitration is simpler than it looks: `cider-complete-at-point',
;; `cider--xref-backend' and `cider-eldoc' each return nil when no REPL is
;; connected, so merely ordering CIDER ahead of eglot gives CIDER's answers
;; when connected and the LSP's otherwise.  Two of the three already order
;; correctly without help:
;;
;;   xref  -- CIDER registers at depth -90 (`cider-xref-fn-depth'), eglot at 0.
;;   eldoc -- eglot appends its functions; CIDER prepends.
;;
;; So only completion needs a nudge, plus the eldoc display strategy.

(defun my/cider-completion-before-eglot ()
  "Order CIDER's completion ahead of eglot's in this buffer.
Both register at depth 0, so without this the winner depends on
which minor mode happened to load last."
  (add-hook 'completion-at-point-functions #'cider-complete-at-point -90 t))

(defun my/clojure-eldoc-first-wins ()
  "Show a single eldoc source rather than CIDER's and the LSP's stacked.
eglot sets `eldoc-documentation-strategy' to `eldoc-documentation-compose',
which would render both at once."
  (when (derived-mode-p 'clojure-mode)
    (setq-local eldoc-documentation-strategy #'eldoc-documentation-enthusiast)))

(use-package eglot
  :ensure nil                          ; built into Emacs 29+
  :hook ((clojure-mode       . eglot-ensure)
         (cider-mode         . my/cider-completion-before-eglot)
         (eglot-managed-mode . my/clojure-eldoc-first-wins))
  :custom
  ;; Connect in the background: clojure-lsp's first run in a project resolves
  ;; the classpath (via `lein classpath') and indexes, which can take a while.
  (eglot-sync-connect nil)
  ;; clojure-lsp reports indexing progress continuously; keep it out of the
  ;; echo area.
  (eglot-report-progress nil))
