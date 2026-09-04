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
  (inhibit-startup-message t))

;; Shell script indentation.  (`sh-indentation' is an obsolete alias for
;; `sh-basic-offset' and has been dropped.)
(use-package sh-script
  :ensure nil
  :custom
  (sh-basic-offset 2))

(provide 'misc)
;;; misc.el ends here
