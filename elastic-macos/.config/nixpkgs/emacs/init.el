
(package-initialize)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

;; fetch the list of packages available
; (unless package-archive-contents
;  (package-refresh-contents))

(require 'evil)
(evil-mode 0)

(setq auto-save-timeout 5)

;; smooth scrolling
(setq mouse-wheel-scroll-amount '(1 ((shift) . 2) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)

(global-set-key (kbd "C-x e") 'evil-mode)
(global-set-key (kbd "C-x G") 'magit-status)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

;; horizontal and vertical split settings
(setq split-height-threshold nil)
(setq split-width-threshold 160)

;; Disable startup message.
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message (user-login-name))

(setq initial-major-mode 'fundamental-mode
      initial-scratch-message nil)

;; 4 spaces instead of tabs, this makes simple to work
;; with whitespace-aware languages (looking at you, Python)
(setq-default indent-tabs-mode nil
              tab-width 4
              c-basic-offset 4)


;; Disable some GUI distractions.
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(blink-cursor-mode 0)

(line-number-mode)
(column-number-mode)

;; Stop creating backup and autosave files.
(setq make-backup-files nil
      auto-save-default nil)

;; Accept 'y' and 'n' rather than 'yes' and 'no'.
(defalias 'yes-or-no-p 'y-or-n-p)

;; Use UTF-8 by default
(prefer-coding-system 'utf-8)

;; Nicer handling of regions
(transient-mark-mode 1)

;; Highlight the current line
(global-hl-line-mode 1)

;; Improved handling of clipboard in GNU/Linux and otherwise.
(setq select-enable-clipboard t
      select-enable-primary t
      save-interprogram-paste-before-kill t)

;; Pasting with middle click should insert at point, not where the
;; click happened.
(setq mouse-yank-at-point t)

;; Make moving cursor past bottom only scroll a single line rather
;; than half a page.
(setq scroll-step 1
      scroll-conservatively 5)

;; Trailing white space are banned!
(setq-default show-trailing-whitespace t)

;; Shouldn't highlight trailing spaces in terminal mode.
(add-hook 'term-mode (lambda () (setq show-trailing-whitespace nil)))
(add-hook 'term-mode-hook (lambda () (setq show-trailing-whitespace nil)))

;; (put 'narrow-to-region 'disabled nil)
(setq fill-column 100)
(global-visual-line-mode 1)
(global-visual-fill-column-mode 1)

;; org-babel setup
(require 'ob-python)
(require 'ob-shell)
(require 'ob-dot)
(require 'ob-sql)
(require 'ob-clojure)
(require 'ob-plantuml)
(require 'ob-sql-mode)
(require 'ob-clojurescript)
(require 'ob-restclient)
(require 'ob-calc)
(require 'ob-async)
(require 'ob-ein)
(require 'ob-js)
(require 'ob-http)

(org-babel-do-load-languages
 'org-babel-load-languages
 '( (python . t)
    (sql . t)
    (dot . t)
    (shell . t)
    (clojure . t)
    (plantuml . t)
    (sql-mode . t)
    (clojurescript . t)
    (restclient . t)
    (calc . t)
    (ein . t)
    (js . t)
    (http . t)))

;; org inline images
(setq org-display-inline-images t)
(setq org-redisplay-inline-images t)
(setq org-startup-with-inline-images "inlineimages")

;; Always redisplay inline images after executing SRC block
(eval-after-load 'org
  (add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images))

;; org-bullets
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

;; Be able to change the image size
;; (setq org-image-actual-width 200)
(setq org-image-actual-width '(1200))
;;(setq org-image-actual-width (/ (display-pixel-width) 3))


;; load-theme org-beautify
(load-theme 'org-beautify t)

(require 'powerline)
(powerline-default-theme)
