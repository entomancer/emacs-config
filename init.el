;;; init.el --- Emacs configuration entry point  -*- lexical-binding: t; -*-

;;; Commentary:
;; Bootstrap only: package archives, use-package, and the load order for the
;; files in customizations/.  Every package is declared in exactly one
;; `use-package' block inside one of those files -- there is no separate
;; package list to keep in sync.  See MODERNIZATION.md.

;;; Code:

;; ---------------------------------------------------------------------------
;; Indentation
;; ---------------------------------------------------------------------------
;; Set here rather than only in editing.el because package.el writes
;; custom.el through `indent-pp-sexp', which honours `indent-tabs-mode'.
;; With the default (t) the continuation lines of `package-selected-packages'
;; come out tab-indented, so any save made before editing.el has loaded
;; produces a whitespace-only diff against the spaces already in the file.
;; editing.el keeps its own declaration as the documented home for this.
(setq-default indent-tabs-mode nil)

;; ---------------------------------------------------------------------------
;; Package archives
;; ---------------------------------------------------------------------------
(require 'package)

(setopt package-archives
        '(("gnu"          . "https://elpa.gnu.org/packages/")
          ("nongnu"       . "https://elpa.nongnu.org/nongnu/")
          ("melpa"        . "https://melpa.org/packages/")
          ("melpa-stable" . "https://stable.melpa.org/packages/")))

;; CIDER and magit track the Clojure/git tooling closely; the stable channel
;; avoids breaking changes landing mid-session.
(setopt package-pinned-packages
        '((cider . "melpa-stable")
          (magit . "melpa-stable")))

(package-initialize)

;; MELPA keeps only the newest build of each package, so a cached index goes
;; stale: it names tarball URLs that have since 404'd, and installing anything
;; declared after the last refresh fails.  Refreshing only when there is no
;; cache at all (the usual `unless package-archive-contents') never notices.
;; Re-fetch once a day instead -- one network round trip per archive, on the
;; first startup of the day.
(defvar my/package-archive-max-age (* 24 60 60)
  "Seconds a cached package index may be used before it is re-fetched.")

(defun my/package-archives-stale-p ()
  "Return non-nil if any archive in `package-archives' has a missing or old index."
  (let ((cutoff (- (float-time) my/package-archive-max-age)))
    (seq-some
     (lambda (archive)
       (let ((index (expand-file-name
                     (format "archives/%s/archive-contents" (car archive))
                     package-user-dir)))
         (or (not (file-exists-p index))
             (< (float-time (file-attribute-modification-time
                             (file-attributes index)))
                cutoff))))
     package-archives)))

(when (or (null package-archive-contents)
          (my/package-archives-stale-p))
  (package-refresh-contents))

;; ---------------------------------------------------------------------------
;; use-package
;; ---------------------------------------------------------------------------
;; Built in since Emacs 29.  `use-package-always-ensure' makes every
;; `use-package' block install its package if missing, so declaring a package
;; and configuring it are the same act.  Built-in packages opt out with
;; `:ensure nil'.
(require 'use-package)
(setopt use-package-always-ensure t)

;; Note: `use-package-always-defer' is deliberately NOT set.  Deferral is
;; expressed per-package through :hook/:bind/:mode/:commands, which create the
;; autoloads that make it work.  Setting it globally makes global modes
;; silently fail to activate unless every block remembers :demand.

;; ---------------------------------------------------------------------------
;; Load path
;; ---------------------------------------------------------------------------
;; Drop hand-downloaded .el files in ~/.emacs.d/vendor to make them loadable.
(add-to-list 'load-path (expand-file-name "vendor" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "customizations" user-emacs-directory))

;; ---------------------------------------------------------------------------
;; Customization files
;; ---------------------------------------------------------------------------
;; Order matters in two places:
;;   navigation.el sets `completion-styles', which completion.el builds on.
;;   Everything else is independent.
(load "shell-integration.el")   ; exec-path-from-shell (macOS only)
(load "navigation.el")          ; vertico + orderless + marginalia + consult
(load "completion.el")          ; corfu + cape in-buffer completion popup
(load "ui.el")                  ; frame, theme, appearance
(load "editing.el")             ; general editing behavior and keys
(load "structural-editing.el")  ; smartparens everywhere, strict in lisp
(load "git.el")                 ; magit
(load "misc.el")                ; odds and ends
(load "elisp-editing.el")       ; eldoc for lisp modes
(load "setup-clojure.el")       ; clojure-mode + CIDER + eglot/clojure-lsp
(load "setup-js.el")            ; js, html, tagedit
(load "setup-python.el")        ; python-ts-mode + eglot/pyright + pet + ruff
(load "setup-jupyter.el")       ; jupyter REPL + org-babel jupyter-python
(load "markdown.el")            ; markdown-ts-mode

;; ---------------------------------------------------------------------------
;; Custom
;; ---------------------------------------------------------------------------
;; Give Custom its own file so that anything written by `M-x customize' (or by
;; package.el updating `package-selected-packages') never collides with the
;; hand-written configuration above.  Loaded last so Custom's values win.
(setopt custom-file
        (expand-file-name "customizations/custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;; init.el ends here
