;;; completion.el --- in-buffer completion (corfu + cape)  -*- lexical-binding: t; -*-

;;; Commentary:
;; In-buffer completion popup, the sibling of the vertico/orderless
;; minibuffer stack set up in navigation.el.  corfu provides the popup UI;
;; cape provides completion-at-point sources to feed it.
;;
;; Requires `use-package` and `use-package-always-ensure` to be configured
;; in init.el (see MODERNIZATION.md).  With :ensure on, corfu and cape do
;; NOT need to be added to the my-packages list — the blocks below install
;; them.

;;; Code:

;; ---------------------------------------------------------------------------
;; Corfu: the in-buffer completion popup
;; ---------------------------------------------------------------------------
(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  ;; Show the popup automatically as you type, not just on TAB.
  (corfu-auto t)
  ;; Wait until 2 chars before popping up (less noise on short tokens).
  (corfu-auto-prefix 2)
  ;; Short idle delay before the popup appears.
  (corfu-auto-delay 0.15)
  ;; Cycle through candidates with C-n / C-p past the ends.
  (corfu-cycle t)
  ;; Keep the popup open while no candidate matches, so you can keep typing.
  (corfu-quit-no-match 'separator)
  ;; Preselect the first candidate (except the prompt) rather than nothing.
  (corfu-preselect 'prompt)
  :bind
  ;; Within the popup: RET to insert, TAB/S-TAB to move, M-SPC to insert
  ;; a separator (used with orderless — see below).
  (:map corfu-map
        ("M-SPC" . corfu-insert-separator)
        ("RET"   . corfu-insert)
        ("TAB"   . corfu-next)
        ([tab]   . corfu-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous)))

;; Show a documentation panel next to the popup for the selected candidate.
;; It auto-shows after a short delay; M-t toggles it, M-h shows the docs for
;; the current candidate and M-g jumps to its source.  (corfu-popupinfo-map
;; remaps corfu's own M-h/M-g so they render in the panel.)
(use-package corfu-popupinfo
  :ensure nil                ; ships inside the corfu package, no separate install
  :after corfu
  :init
  (corfu-popupinfo-mode)
  :custom
  (corfu-popupinfo-delay '(0.4 . 0.2)))

;; ---------------------------------------------------------------------------
;; Cape: completion-at-point sources that feed corfu
;; ---------------------------------------------------------------------------
(use-package cape
  :init
  ;; Add a few generally-useful sources to the global list.
  ;; Order matters: earlier sources are tried first.
  (add-to-list 'completion-at-point-functions #'cape-file)     ; file paths
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)  ; words in open buffers
  (add-to-list 'completion-at-point-functions #'cape-keyword)) ; language keywords

;; ---------------------------------------------------------------------------
;; Make TAB do completion in prog modes (optional but recommended)
;; ---------------------------------------------------------------------------
;; By default TAB indents.  This makes TAB indent when appropriate and
;; complete otherwise, which is the behavior most people want while coding.
(setq tab-always-indent 'complete)

;; ---------------------------------------------------------------------------
;; Orderless in the popup
;; ---------------------------------------------------------------------------
;; navigation.el already sets completion-styles to include orderless, which
;; corfu picks up automatically — so the same any-order fuzzy matching works
;; in the in-buffer popup.  Use M-SPC inside the popup to type a space
;; separator without dismissing it.

(provide 'completion)
;;; completion.el ends here
