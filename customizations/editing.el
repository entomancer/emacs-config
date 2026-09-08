;;; editing.el --- general editing behavior  -*- lexical-binding: t; -*-

;;; Commentary:
;; Editing behavior that is not specific to any language.  Structural editing
;; (smartparens) lives in structural-editing.el.

;;; Code:

;; ---------------------------------------------------------------------------
;; Small commands
;; ---------------------------------------------------------------------------
;; Defined before the `use-package emacs' block below, which binds them.
;; `:bind' emits (unless (fboundp 'CMD) (autoload 'CMD "emacs" ...)) -- and an
;; autoload pointing at a file named "emacs" would never resolve.  Defining
;; them first makes that fboundp check skip the autoload entirely.

(defun toggle-comment-on-line ()
  "Comment or uncomment the current line."
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))

(defun die-tabs ()
  "Replace every tab in the buffer with spaces, two columns per tab."
  (interactive)
  (setq-local tab-width 2)
  (untabify (point-min) (point-max)))

;; Workaround for an old macOS kill/yank error.  Guarded so it does not
;; redefine anything on other systems, where it was dead code.
(when (eq system-type 'darwin)
  (defun ns-get-pasteboard ()
    "Return the value of the pasteboard, or nil for unsupported formats."
    (condition-case nil
        (ns-get-selection-internal 'CLIPBOARD)
      (quit nil))))

;; ---------------------------------------------------------------------------
;; Core editing behavior
;; ---------------------------------------------------------------------------
(use-package emacs
  :ensure nil
  :custom
  ;; Never insert hard tabs.  init.el also sets this before the package
  ;; bootstrap, so that it holds for any custom.el save that happens
  ;; before this file loads; this declaration is the documented home.
  (indent-tabs-mode nil)
  ;; Keep backups out of the working directory.
  (backup-directory-alist
   `(("." . ,(expand-file-name "backups" user-emacs-directory))))
  (auto-save-default nil)
  ;; With auto-save off there is nothing to recover, so don't leave a
  ;; recovery-list directory behind on every session.  (Deleting
  ;; auto-save-list/ does not help -- Emacs recreates it at startup.)
  (auto-save-list-file-prefix nil)
  :bind
  (("C-;"   . toggle-comment-on-line)
   ;; C-s is `consult-line' (see navigation.el).  These keep the native
   ;; incremental search reachable.
   ("C-r"   . isearch-backward-regexp)
   ("C-M-s" . isearch-forward)
   ("C-M-r" . isearch-backward))
  :config
  ;; Highlight the matching parenthesis, and the current line.
  (show-paren-mode 1)
  (global-hl-line-mode 1)
  ;; Electric indent reindents the previous line on RET, which fights manual
  ;; formatting.  Call the mode function rather than setting the variable --
  ;; setting the variable alone leaves the mode's hooks installed.
  (electric-indent-mode -1))

;; ---------------------------------------------------------------------------
;; hippie-expand: completion from the buffer, kill ring and lisp symbols
;; ---------------------------------------------------------------------------
(use-package hippie-exp
  :ensure nil
  :bind ("M-/" . hippie-expand)
  :custom
  (hippie-expand-try-functions-list
   '(try-expand-dabbrev
     try-expand-dabbrev-all-buffers
     try-expand-dabbrev-from-kill
     try-complete-lisp-symbol-partially
     try-complete-lisp-symbol)))

;; ---------------------------------------------------------------------------
;; saveplace: return to where you left off in a file
;; ---------------------------------------------------------------------------
(use-package saveplace
  :ensure nil
  :init
  ;; `save-place-mode' is the modern entry point; the old idiom was
  ;; (setq-default save-place t).
  (save-place-mode 1)
  :custom
  (save-place-file (expand-file-name "places" user-emacs-directory)))

(provide 'editing)
;;; editing.el ends here
