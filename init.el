;;; init.el --- -*- lexical-binding: t -*-

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

;; tweaking for speedup
(setq gc-cons-threshold (* 1024 1024 1024))
(setq gcmh-high-cons-threshold (* 1024 1024 1024))
(setq gcmh-idle-delay-factor 20)
(setq jit-lock-defer-time 0.05)
(setq read-process-output-max (* 1024 1024))
(setq package-native-compile t)

(setq mac-command-modifier 'meta)

(set-frame-font "Iosevka Term 17" nil t)
(setq-default cursor-type 'bar)
(set-cursor-color "#7532a8")

(add-to-list 'load-path "~/.emacs.d/site-lisp/use-package")
(require 'use-package)

(with-eval-after-load 'info
  (info-initialize)
  (add-to-list 'Info-directory-list
               "~/.emacs.d/site-lisp/use-package/"))

(use-package fontify-face
  :ensure t)

(use-package diminish
  :ensure t)

(use-package nano-theme
  :load-path "site-lisp/nano-theme"
  :config
  (load-theme 'nano t)
  )

;;(use-package nano-modeline
;;  :load-path "site-lisp/nano-modeline"
;;  :config
;;  (nano-modeline nil t))

(use-package auto-save
  :load-path "site-lisp/auto-save"
  :config
  (auto-save-enable)
  (setq auto-save-silent t)   ; quietly save
  (setq auto-save-delete-trailing-whitespace t)  ; automatically delete spaces at the end of the line when saving
  )


(use-package reveal-in-osx-finder
  :ensure t)

(use-package better-defaults
  :ensure t
  :config (setq visible-bell nil)
          (setq ring-bell-function 'ignore)
          (show-paren-mode 0)
          (defalias 'yes-or-no-p 'y-or-n-p))

(use-package mood-line
  :ensure t
  :config (mood-line-mode))

(use-package exec-path-from-shell
  :if (memq window-system '(ns mac))
  :ensure t
  :config (exec-path-from-shell-initialize))

(use-package undo-tree
  :ensure t
  :config (global-undo-tree-mode))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package orderless
  :ensure t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package consult
  :ensure t
  :bind (("C-s" . consult-line)
         ("M-i" . consult-imenu)
         ("C-x b" . consult-buffer))
  :config (consult-customize
           consult-line :inherit-input-method t))

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-auto t)                 ;; Enable auto completion
  (corfu-separator ?\s)          ;; Orderless field separator
  (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Enable Corfu only for certain modes.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :ensure t
  :init
  (global-corfu-mode))

;; Use Dabbrev with Corfu!
(use-package dabbrev
  :bind (("M-/" . dabbrev-expand))
  :config
  (setq dabbrev-case-fold-search nil)
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` "))

;;(use-package hl-line
;;  :ensure t
;;  :config (global-hl-line-mode 1))

(use-package display-line-numbers
  :config
  (setq display-line-numbers-grow-only t)
  (add-hook 'agda2-mode-hook #'display-line-numbers-mode))

(use-package paren
  :config
  (setq show-paren-when-point-inside-paren t
        show-paren-when-point-in-periphery t
        show-paren-context-when-offscreen t
        show-paren-delay 0.2)
  (add-hook 'agda2-mode-hook #'show-paren-mode))

(defun agda-imenu-create-index ()
  "Create an `imenu` index for Agda files, including Unicode names but excluding module declarations and duplicates."
  (let (index seen-names)
    (goto-char (point-min)) ; Start at the beginning of the buffer
    (while (re-search-forward
            "^\\([[:word:][:multibyte:]'_]+\\)\\s-*:" ; Match type signatures
            nil t)
      (let ((name (match-string 1))) ; Capture the name of the definition
        (unless (member name seen-names) ; Avoid duplicates
          (push name seen-names) ; Track seen names
          (push (cons name (match-beginning 0)) index))))
    (nreverse index))) ; Reverse the list to preserve the order

(defun setup-agda-imenu ()
  "Set up `imenu` for the current buffer in Agda mode."
  ;; Ensure `imenu-create-index-function` is buffer-local
  (setq-local imenu-create-index-function #'agda-imenu-create-index))

(defun agda-imenu-refresh ()
  "Refresh the `imenu` index for the current buffer."
  ;; Ensure `imenu--index-alist` is cleared for a fresh rebuild
  (setq-local imenu--index-alist nil))

;; Hook to set up `imenu` for Agda mode
(add-hook 'agda2-mode-hook
          (lambda ()
            (setup-agda-imenu) ;; Set up `imenu`
            (agda-imenu-refresh))) ;; Refresh the index


;; A few more useful configurations...
(use-package emacs
  :bind
  (("M-v" . yank)
   ("M-c" . kill-ring-save)
   ("M-s" . save-buffer)
   ("M-=" . text-scale-increase)
   ("M--" . text-scale-decrease)
   ("M-z" . undo-only))

  :init
  (setq inhibit-startup-screen t)
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete)
  )

(use-package ultra-scroll-mac
  :if (eq window-system 'mac)
  :load-path "site-lisp/ultra-scroll-mac" ; if you git clone'd instead of package-vc-install
  :init
  (setq scroll-conservatively 101 ; important!
        scroll-margin 0)
  :config
  (ultra-scroll-mac-mode 1))

(use-package move-text
  :ensure t
  :config (move-text-default-bindings))

(use-package rg
  :ensure t)

(use-package projectile
  :ensure t
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  )

(defun treemacs-ignore-specific-files (filename absolute-path)
  "Ignore files ending with '.agdai', '.xmind', or named '.projectile'."
  (or (string-suffix-p ".agdai" filename)
      (string-suffix-p ".xmind" filename)
      (string-equal ".projectile" filename)))

(use-package treemacs
  :ensure t
  :config
  ;; (setq treemacs-no-png-images t)
  (setq treemacs-sorting 'mod-time-desc)
  (set-face-background 'treemacs-window-background-face "#f5f6f7")
  ;; Add the custom ignore predicate to Treemacs
  (add-to-list 'treemacs-ignored-file-predicates #'treemacs-ignore-specific-files)
  ;; (setq imenu-auto-rescan t)
  )


(use-package dashboard
  :ensure t
  :config
  (setq dashboard-items '((recents   . 10)
                        (projects  . 5)))
  (dashboard-setup-startup-hook)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; Coq Theorem Prover ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package proof-general
  :ensure t
  :config
  (defvar coq-user-tactics-db
  '(("dependent induction" "dep ind" "dependent induction #" t "dependent\\s-+induction")
    ("dependent destruction" "dep des" "dependent destruction #" t "dependent\\s-+destruction")))
  (setq proof-splash-enable nil)
  (setq proof-next-command-insert-space nil)
  (setq proof-three-window-mode-policy 'hybrid)
  (global-undo-tree-mode)
  )

(use-package proof-script
  :config
  (define-key proof-mode-map (kbd "M-n") 'proof-assert-next-command-interactive)
  (define-key proof-mode-map (kbd "<C-return>") 'proof-goto-point)
  (define-key proof-mode-map (kbd "M-h") 'coq-Check)
  (define-key proof-mode-map (kbd "M-p") 'proof-undo-last-successful-command))

(use-package company-coq
  :ensure t
  :init (setq company-coq-live-on-the-edge t)
  :config (add-hook 'coq-mode-hook #'company-coq-mode)
          (add-hook 'coq-mode-hook (lambda ()
                                     (setq coq-compile-before-require 't)))
          (add-hook 'coq-mode-hook
          (lambda ()
            (setq-local prettify-symbols-alist
                        '(("Alpha" . ?Α) ("Beta" . ?Β) ("Gamma" . ?Γ)
                          ("Delta" . ?Δ) ("Epsilon" . ?Ε) ("Zeta" . ?Ζ)
                          ("Eta" . ?Η) ("Theta" . ?Θ) ("Iota" . ?Ι)
                          ("Kappa" . ?Κ) ("Lambda" . ?Λ) ("Mu" . ?Μ)
                          ("Nu" . ?Ν) ("Xi" . ?Ξ) ("Omicron" . ?Ο)
                          ("Pi" . ?Π) ("Rho" . ?Ρ) ("Sigma" . ?Σ)
                          ("Tau" . ?Τ) ("Upsilon" . ?Υ) ("Phi" . ?Φ)
                          ("Chi" . ?Χ) ("Psi" . ?Ψ) ("Omega" . ?Ω)
                          ("alpha" . ?α) ("beta" . ?β) ("gamma" . ?γ)
                          ("delta" . ?δ) ("epsilon" . ?ε) ("zeta" . ?ζ)
                          ("eta" . ?η) ("theta" . ?θ) ("iota" . ?ι)
                          ("kappa" . ?κ) ("lambda" . ?λ) ("mu" . ?μ)
                          ("nu" . ?ν) ("xi" . ?ξ) ("omicron" . ?ο)
                          ("pi" . ?π) ("rho" . ?ρ) ("sigma" . ?σ)
                          ("tau" . ?τ) ("upsilon" . ?υ) ("phi" . ?φ)
                          ("chi" . ?χ) ("psi" . ?ψ) ("omega" . ?ω))
                        ))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; Agda Theorem Prover ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-to-list 'auto-mode-alist '("\\.lagda.md\\'" . agda2-mode))

(load-file (let ((coding-system-for-read 'utf-8))
             (shell-command-to-string "agda-mode locate")))

;; (global-display-line-numbers-mode 1)

(defun string-with-offset (msg)
  (setq offset (/ (- 70 (length msg)) 2))
  (concat
   (make-string offset ?\s)
   msg
   (make-string (- 70 offset) ?\s)))

(defun add-padding (str)
  (concat "--+"
          (substring str 3 67)
          "+--"))

(defun comment-block-generator ()
  "Generate comment block"
  (interactive)
  (setq comment-message (read-string "Comment: "))
  (insert (concat (make-string 70 ?-)                                (string ?\n)
;;                  (add-padding (make-string 70 ?\s))                 (string ?\n)
                  (add-padding (string-with-offset comment-message)) (string ?\n)
;;                  (add-padding (make-string 70 ?\s))                 (string ?\n)
                  (make-string 70 ?-)                                (string ?\n))))


(define-derived-mode eq-reason-mode text-mode "Equational Reasoning Mode"
  "A custom major mode similar to text-mode with '= {...}' lines treated as comments."
  (setq-local comment-start "= {")
  (font-lock-add-keywords nil '(("^= \\(.*\\)$" 1 font-lock-comment-face)))
)

(provide 'eq-reason-mode)

(use-package tex
  :ensure auctex)

(defmacro defadvice! (symbol arglist &rest body)
  "Define an advice called SYMBOL and add it to PLACES.

ARGLIST is as in `defun'. WHERE is a keyword as passed to `advice-add', and
PLACE is the function to which to add the advice, like in `advice-add'.
DOCSTRING and BODY are as in `defun'.

\(fn SYMBOL ARGLIST &rest [WHERE PLACES...] BODY\)"
  (declare (indent defun))
  (let (where-alist)
    (while (keywordp (car body))
      (push `(cons ,(pop body) (ensure-list ,(pop body)))
            where-alist))
    `(progn
       (defun ,symbol ,arglist ,@body)
       (dolist (targets (list ,@(nreverse where-alist)))
         (dolist (target (cdr targets))
           (advice-add target (car targets) #',symbol))))))

(use-package copilot
  :ensure editorconfig
  :ensure f
  :load-path "site-lisp/copilot"
  :init
  (defadvice! +copilot--get-source-a (fn &rest args)
    :around #'copilot--get-source
    (cl-letf (((symbol-function #'warn) #'message))
      (apply fn args)))
  :config
  (add-hook 'agda2-mode-hook 'copilot-mode)
  (add-to-list 'copilot-indentation-alist '(agda2-mode 2))
  (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion))
