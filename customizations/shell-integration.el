;;; shell-integration.el --- inherit the shell environment  -*- lexical-binding: t; -*-

;;; Commentary:
;; On macOS a GUI Emacs is not started from a shell, so it does not inherit
;; PATH and friends.  This copies them across.
;; https://github.com/purcell/exec-path-from-shell

;;; Code:

;; The `when' wrapper is load-bearing.  A `:if' keyword would gate only the
;; configuration: `use-package-handler/:ensure' pushes the install call onto the
;; front of the generated body, outside the :if conditional, so :if alone still
;; installs the package on every platform.  Keeping the whole form inside `when'
;; means it is never even macro-expanded off macOS.
(when (memq window-system '(mac ns))
  (use-package exec-path-from-shell
    :config
    (exec-path-from-shell-initialize)
    (exec-path-from-shell-copy-envs '("PATH"))))

(provide 'shell-integration)
;;; shell-integration.el ends here
