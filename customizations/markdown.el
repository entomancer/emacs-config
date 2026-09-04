;;; markdown.el --- Markdown  -*- lexical-binding: t; -*-

;;; Commentary:
;; `markdown-ts-mode' ships with Emacs 31 but deliberately does not claim
;; `auto-mode-alist' -- its own docstring calls it "an experimental mode that
;; has a number of unresolved issues, therefore Emacs does not yet enable it by
;; default".  In practice it is capable: tree-sitter font-locking, outline
;; folding, markup hiding, inline images, table editing and imenu headings.
;;
;; If it misbehaves, the mature third-party alternative is a drop-in swap:
;;   (use-package markdown-mode :mode ("\\.md\\'" . markdown-mode))
;; markdown-mode additionally offers `gfm-mode' and live HTML preview, which
;; need an external processor such as pandoc.
;;
;; No :bind here on purpose -- `markdown-ts-mode-map' already covers the ground:
;;
;;   TAB               fold / unfold the section at point
;;   C-c C-x C-m       toggle markup hiding (the **, _, # clutter)
;;   C-c C-x C-v       toggle inline images
;;   C-c C-c           toggle a "- [ ]" checkbox
;;   C-c C-n / C-c C-p next / previous heading
;;   C-c C-u           up to the parent heading
;;   M-<up> / M-<down> move the whole subtree
;;   M-<left>/M-<right>  promote / demote a heading
;;   C-c C-v n / p     next / previous code block
;;
;; For reading rather than editing, `M-x markdown-ts-view-mode' gives a
;; read-only view with markup hidden and images shown, navigable with plain
;; n / p / u.
;;
;; Grammar handling needs no guard here: `markdown-ts-mode--initialize' calls
;; `treesit-ensure-installed' for the markdown and markdown-inline grammars,
;; and falls back to text-mode with a warning if they cannot be built.  (This
;; differs from clojure-ts-mode in setup-clojure.el, which needs an explicit
;; availability check.)  To install them by hand:
;;   M-x markdown-ts-mode-install-parsers

;;; Code:

(use-package markdown-ts-mode
  :ensure nil                           ; built into Emacs 31
  :mode (("\\.md\\'"       . markdown-ts-mode)
         ("\\.markdown\\'" . markdown-ts-mode))
  ;; Markdown is prose: wrap long lines at the window edge and navigate by
  ;; visual line, rather than letting paragraphs run off to the right.
  :hook (markdown-ts-mode . visual-line-mode))

(provide 'markdown)
;;; markdown.el ends here
