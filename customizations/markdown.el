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
;; Grammar handling: `markdown-ts-mode--initialize' calls `treesit-ensure-installed'
;; for the markdown and markdown-inline grammars, but that consults
;; `treesit-auto-install-grammar', which misc.el sets to `never' -- so left
;; alone, the first .md file opened would just fall back to text-mode with a
;; warning.  The :config block below installs those two grammars eagerly at
;; startup instead, the same way use-package's :ensure installs a missing
;; package, rather than waiting for that first file.  This is deliberately
;; narrower than flipping the global `never': that setting exists so a fenced
;; code block in some *other*, unavailable language never blocks trying to
;; install that language's grammar too (see misc.el) -- this only ever
;; touches the two grammars markdown-ts-mode itself requires.
;;
;; To install by hand (also covers the optional html/yaml/toml grammars for
;; fenced code blocks, or to retry after a startup install fails, e.g. no
;; network at the time):
;;   M-x markdown-ts-mode-install-parsers

;;; Code:

(use-package markdown-ts-mode
  :ensure nil                           ; built into Emacs 31
  :demand t                             ; see :config -- needs the language-source
                                         ; entries this file registers at load time
  :mode (("\\.md\\'"       . markdown-ts-mode)
         ("\\.markdown\\'" . markdown-ts-mode))
  ;; Markdown is prose: wrap long lines at the window edge and navigate by
  ;; visual line, rather than letting paragraphs run off to the right.
  ;;
  ;; `markdown-ts-view-mode' must be listed separately.  It is defined with
  ;; `define-derived-mode ... nil' -- an explicitly blank parent -- so it runs
  ;; only `markdown-ts-view-mode-hook'; `markdown-ts-mode-hook' never fires
  ;; there.  The package calls `derived-mode-add-parents' for it, but as with
  ;; clojure-ts-mode that fixes `derived-mode-p' only, not hook execution.
  :hook ((markdown-ts-mode      . visual-line-mode)
         (markdown-ts-view-mode . visual-line-mode))
  :config
  (dolist (lang '(markdown markdown-inline))
    (unless (treesit-language-available-p lang)
      (treesit-install-language-grammar lang))))

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
  ;; Both modes, for the reason given above -- and view mode matters most here:
  ;; it sets `markdown-ts-enable-table-mode' to nil, disabling the built-in
  ;; aligner, so valign is the only thing aligning tables while reading.
  ;; valign wraps its edits in `with-silent-modifications', so the read-only
  ;; buffer is not an obstacle.
  :hook ((markdown-ts-mode      . my/valign-if-graphical)
         (markdown-ts-view-mode . my/valign-if-graphical))
  :custom
  ;; Draw the column separator as a full-height line rather than a bare "|".
  (valign-fancy-bar t))

(provide 'markdown)
;;; markdown.el ends here
