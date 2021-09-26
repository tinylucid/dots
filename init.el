;;; -*- lexical-binding: t -*-

(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives
      '(("elpa" . "https://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.org/packages/")))

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (warn "use-package is not installed, trying to install")
  (package-install 'use-package))
(require 'use-package)
(defalias 'display-startup-echo-area-message #'ignore)
(defalias 'yes-or-no-p 'y-or-n-p)

;; UTF-8 everywhere for everything
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

(setq default-directory "~/.emacs.d/")
(add-to-list 'load-path "~/.emacs.d/lisp/")
(let ((default-directory  "~/.emacs.d/lisp/"))
  (normal-top-level-add-subdirs-to-load-path))

(setq use-package-always-ensure t)
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(transient-mark-mode 1)
(tool-bar-mode       0)
(menu-bar-mode       0)
(scroll-bar-mode     0)
(show-paren-mode     1)
(line-number-mode    1)
(column-number-mode  1)
(blink-cursor-mode   1)

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
      scroll-margin 1
      fringes-outside-margins 1
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      frame-resize-pixelwise t
      frame-inhibit-implied-resize t
      initial-major-mode 'fundamental-mode
      make-backup-files nil
      create-lockfiles nil
      frame-title-format (list "EMACS")
      read-process-output-max (* 1024 1024)
      gc-cons-threshold 100000000
      blink-cursor-blinks 7
      window-combination-resize t
      shift-select-mode nil
      lazy-highlight-initial-delay 0
      search-default-mode 'char-fold-to-regexp)

;; -----------------------------------------------------------------------------
;; fonts & aesthetics
(set-face-attribute 'default nil :font "Consolas-18")

(defun my/disable-scroll-bars (frame)
  (modify-frame-parameters frame
                           '((vertical-scroll-bars . nil)
                             (horizontal-scroll-bars . nil))))
(add-hook 'after-make-frame-functions 'my/disable-scroll-bars)

(defun disable-all-themes ()
  (dolist (i custom-enabled-themes)
    (disable-theme i)))

(defadvice load-theme (before disable-themes-first activate)
  (disable-all-themes))

(require 'elemental-theme)
(enable-theme 'elemental-theme)
;; ####################################################################################

(eval-and-compile
  (defun my-blend-colors (basecolor mixcolor percent)
    "Mix two colors."
    (require 'color)
    (cl-destructuring-bind (r g b) (color-name-to-rgb basecolor)
      (cl-destructuring-bind (r2 g2 b2) (color-name-to-rgb mixcolor)
        (let* ((x (/ percent 100.0))
               (y (- 1 x)))
          (color-rgb-to-hex (+ (* r y) (* r2 x)) (+ (* g y) (* g2 x)) (+ (* b y) (* b2 x))))))))

(defmacro my-elemental-theme-apply-colors
    (bg-base fg-base accent-1 accent-2 accent-3 accent-4 red orange green blue)
  (declare (indent defun))
  (let* ((brightness-bg (caddr (apply 'color-rgb-to-hsl (color-name-to-rgb bg-base))))
         (brightness-fg (caddr (apply 'color-rgb-to-hsl (color-name-to-rgb fg-base))))
         (mode          (if (< brightness-bg brightness-fg) 'dark 'light))
         (bright-bg     (my-blend-colors bg-base fg-base (if (eq mode 'dark) 15 6)))
         (brighter-bg   (my-blend-colors bg-base fg-base (if (eq mode 'dark) 30 12)))
         (darker-fg     (my-blend-colors fg-base bg-base (if (eq mode 'dark) 74 84)))
         (dark-fg       (my-blend-colors fg-base bg-base (if (eq mode 'dark) 37 42)))
         (bright-fg     (my-blend-colors fg-base bg-base (if (eq mode 'dark) -30 -12))))
    `(progn
       (custom-theme-set-variables 'elemental-theme '(frame-background-mode ',mode))
       ,(when (eq window-system 'ns)
          `(set-frame-parameter nil 'ns-appearance ',mode))
       (set-face-background 'default ,bg-base)
       (set-face-background 'cursor ,fg-base)
       (set-face-background 'elemental-bright-bg-face ,bright-bg)
       (set-face-background 'elemental-brighter-bg-face ,brighter-bg)
       (set-face-foreground 'elemental-darker-fg-face ,darker-fg)
       (set-face-foreground 'elemental-dark-fg-face ,dark-fg)
       (set-face-foreground 'default ,fg-base)
       (set-face-foreground 'elemental-bright-fg-face ,bright-fg)
       (set-face-foreground 'elemental-accent-fg-1-face ,accent-1)
       (set-face-foreground 'elemental-accent-fg-2-face ,accent-2)
       (set-face-foreground 'elemental-accent-fg-3-face ,accent-3)
       (set-face-foreground 'elemental-accent-fg-4-face ,accent-4)
       (set-face-foreground 'elemental-red-fg-face ,red)
       (set-face-foreground 'elemental-orange-fg-face ,orange)
       (set-face-foreground 'elemental-green-fg-face ,green)
       (set-face-foreground 'elemental-blue-fg-face ,blue)
       ;; Liking my comments green shrug shrug
       (set-face-foreground 'font-lock-comment-face ,green)
       (set-face-foreground 'font-lock-comment-delimiter-face ,green)
       (set-face-foreground 'font-lock-doc-face ,green)
       (set-face-foreground 'font-lock-string-face ,orange)
       (set-face-foreground 'font-lock-function-name-face "#f0f0f0")
       (run-hooks 'my-elemental-theme-change-palette-hook))))

;; Late night hacking pallet
;; (my-elemental-theme-apply-colors
;;  "#0a1116" "#8ea29e" "#729fcf" "#c4ddd8" "#49c9be" "#a49bfa"
;;  "#fe5450" "#d1a663" "#34cd4a" "#729fcf")

;; Naysay
(my-elemental-theme-apply-colors
 "#111415" "#B2A895" "#9BB7C9" "#f0f0f0" "PaleGreen3" "#49c9af"
 "#ff4450" "#2fd8c6" "#34cf4a" "#86B7e9")

;; ####################################################################################

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
;; (use-package undo-tree
;;   :bind ("C-x C-u" . undo-tree-mode))

(use-package paredit
  :diminish paredit-mode
  :config
  (dolist (m '(clojure-mode-hook
               cider-repl-mode-hook
               clojure-mode-hook
               emacs-lisp-mode-hook
               racket-mode-hook
               racket-repl-mode-hook
               scheme-mode-hook
               slime-mode-hook
               slime-repl-mode-hook
               eval-expression-minibuffer-setup-hook))
    (add-hook m #'paredit-mode)))

(use-package highlight-numbers
  :config
  (add-hook 'prog-mode-hook 'highlight-numbers-mode))

(add-hook 'c++-mode-hook 'tree-sitter-hl-mode)
(add-hook 'c-mode-hook 'tree-sitter-hl-mode)


(use-package rainbow-delimiters
  :config
  (dolist (m '(clojure-mode-hook
               cider-repl-mode-hook
               emacs-lisp-mode-hook
               racket-mode-hook
               racket-repl-mode-hook
               scheme-mode-hook
               lisp-mode-hook
               ;;c++-mode-hook
               eval-expression-minibuffer-setup-hook))
    (add-hook m #'rainbow-delimiters-mode)))

(use-package diminish
  :ensure t)
(when (fboundp 'native-compile-async)
  (setq comp-deferred-compilation t
        comp-deferred-compilation-black-list '("/mu4e.*\\.el$")))


;; -----------------------------------------------------------------------------
;; Local Variables:
;; byte-compile-warnings: (not free-vars noruntime)
;; fill-column: 80
;; End:
;;; init.el ends here
