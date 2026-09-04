;;; setup-js.el --- javascript and html  -*- lexical-binding: t; -*-

;;; Code:

;; ---------------------------------------------------------------------------
;; JavaScript
;; ---------------------------------------------------------------------------
;; `.js' already maps to js-mode in the default `auto-mode-alist', so only the
;; settings below are needed.  subword-mode makes M-f / M-b stop at CamelCase
;; boundaries.
(use-package js
  :ensure nil
  :hook (js-mode . subword-mode)
  :custom
  (js-indent-level 2))

;; ---------------------------------------------------------------------------
;; HTML
;; ---------------------------------------------------------------------------
(use-package sgml-mode
  :ensure nil
  :hook (html-mode . subword-mode))

;; tagedit: edit html tags as if they were sexps.  Note this is independent of
;; paredit/smartparens -- `tagedit-add-paredit-like-keybindings' only borrows
;; paredit's key *names*.  In html-mode both tagedit and smartparens are live
;; and both bind C-<right>/C-<left>; tagedit wins, which is what you want there.
(use-package tagedit
  :hook (html-mode . tagedit-mode)
  :config
  (tagedit-add-paredit-like-keybindings))

(provide 'setup-js)
;;; setup-js.el ends here
