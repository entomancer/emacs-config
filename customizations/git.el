;;; git.el --- git integration  -*- lexical-binding: t; -*-

;;; Code:

;; Fully deferred: :bind creates the autoload, so magit loads the first time
;; C-x g is pressed.  Pinned to melpa-stable in init.el.
(use-package magit
  :bind ("C-x g" . magit-status))

(provide 'git)
;;; git.el ends here
