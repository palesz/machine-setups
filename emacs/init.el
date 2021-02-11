
(package-initialize)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

;; enable use-package
(setq use-package-always-ensure t)
(require 'use-package)

;; fetch the list of packages available
; (unless package-archive-contents
;  (package-refresh-contents))

(require 'evil)
(evil-mode 0)


;; set different fonts for the variable and fixed pitch

(set-face-attribute 'default nil :font "Monospace-16")

(let* ((variable-tuple
          (cond ((x-list-fonts "ETBembo")         '(:font "ETBembo-18"))
                ((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro-18"))
                ((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande-18"))
                ((x-list-fonts "Verdana")         '(:font "Verdana-18"))
                ((x-list-fonts "Helvetica")       '(:font "Helvetica-18" :weight thin))
                ((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
                (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
         (base-font-color     (face-foreground 'default nil 'default))
         (headline           `(:inherit default :heihgt 1.0 :weight bold :foreground ,base-font-color :background "#deeeff")))

    (custom-theme-set-faces
     'user
     `(variable-pitch ((t (:inherit default ,@variable-tuple))))
     '(fixed-pitch ((t (:inherit default))))
     `(org-level-8 ((t (,@headline ,@variable-tuple))))
     `(org-level-7 ((t (,@headline ,@variable-tuple))))
     `(org-level-6 ((t (,@headline ,@variable-tuple))))
     `(org-level-5 ((t (,@headline ,@variable-tuple))))
     `(org-level-4 ((t (,@headline ,@variable-tuple :height 1.1))))
     `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.25))))
     `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.5))))
     `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.75))))
     `(org-document-title ((t (,@headline ,@variable-tuple :height 2.0 :underline nil))))))

(setq auto-save-timeout 5)

;; smooth scrolling
(setq mouse-wheel-scroll-amount '(1 ((shift) . 2) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)

;; fixing page-up|down behaviour
(global-set-key [next]
  (lambda () (interactive)
    (condition-case nil (scroll-up)
      (end-of-buffer (goto-char (point-max))))))

(global-set-key [prior]
  (lambda () (interactive)
    (condition-case nil (scroll-down)
      (beginning-of-buffer (goto-char (point-min))))))

(global-set-key (kbd "C-x e") 'evil-mode)
(global-set-key (kbd "C-x G") 'magit-status)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)
(global-set-key [home] 'move-beginning-of-line)
(global-set-key [end] 'move-end-of-line)

;; org agenda files
(setq org-agenda-files (append
                        (directory-files "~/orgs/" t "\\.org$")))

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

;; do not add new line automatically
(setq mode-require-final-newline nil)
(setq require-final-newline nil)

;; Disable some GUI distractions.
(tool-bar-mode -1)
(menu-bar-mode -1)
(blink-cursor-mode 0)

;; I use the horizontal scrollbar in org mode, with big tables
;; it is better than breaking the tables with visual-line-mode
;; or having to zoom out
(scroll-bar-mode 1)
(horizontal-scroll-bar-mode 1)

;; show the line and column numbers in the modeline
(line-number-mode)
(column-number-mode)

;; highlight the parenthesis
(show-paren-mode 1)

;; Stop creating backup and autosave files.
(setq make-backup-files nil
      auto-save-default nil)

;; Accept 'y' and 'n' rather than 'yes' and 'no'.
(defalias 'yes-or-no-p 'y-or-n-p)

;; Use UTF-8 by default
(prefer-coding-system 'utf-8)

;; Nicer handling of regions
(transient-mark-mode 1)
(delete-selection-mode 1)

;; Highlight the current line
(global-hl-line-mode 1)
(set-face-background hl-line-face "#eeeeee" )


;; show line numbers
;; found it distracting and it also messes up the org-mode indentation for files with 3-4 digits line numbers
(global-display-line-numbers-mode -1)

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

(global-visual-line-mode -1)
(global-visual-fill-column-mode -1)

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
(require 'ob-java)
(require 'ob-groovy)

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
    (http . t)
    (elasticsearch . t)
    (java . t)
    (groovy . t)))

;; org refile
(setq org-refile-targets
      '((nil :maxlevel . 3)
        (org-agenda-files :maxlevel . 3)))

;; org-download for easy image insert
(require 'org-download)
(add-hook 'dired-mode-hook 'org-download-enable)

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
(setq org-bullets-bullet-list '("⁞" "⁞" "⁞" "⁞" "⁞" "⁞" "⁞" "⁞" "⁞" "⁞" "⁞" "⁞" "⁞" "⁞" "⁞" "⁞"))
;; ∷
;; (setq org-bullets-bullet-list '("➤" "➤" "➤" "➤" "➤" "➤" "➤" "➤" "➤" "➤" "➤" "➤" "➤" "➤" "➤" "➤"))
;; (setq org-bullets-bullet-list '("∵" "∵" "∵" "∵" "∵" "∵" "∵" "∵" "∵" "∵" "∵" "∵" "∵" "∵" "∵"))
;; (setq org-bullets-bullet-list '("⫼" "⫼" "⫼" "⫼" "⫼" "⫼" "⫼" "⫼" "⫼" "⫼" "⫼" "⫼"))

;; indentation
(add-hook 'org-mode-hook (lambda () (org-indent-mode 1)))
(setq org-indent-indentation-per-level 4)
(setq org-adapt-indentation nil)
(setq org-hide-leading-starts nil)

;; enable variable pitch mode
(add-hook 'org-mode-hook (lambda () (variable-pitch-mode 1)))

;; emphasis markers
(setq org-hide-emphasis-markers nil)

;; headline
(setq org-fontify-whole-heading-line t
      ;; I've included these to maximize compatibility with doom-themes in general
      org-fontify-done-headline t
      org-fontify-quote-and-verse-blocks t)

;; mix pitches
(use-package mixed-pitch
  :hook
  (text-mode . mixed-pitch-mode)
  (org-mode . mixed-pitch-mode))

;; Be able to change the image size
;; (setq org-image-actual-width 200)
(setq org-image-actual-width '(1200))
;;(setq org-image-actual-width (/ (display-pixel-width) 3))

;; load-theme org-beautify
(load-theme 'org-beautify t)

(require 'powerline)
(powerline-default-theme)

;; -------------------------------------------
;; lsp-java setup
;; -------------------------------------------
;; https://github.com/emacs-lsp/lsp-java#quick-start

(use-package projectile)
(use-package flycheck)
(use-package yasnippet :config (yas-global-mode))
(use-package lsp-mode :hook ((lsp-mode . lsp-enable-which-key-integration))
  :config (setq lsp-completion-enable-additional-text-edit nil))
(use-package hydra)
(use-package company)
(use-package lsp-ui)
(use-package which-key :config (which-key-mode))
(use-package lsp-java :config (add-hook 'java-mode-hook 'lsp))
(use-package dap-mode :after lsp-mode :config (dap-auto-configure-mode))
(use-package dap-java :ensure nil)
(use-package helm-lsp)
(use-package helm
  :config (helm-mode))
(use-package lsp-treemacs)

(setq lsp-java-vmargs (list "-noverify" "-Xmx8G" "-XX:+UseG1GC" "-XX:+UseStringDeduplication")
      lsp-file-watch-ignored '(".idea" ".git" "build"))

;; activate helm, enable helm-M-x
(helm-mode 1)
(global-set-key (kbd "M-x") 'helm-M-x)

(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

;; enable git-gutter by default
(git-gutter-mode)

(require 'helm-projectile)
(helm-projectile-on)

;; remove the Ctrl-Z binding, so emacs won't hang
(global-unset-key (kbd "C-z"))

(global-set-key (kbd "C-;") 'er/expand-region)

;; Edit browser text with Emacs
;; Install the
;; Atomic Chrome: https://chrome.google.com/webstore/detail/atomic-chrome/lhaoghhllmiaaagaffababmkdllgfcmc
;; or
;; GhostText: https://github.com/GhostText/GhostText
;; extensions into your browser to make it work.
(require 'atomic-chrome)
(atomic-chrome-start-server)

(require 'visual-regexp-steroids)
(define-key global-map (kbd "C-c r") 'vr/replace)
(define-key global-map (kbd "C-c q") 'vr/query-replace)
;; if you use multiple-cursors, this is for you:
(define-key global-map (kbd "C-c m") 'vr/mc-mark)
;; to use visual-regexp-steroids's isearch instead of the built-in regexp isearch, also include the following lines:
(define-key esc-map (kbd "C-r") 'vr/isearch-backward) ;; C-M-r
(define-key esc-map (kbd "C-s") 'vr/isearch-forward) ;; C-M-s

