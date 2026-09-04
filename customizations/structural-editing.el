;;; structural-editing.el --- smartparens everywhere  -*- lexical-binding: t; -*-
;;; Commentary:
;; Replaces paredit.  `smartparens-global-mode' gives autopair, sexp
;; navigation, slurp/barf and unwrap in every buffer;
;; `smartparens-strict-mode' adds paredit's balance guarantee -- deletion
;; and kill commands refuse to leave delimiters unbalanced -- in lisp
;; buffers only.
;;
;; Strict mode is implemented entirely as [remap] entries (kill-line ->
;; sp-kill-hybrid-sexp and friends), so it layers on top of the global
;; bindings below without conflicting with them.
;;; Code:

(use-package smartparens
  :demand t                             ; it's a global mode; nothing to defer
  :hook ((emacs-lisp-mode       . smartparens-strict-mode)
         (lisp-mode             . smartparens-strict-mode)
         (lisp-interaction-mode . smartparens-strict-mode)
         (ielm-mode             . smartparens-strict-mode)
         (scheme-mode           . smartparens-strict-mode)
         (eval-expression-minibuffer-setup . smartparens-strict-mode))
  :config
  ;; Language-aware pair definitions: no ' pairing in lisp, template
  ;; literal and JSX handling in js, and so on.  Ships inside the package.
  (require 'smartparens-config)

  ;; Installs smartparens' own keybindings (C-M-* navigation,
  ;; C-<right>/C-<left> slurp/barf, M-D splice, ...) into
  ;; `smartparens-mode-map', which is now live in every buffer.
  (sp-use-smartparens-bindings)

  ;; ...but sp-use-smartparens-bindings claims M-<backspace> for
  ;; sp-backward-unwrap-sexp, which is a bad trade: backward-kill-word is
  ;; an all-day key in every buffer, while backward-unwrap is occasional
  ;; and still reachable on M-<delete> and C-M-<backspace>.
  (define-key smartparens-mode-map (kbd "M-<backspace>") #'backward-kill-word)

  (smartparens-global-mode 1))

(provide 'structural-editing)
;;; structural-editing.el ends here
