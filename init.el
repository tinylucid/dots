;;; -*- lexical-binding: t -*-
(setq package-enable-at-startup nil)

(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; TODO: Deprecate this
;; (require 'package)

;; (setq package-archives
;;       '(("elpa" . "https://elpa.gnu.org/packages/")
;;         ("melpa" . "https://melpa.org/packages/")))

;; (package-initialize)
;; (when (not package-archive-contents)
;;   (package-refresh-contents))

;; (unless (package-installed-p 'use-package)
;;   (warn "use-package is not installed, trying to install")
;;   (package-install 'use-package))
;;(require 'use-package)

(defalias 'display-startup-echo-area-message #'ignore)
(defalias 'yes-or-no-p 'y-or-n-p)

(setq default-directory "~/.emacs.d/")
(add-to-list 'load-path "~/.emacs.d/lisp/")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(let ((default-directory  "~/.emacs.d/lisp/"))
  (normal-top-level-add-subdirs-to-load-path))

(setq use-package-always-ensure t)
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(use-package straight
         :custom (straight-use-package-by-default t))

(add-hook 'after-init-hook
          #'(lambda ()
              (setq gc-cons-threshold (* 100 1000 1000))))
(add-hook 'focus-out-hook 'garbage-collect)
(run-with-idle-timer 5 t 'garbage-collect)


(tool-bar-mode       0)
(menu-bar-mode       0)
(scroll-bar-mode     0)
(show-paren-mode     0)

(line-number-mode    1)
(column-number-mode  1)
(blink-cursor-mode   1)
(transient-mark-mode 1)

(setq-default indent-tabs-mode nil
              tab-width 4
              require-final-newline t
              cursor-type 'box
              indicate-buffer-boundaries '((top . right)
                                           (bottom . right)
                                           (t . nil)))
(setq-default tab-width 4)
(global-auto-revert-mode 1)
(setq mouse-autoselect-window nil
      focus-follows-mouse nil
      load-prefer-newer t
      delete-old-versions t
      ring-bell-function 'ignore
      inhibit-splash-screen t
      initial-scratch-message nil
      inhibit-startup-message t
      inhibit-startup-buffer-menu t
      inhibit-startup-screen t
      mouse-wheel-scroll-amount '(1 ((shift) .1))
      mouse-wheel-progressive-speed nil
      scroll-step 1
      scroll-conservatively 100000
      scroll-margin 3
      fringes-outside-margins 1
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      frame-resize-pixelwise t
      frame-inhibit-implied-resize t
      initial-major-mode 'fundamental-mode
      make-backup-files nil
      create-lockfiles nil
      blink-cursor-blinks 7
      window-combination-resize t
      shift-select-mode nil
      lazy-highlight-initial-delay 0
      search-default-mode 'char-fold-to-regexp)

(defun my/disable-scroll-bars (frame)
  (modify-frame-parameters frame
                           '((vertical-scroll-bars . nil)
                             (horizontal-scroll-bars . nil))))
(add-hook 'after-make-frame-functions 'my/disable-scroll-bars)
(set-face-attribute 'default nil :font "Cascadia Mono-9.5")
(load-theme 'naysay t)

(defun maximize-frame ()
  "Maximize the current frame"
  (interactive)
  (w32-send-sys-command 61488))

(defvar newline-and-indent t)
(defun open-previous-line (arg)
  "Open a new line above current one ARG."
  (interactive "p")
  (beginning-of-line)
  (open-line arg)
  (when newline-and-indent
    (indent-according-to-mode)))

(defun post-load-stuff ()
  (interactive)
  (maximize-frame)
  (set-cursor-color "#ff0048"))
(add-hook 'window-setup-hook 'post-load-stuff t)

(defun my-c-mode-common-hook ()
  (c-set-style "bsd")
  (electric-pair-mode)
  (setq-default tab-width 4)
  (setq c-basic-offset 4)
  (setq indent-tabs-mode nil))
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
(add-hook 'c++-mode-common-hook 'my-c-mode-common-hook)

(global-set-key [(control s)] 'isearch-forward-regexp)
(global-set-key [(control r)] 'isearch-backward-regexp)
(global-set-key [(meta %)] 'query-replace-regexp)
(global-set-key [(control z)] 'undo)
(global-set-key [(meta o)] 'open-previous-line)
;; -----------------------------------------------------------------------------
(use-package undo-tree)

(setq ctrlf-show-match-count-at-eol nil)
(use-package ctrlf)
(ctrlf-mode +1)

(use-package paredit
  :diminish paredit-mode
  :config
  (dolist (m '(clojure-mode-hook
               emacs-lisp-mode-hook
               eval-expression-minibuffer-setup-hook))
    (add-hook m #'paredit-mode)))

(use-package highlight-numbers
  :config
  (add-hook 'prog-mode-hook 'highlight-numbers-mode))

(use-package diminish
  :ensure t)

(use-package vertico
  :ensure t
  :init
  (vertico-mode)
  (setq vertico-scroll-margin 0)
  (setq vertico-count 5)
  (setq vertico-resize t)
  ;; (setq vertico-cycle t)
  )

(use-package savehist
  :ensure t
  :init
  (savehist-mode))

(setq minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt))
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

(setq enable-recursive-minibuffers t)

(use-package orderless
  :ensure t
  :init
  ;; (setq orderless-style-dispatchers '(+orderless-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(setq esup-depth 0)

(use-package esup
  :ensure t)
;; -----------------------------------------------------------------------------
;; Local Variables:
;; byte-compile-warnings: (not free-vars noruntime)
;; fill-column: 80
;; End:
;;; init.el ends here
