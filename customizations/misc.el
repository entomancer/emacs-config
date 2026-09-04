;;; misc.el --- hard-to-categorize settings  -*- lexical-binding: t; -*-

;;; Code:

(use-package emacs
  :ensure nil
  :custom
  ;; Answer yes/no prompts with y/n.  Since Emacs 28 this is a proper option
  ;; rather than the old (fset 'yes-or-no-p 'y-or-n-p) redefinition.
  (use-short-answers t)
  ;; No .#lockfiles alongside edited files.
  (create-lockfiles nil)
  ;; Straight to the scratch buffer on startup.
  (inhibit-startup-message t)
  ;; Never install a tree-sitter grammar behind your back, and never prompt for
  ;; one while opening a file.  This matters because `markdown-ts-mode'
  ;; highlights fenced code blocks using each language's own tree-sitter mode:
  ;; with the default `ask', opening a .md file containing a ```bash fence
  ;; prompts "Tree-sitter grammar for `bash' is missing; install it?", and in a
  ;; non-interactive context (a daemon, a batch run) that blocks forever waiting
  ;; for an answer.  With `never', code blocks whose grammar is absent simply
  ;; fall back to conventional font-lock.
  ;;
  ;; Install grammars deliberately instead:
  ;;   M-x treesit-install-language-grammar
  ;;   M-x markdown-ts-mode-install-parsers   (markdown + markdown-inline)
  ;;   M-x clojure-ts-reinstall-grammars      (clojure and friends)
  (treesit-auto-install-grammar 'never))

;; Shell script indentation.  (`sh-indentation' is an obsolete alias for
;; `sh-basic-offset' and has been dropped.)
(use-package sh-script
  :ensure nil
  :custom
  (sh-basic-offset 2))

(provide 'misc)
;;; misc.el ends here
