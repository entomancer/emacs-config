;;; custom.el --- Custom's storage  -*- lexical-binding: t; -*-

;;; Commentary:
;; Written by `M-x customize' and by package.el.  Do not hand-edit: put
;; configuration in init.el or the other files in this directory instead.
;; init.el points `custom-file' here and loads it last.

;;; Code:

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.

 ;; The packages installed by `use-package ... :ensure'.  package.el keeps this
 ;; up to date as packages are installed; it is what `M-x package-autoremove'
 ;; consults to decide what is no longer wanted.
 '(package-selected-packages
   '(cape cider clojure-mode clojure-mode-extra-font-locking clojure-ts-mode
          consult corfu magit marginalia orderless rainbow-delimiters
          smartparens tagedit vertico)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;; custom.el ends here
