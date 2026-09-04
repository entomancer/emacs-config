;;; navigation.el --- minibuffer completion and navigation  -*- lexical-binding: t; -*-

;;; Commentary:
;; The modern minibuffer completion stack, replacing the original ido setup:
;;
;;   vertico    -- vertical completion UI
;;   orderless  -- space-separated, any-order matching
;;   marginalia -- annotations in the completion margin
;;   consult    -- enhanced commands with live preview
;;
;; completion.el builds the in-buffer popup (corfu) on the `completion-styles'
;; set here, so this file must load first.

;;; Code:

;; ---------------------------------------------------------------------------
;; Vertico: vertical completion UI in the minibuffer
;; ---------------------------------------------------------------------------
(use-package vertico
  :init
  (vertico-mode 1)
  :custom
  (vertico-count 12)
  ;; Cycle with C-n / C-p past the top and bottom.
  (vertico-cycle t))

;; ---------------------------------------------------------------------------
;; Orderless: space-separated, any-order matching
;; ---------------------------------------------------------------------------
;; :demand because `completion-styles' names the style but the package must be
;; loaded for it to resolve -- there is no command or hook to trigger it.
(use-package orderless
  :demand t
  :custom
  (completion-styles '(orderless basic))
  ;; Keep partial-completion for file paths: nicer directory navigation.
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; ---------------------------------------------------------------------------
;; Marginalia: docstrings, keybindings and file info in the margin
;; ---------------------------------------------------------------------------
(use-package marginalia
  :init
  (marginalia-mode 1))

;; ---------------------------------------------------------------------------
;; Consult: enhanced commands with live preview
;; ---------------------------------------------------------------------------
;; Entirely deferred: :bind creates autoloads, so consult does not load until
;; the first time one of these keys is pressed.
(use-package consult
  :bind (("C-x b"   . consult-buffer)      ; buffers + recent files + bookmarks
         ("C-s"     . consult-line)        ; in-buffer search with preview
         ("M-s l"   . consult-line)        ; the standard consult binding too
         ("M-g g"   . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g i"   . consult-imenu)       ; jump to definition/heading
         ("C-c s"   . consult-ripgrep)))   ; project search (needs rg on PATH)

;; ---------------------------------------------------------------------------
;; Built-ins
;; ---------------------------------------------------------------------------
;; Persist minibuffer history so recent choices sort to the top.
(use-package savehist
  :ensure nil
  :init
  (savehist-mode 1))

;; Track recently opened files.  `consult-buffer' has a recent-files source
;; (`consult-source-recent-file') which is inert without this -- C-x b silently
;; offers no recent files at all until recentf-mode is on.
(use-package recentf
  :ensure nil
  :init
  (recentf-mode 1)
  :custom
  (recentf-max-saved-items 200)
  (recentf-save-file (expand-file-name "recentf" user-emacs-directory)))

;; The classic buffer list, kept from the original config.
(use-package ibuffer
  :ensure nil
  :bind ("C-x C-b" . ibuffer))

;; Built-in project support, on the C-x p prefix: C-x p f (find file),
;; C-x p g (grep), C-x p p (switch project).  Replaces projectile, which this
;; config carried without ever enabling it.
(use-package project
  :ensure nil)

(provide 'navigation)
;;; navigation.el ends here
