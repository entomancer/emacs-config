;;; ui.el --- appearance and frame settings  -*- lexical-binding: t; -*-

;;; Commentary:
;; How Emacs looks, and which chrome is switched off.

;;; Code:

;; ---------------------------------------------------------------------------
;; Chrome and frame
;; ---------------------------------------------------------------------------
(use-package emacs
  :ensure nil
  :custom
  ;; Full path in the title bar.
  (frame-title-format "%b (%f)")
  ;; No audible or visual bell.
  (ring-bell-function #'ignore)
  ;; Killing and yanking interact with the system clipboard.  (The old
  ;; x-select-enable-* names have been obsolete aliases since Emacs 25.1.)
  (select-enable-clipboard t)
  (select-enable-primary t)
  ;; If something is selected in another program and then killed in Emacs
  ;; before pasting, keep the outside selection in the kill ring.
  (save-interprogram-paste-before-kill t)
  ;; Show every option in apropos results.
  (apropos-do-all t)
  ;; Mouse yank goes to point rather than to the click position.
  (mouse-yank-at-point t)
  :bind
  ;; Don't pop up the font menu.
  ("s-t" . ignore)
  :config
  ;; The menu bar is distracting; the toolbar and scroll bars are redundant.
  (menu-bar-mode -1)
  (when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
  (when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
  ;; Cursor blinking is distracting.
  (blink-cursor-mode 0)
  ;; Larger default font for readability.
  (set-face-attribute 'default nil :height 140))

;; ---------------------------------------------------------------------------
;; Line numbers
;; ---------------------------------------------------------------------------
;; `global-linum-mode' was removed in Emacs 29.1; this is its replacement.
(use-package display-line-numbers
  :ensure nil
  :init
  (global-display-line-numbers-mode 1))

;; ---------------------------------------------------------------------------
;; Theme
;; ---------------------------------------------------------------------------
;; The hand-vendored themes in ~/.emacs.d/themes are no longer the active
;; theme, but stay on the load path as a fallback: M-x load-theme
;; tomorrow-night-bright.
(use-package custom
  :ensure nil
  :config
  (let ((theme-dir (expand-file-name "themes" user-emacs-directory)))
    (add-to-list 'custom-theme-load-path theme-dir)
    (add-to-list 'load-path theme-dir)))

;; Catppuccin ships one theme whose palette is chosen by `catppuccin-flavor':
;; latte (light), frappe, macchiato, mocha (darkest).  Set it before loading,
;; which `:custom' guarantees -- it runs ahead of `:config'.
(use-package catppuccin-theme
  :custom
  (catppuccin-flavor 'mocha)
  :config
  (load-theme 'catppuccin t))

(provide 'ui)
;;; ui.el ends here
