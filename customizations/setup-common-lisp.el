;;; setup-common-lisp.el --- Common Lisp editing + SLY  -*- lexical-binding: t; -*-
;;; Code:

;; ---------------------------------------------------------------------------
;; lisp-mode: built-in major mode for Common Lisp source.  Emacs' default
;; `auto-mode-alist' already maps .lisp/.asd to it, so nothing to add there.
;; Structural editing (smartparens-strict-mode) is already hooked onto
;; lisp-mode in structural-editing.el.
;; ---------------------------------------------------------------------------
(use-package rainbow-delimiters
  :hook (lisp-mode . rainbow-delimiters-mode))

;; eldoc-mode shows documentation in the minibuffer when writing code.  SLY
;; installs its own eldoc backend once a REPL is connected; this covers the
;; buffer before that too, same as the emacs-lisp-mode hook in
;; elisp-editing.el.
(add-hook 'lisp-mode-hook #'turn-on-eldoc-mode)

;; ---------------------------------------------------------------------------
;; SLY: the Common Lisp REPL / SWANK integration (SLIME's actively
;; maintained fork).  This is CIDER's counterpart -- sly-mode enables itself
;; automatically in lisp-mode buffers, no explicit hook required.
;; ---------------------------------------------------------------------------
(use-package sly
  :custom
  ;; Requires a Common Lisp implementation on PATH, e.g. `brew install sbcl'.
  ;; SBCL is the default: native-compiled, fastest, and what SLY itself is
  ;; most tested against.  Switch with `my/sly-use-clisp' below when testing
  ;; portability against a second implementation.
  (inferior-lisp-program "sbcl"))

(defun my/sly-use-clisp ()
  "Switch `inferior-lisp-program' to CLISP for the next `sly' connection.
Useful for portability testing: CLISP is stricter than SBCL about some
things SBCL is lax on.  Requires `brew install clisp'."
  (interactive)
  (setq inferior-lisp-program "clisp")
  (message "inferior-lisp-program set to clisp"))

(defun my/sly-use-sbcl ()
  "Switch `inferior-lisp-program' back to SBCL, the default."
  (interactive)
  (setq inferior-lisp-program "sbcl")
  (message "inferior-lisp-program set to sbcl"))

(provide 'setup-common-lisp)
;;; setup-common-lisp.el ends here
