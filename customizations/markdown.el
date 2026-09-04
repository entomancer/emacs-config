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

;; ---------------------------------------------------------------------------
;; valign: visually align table columns
;; ---------------------------------------------------------------------------
;; markdown-ts-mode can align tables, but it does so by rewriting the buffer --
;; padding cells with spaces (`M-x markdown-ts-table-align-table', and
;; automatically during cell navigation, see `markdown-ts-table-auto-align').
;; valign instead aligns them visually, using pixel-width `display' properties,
;; so the file on disk is never touched and no diff appears.  It also copes
;; with proportional fonts and wide characters, which space padding cannot.
;;
;; Both approaches coexist fine; this just means tables look right without
;; having to reformat them.
(defun my/valign-if-graphical ()
  "Enable `valign-mode', but only on a graphical display.
valign aligns using pixel widths, so it is inert in a terminal -- and
would otherwise print \='no effect in non-graphical display\=' into the
echo area for every Markdown buffer opened under `emacs -nw'."
  (when (display-graphic-p)
    (valign-mode 1)))

(use-package valign
  :hook (markdown-ts-mode . my/valign-if-graphical)
  :custom
  ;; Draw the column separator as a full-height line rather than a bare "|".
  (valign-fancy-bar t))

(provide 'markdown)
;;; markdown.el ends here
