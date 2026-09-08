;;; setup-jupyter.el --- Jupyter kernels: REPL + org-babel notebooks  -*- lexical-binding: t; -*-

;;; Commentary:
;; A live kernel REPL (`jupyter-run-repl') and org-babel `jupyter-LANG'
;; source blocks in .org files -- literate, notebook-style documents with
;; inline images/LaTeX/HTML, completion and code inspection, talking to a
;; kernel directly over ZMQ.
;;
;; Deliberately does NOT include opening actual .ipynb files as notebook
;; buffers. The package that does that, `ein', is self-described by its own
;; maintainer as unmaintained ("crippled undo", no LSP-like features), and
;; its suggested successor isn't on MELPA and ships no usage docs. See the
;; README for the fuller explanation and for jupytext as the practical way
;; to edit an existing .ipynb's content in Emacs instead.
;;
;; Does not know about `pet' (see setup-python.el) -- a kernel is a
;; standalone process, not a buffer-local venv lookup. A project's
;; virtualenv only becomes choosable as a kernel once ipykernel has
;; registered it from inside that venv: `python -m ipykernel install --user
;; --name=myproject'. See the README for the full explanation.

;;; Code:

;; ---------------------------------------------------------------------------
;; zmq: the C module `jupyter' talks to kernels through
;; ---------------------------------------------------------------------------
;; No config of its own. `jupyter' calls `zmq-load' the first time it needs
;; the module; that downloads a prebuilt binary for this machine if one
;; exists, or builds one from source (`git', a C compiler, and
;; autoconf/automake/libtool/pkg-config on PATH -- see the README) if not.
(use-package zmq)

;; ---------------------------------------------------------------------------
;; jupyter: REPL + org-babel frontends, direct to a local kernel
;; ---------------------------------------------------------------------------
(use-package jupyter
  :commands (jupyter-run-repl jupyter-connect-repl jupyter-repl-associate-buffer))

;; `ob-jupyter' (part of the `jupyter' package) has to be loaded via
;; `org-babel-do-load-languages' -- that call is what pulls it in, not
;; use-package's own deferral, so it has to run on its own rather than
;; inside jupyter's :config (which would only fire *after* something else
;; had already loaded jupyter). Deferred until `org' itself loads, which
;; happens the first time any .org file is opened.
(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   (append org-babel-load-languages '((jupyter . t)))))

(provide 'setup-jupyter)
;;; setup-jupyter.el ends here
