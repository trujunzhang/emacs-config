;; -*- emacs-lisp -*-

;;; Package.el
(setq gc-cons-threshold 8000000) ; augmente la taille du garbage collector

(setq package-enable-at-startup nil)
(let ((default-directory "~/.emacs.d/elpa"))
  (normal-top-level-add-subdirs-to-load-path))
(package-initialize t)
(require 'use-package)

(setq package-check-signature nil)
(setq package-enable-at-startup nil)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))

;; bootstrap `quelpa'
(use-package quelpa
  :load-path "~/.emacs.d/private/quelpa"
  :config
  (setq quelpa-update-melpa-p nil)
  (use-package quelpa-use-package
    :load-path "~/.emacs.d/private/quelpa-use-package"))


(use-package general
  :quelpa (general :fetcher github :repo "noctuid/general.el"))
(use-package use-package-chords :config (key-chord-mode 1))
(use-package diminish)
(use-package bind-key)
(use-package server
  :config
  (unless (server-running-p) (server-start)))

;;; Sane default
(setq
 use-package-verbose nil  ; use-package décrit les appels qu'il fait
 delete-old-versions -1	; supprime les vieilles versions des fichiers sauvegardés
 version-control t	; enable le version control
 vc-make-backup-files t	; backups file even when under vc
 vc-follow-symlinks t	; vc suit les liens  symboliques
 auto-save-file-name-transforms
 '((".*" "~/.emacs.d/auto-save-list/" t)); transforme les noms des fichiers sauvegardés
 inhibit-startup-screen t ; supprime l'écran d'accueil
 ring-bell-function 'ignore ; supprime cette putain de cloche.
 coding-system-for-read 'utf-8          ; use UTF8 pour tous les fichiers
 coding-system-for-write 'utf-8         ; idem
 sentence-end-double-space nil          ; sentences does not end with double space.
 default-fill-column 72
 initial-scratch-message ""
 save-interprogram-paste-before-kill t
 help-window-select t			; focus help window when opened
 tab-width 4                    ; tab are 4 spaces large
 )

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(setq-default indent-tabs-mode nil
              tab-width 4)

(prefer-coding-system 'utf-8)           ; utf-8 est le systeme par défaut.

(defalias 'yes-or-no-p 'y-or-n-p) ; remplace yes no par y n
(show-paren-mode) ; highlight delimiters
(line-number-mode) ; display line number in mode line
(column-number-mode) ; display colum number in mode line
(save-place-mode)    ; save cursor position between sessions
(delete-selection-mode 1)               ; replace highlighted text with type
(setq initial-major-mode 'fundamental-mode)
;; supprime les caractères en trop en sauvegardant.
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; rend les scripts executable par défault si c'est un script.
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)


;;; apparences
(when window-system
  (tooltip-mode -1)                     ; don't know what that is
  (tool-bar-mode -1)                    ; sans barre d'outil
  (menu-bar-mode -1)                    ; barre de menu
  (scroll-bar-mode -1)                  ; enlève la barre de défilement
  (blink-cursor-mode -1)                 ; pas de clignotement
  (set-frame-size (selected-frame) 85 61)
  (add-to-list 'default-frame-alist '(height . 46))
  (add-to-list 'default-frame-alist '(width . 85))
  ;; change default font for current frame
  (add-to-list 'default-frame-alist '(font . "Fira Code 14"))
  (set-face-attribute 'default nil :font "Fira Code 14"))


;;; keybindings

(when (eq system-type 'darwin)           ; mac specific bindings
  (setq mac-right-command-modifier 'meta ; cmd de droite = meta
        mac-command-modifier 'control    ; cmd de gauche = control
        mac-option-modifier 'super       ; option de gauche = super
        mac-right-option-modifier nil    ; option de droite = carac spéciaux
        mac-control-modifier 'hyper ; control de gauche = hyper (so does capslock)
        ns-function-modifier 'hyper ; fn key = hyper
        ns-right-alternate-modifier nil) ; cette touche n'existe pas.
  (setq mac-pass-command-to-system nil)  ; disable system call to commands like
                                        ; C-h (hide frame on macOS by default
  (setq mac-pass-control-to-system nil)  ; idem
  (setq locate-command "mdfind")
  (setq delete-by-moving-to-trash t)
  (defun system-move-file-to-trash (file)
    "Use \"trash\" to move FILE to the system trash.
When using Homebrew, install it using \"brew install trash\"."
    (call-process (executable-find "trash") nil nil nil file)))



;;; Packages -------------------------------------------------------------------

;; ---------- A --------------------------------------------------
(use-package abbrev :defer t
  :diminish ""
  :init
  (add-hook 'text-mode-hook (lambda () (abbrev-mode 1)))
  ;; tell emacs where to read abbrev definitions from...
  (setq abbrev-file-name "~/dotfile/emacs/.abbrev_defs")
  (setq save-abbrevs 'silently)
  (setq-default abbrev-mode t))

(use-package ace-window :ensure t
  :commands
  ace-window
  :config
  (setq aw-keys '(?t ?s ?r ?n ?m ?a ?u ?i ?e))
  (setq aw-background t)
  (setq aw-ignore-current t))

(use-package ag :ensure t
  :commands (ag)
  :config
  (progn
    (setq ag-highlight-search t)
    (setq ag-reuse-buffers t)
    (add-to-list 'ag-arguments "--word-regexp")))

(use-package anzu :ensure t
  :diminish ""
  :commands (global-anzu-mode)
  :init
  (global-anzu-mode 1)
  :bind*
  (("C-/" . anzu-query-replace-at-cursor)
   ("C-9" . anzu-replace-at-cursor-thing))
  :config
  (global-set-key [remap query-replace] 'anzu-query-replace)
  (global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp))

(use-package apropospriate-theme :ensure t
  :commands (load-apropospriate-theme)
  :defines (load-apropospriate-theme)
  :config
  (defun load-apropospriate-theme (&optional dark)
    (interactive)
    (if dark
        (load-theme 'apropospriate-dark t)
      (load-theme 'apropospriate-light t))))

(use-package auto-fill-mode
  :diminish auto-fill-function
  :commands turn-on-auto-fill
  :init
  (add-hook 'text-mode-hook 'turn-on-auto-fill)
  (diminish 'auto-fill-function ""))

(use-package autoinsert
  :init
  (auto-insert-mode)
  (setq auto-insert-directory "~/dotfile/emacs/autoinsert")
  (define-auto-insert "\\.R\\'" "header.R")
  (define-auto-insert "\\.pl\\'" "header.pl"))

(use-package autorevert :defer t
  ;; mainly to make autorevert disappear from the modeline
  :diminish auto-revert-mode)

(use-package avy :ensure t
  :commands (avy-goto-word-or-subword-1
             avy-goto-word-1
             avy-goto-char-in-line
             avy-goto-line)
  :config
  (setq avy-keys '(?a ?t ?u ?s ?i ?r ?e ?n ?p ?d ?é ?l))
  (setq avy-styles-alist
        '((avy-goto-char-in-line . post)
          (avy-goto-word-or-subword-1 . post))))

(use-package avy-zap :ensure t
  :bind (("M-Z" . avy-zap-to-char-dwim)
         ("M-z" . avy-zap-up-to-char-dwim)))

(use-package aggressive-indent :ensure t
  :diminish (aggressive-indent-mode . "")
  :commands aggressive-indent-mode
  :init
  (add-hook 'prog-mode-hook 'aggressive-indent-mode)
  :config
  (add-to-list 'aggressive-indent-excluded-modes 'html-mode)
  (add-to-list 'aggressive-indent-excluded-modes 'perl-mode)
  (add-to-list 'aggressive-indent-excluded-modes 'ess-mode)
  (add-to-list
   'aggressive-indent-dont-indent-if    ; do not indent line if
   '(and (derived-mode-p 'ess-mode)     ; in ess mode
         (null (string-match "\\(^#\\+ .+ $\\)" ; and in a roxygen block
                             (thing-at-point 'line))))))

;; ---------- B --------------------------------------------------
(use-package beacon
  :diminish ""
  :quelpa (beacon :fetcher github :repo "Malabarba/beacon")
  :config
  (beacon-mode 1))

(use-package blank-mode :ensure t
  :commands blank-mode)

(use-package bongo :ensure t
  :commands (bongo)
  :config
  (define-key bongo-playlist-mode-map (kbd "g") #'bongo-redisplay)
  (setq bongo-default-directory "~/Music/electro-swing/"))

;; ---------- C --------------------------------------------------
(use-package command-log-mode :ensure t
  :commands (command-log-mode))

(use-package company :ensure t
  :diminish ""
  :commands global-company-mode
  :init
  (add-hook 'after-init-hook #'global-company-mode)
  (setq
   company-idle-delay 0.2
   company-selection-wrap-around t
   company-minimum-prefix-length 2
   company-require-match nil
   company-dabbrev-ignore-case nil
   company-dabbrev-downcase nil
   company-show-numbers t)

  :config
  (global-company-mode)

  (use-package company-statistics
    :quelpa (company-statistics :fetcher github :repo "company-mode/company-statistics")
    :config
    (company-statistics-mode))

  (bind-keys :map company-active-map
    ("C-d" . company-show-doc-buffer)
    ("C-l" . company-show-location)
    ("C-n" . company-select-next)
    ("C-p" . company-select-previous)
    ("C-t" . company-select-next)
    ("C-s" . company-select-previous)
    ("TAB" . company-complete))

  (setq company-backends
        '((company-css
           company-clang
           company-capf
           company-semantic
           company-xcode
           company-cmake
           company-files
           company-gtags
           company-etags
           company-keywords)))

  ;; from https://github.com/syl20bnr/spacemacs/blob/master/layers/auto-completion/packages.el
  (setq hippie-expand-try-functions-list
        '(
          ;; Try to expand word "dynamically", searching the current buffer.
          try-expand-dabbrev
          ;; Try to expand word "dynamically", searching all other buffers.
          try-expand-dabbrev-all-buffers
          ;; Try to expand word "dynamically", searching the kill ring.
          try-expand-dabbrev-from-kill
          ;; Try to complete text as a file name, as many characters as unique.
          try-complete-file-name-partially
          ;; Try to complete text as a file name.
          try-complete-file-name
          ;; Try to expand word before point according to all abbrev tables.
          try-expand-all-abbrevs
          ;; Try to complete the current line to an entire line in the buffer.
          try-expand-list
          ;; Try to complete the current line to an entire line in the buffer.
          try-expand-line
          ;; Try to complete as an Emacs Lisp symbol, as many characters as
          ;; unique.
          try-complete-lisp-symbol-partially
          ;; Try to complete word as an Emacs Lisp symbol.
          try-complete-lisp-symbol)))



(use-package counsel :ensure t
  :bind*
  (("M-x"     . counsel-M-x)
   ("C-x C-f" . counsel-find-file)
   ("C-c f"   . counsel-git)
   ("C-c s"   . counsel-git-grep)
   ("C-c /"   . counsel-ag)
   ("C-c o"   . counsel-find-file-extern)
   ("C-S-s"   . counsel-ag)
   ("C-c l"   . counsel-locate))
  :config
  (setq counsel-find-file-at-point t)
  (setq counsel-locate-cmd 'counsel-locate-cmd-mdfind)
  (setq counsel-find-file-ignore-regexp "\\.DS_Store\\|.git")

  ;; from http://blog.binchen.org/posts/use-ivy-mode-to-search-bash-history.html
  (defun counsel-yank-bash-history ()
    "Yank the bash history"
    (interactive)
    (let (hist-cmd collection val)
      (shell-command "history -r")      ; reload history
      (setq collection
            (nreverse
             (split-string (with-temp-buffer (insert-file-contents (file-truename "~/.bash_history"))
                                             (buffer-string))
                           "\n"
                           t)))
      (when (and collection (> (length collection) 0)
                 (setq val (if (= 1 (length collection)) (car collection)
                             (ivy-read (format "Bash history:") collection))))
        (insert val)
        (message "%s => kill-ring" val))))

  ;; TODO make the function respects reverse order of file
  (defun counsel-yank-zsh-history ()
    "Yank the zsh history"
    (interactive)
    (let (hist-cmd collection val)
      (shell-command "history -r")      ; reload history
      (setq collection
            (nreverse
             (split-string (with-temp-buffer (insert-file-contents (file-truename "~/.zhistory"))
                                             (buffer-string))
                           "\n"
                           t)))
      (setq collection (mapcar (lambda (it) (replace-regexp-in-string ".*;" "" it)) collection))
      (when (and collection (> (length collection) 0)
                 (setq val (if (= 1 (length collection)) (car collection)
                             (ivy-read (format "Zsh history:") collection :re-builder #'ivy--regex-ignore-order))))
        (kill-new val)
        (insert val)
        (message "%s => kill-ring" val))))

  (defun counsel-package-install ()
    (interactive)
    (ivy-read "Install package: "
              (delq nil
                    (mapcar (lambda (elt)
                              (unless (package-installed-p (car elt))
                                (symbol-name (car elt))))
                            package-archive-contents))
              :action (lambda (x)
                        (package-install (intern x)))
              :caller 'counsel-package-install))
  (ivy-set-actions
   'counsel-find-file
   '(("o" (lambda (x) (counsel-find-file-extern x)) "open extern"))))

(use-package counsel-osx-app :ensure t
  :commands counsel-osx-app
  :bind*
  ("C-c a" . counsel-osx-app)
  :config
  (setq counsel-osx-app-location
        '("/Applications/" "~/Applications/" "~/sam_app/")))

(use-package counsel-projectile :ensure t
  :bind* (("H-P" . counsel-projectile-switch-to-buffer)
          ("H-p" . counsel-projectile))
  :config
  (counsel-projectile-on))

(use-package counsel-gtags :ensure t
  :defer t)

(use-package css-mode :ensure t
  :mode (("\\.css\\'" . css-mode)))

(use-package csv-mode :ensure t
  :mode (("\\.csv\\'" . csv-mode))
  :bind (:map csv-mode-map
         ("'" . hydra-csv/body))
  :defines hydra-csv/body
  :config
  (defhydra hydra-csv (:hint nil :color amaranth)
    "
^NAV^        ^TRANSFORM^      ^ALIGN^         ^TOGGLE^         ^YANK^
_f_: fwd     _s_: sort        _a_: align      _d_: desc        _k_: kill
_b_: bwd     _S_: sort num    _A_: unalign    _T_: invisible   _y_: yank
_n_: next    _t_: transpose   ^ ^             ^ ^              _Y_: yank as new table
_p_: prev    _r_: reverse
"
    ("f" csv-forward-field)
    ("b" csv-backward-field)
    ("n" next-line)
    ("p" previous-line)
    ("t" csv-transpose)
    ("s" csv-sort-fields)
    ("S" csv-sort-numeric-fields)
    ("a" csv-align-fields)
    ("A" csv-unalign-fields)
    ("r" csv-reverse-region)
    ("d" csv-toggle-descending)
    ("T" csv-toggle-invisibility)
    ("k" csv-kill-fields)
    ("y" csv-yank-fields)
    ("Y" csv-yank-as-new-table)
    ("u" undo "undo")
    ("q" nil "quit" :color blue))

  (setq csv-invisibility-default nil)

  (defun csv--align-buffer ()
    (save-excursion
      (csv-align-fields t (point-min) (point-max))))

  (defun csv--next-or-new-field ()
    (cond ((looking-at ",$")
           (forward-char 1)
           (save-excursion (insert ",")))
          ((eq (point) (point-at-eol))
           (insert ","))
          (t
           (unless (re-search-forward "," nil t)
             (end-of-line))))
    (csv--align-buffer))

  (defun csv-tab-to-next-field ()
    (interactive)
    (if (or (mapcar #'looking-at csv-separators))
        (csv--next-or-new-field)
      (yas-expand)))

  (defun csv--previous-field ()
    (re-search-backward "," nil t))

  (defun csv-backtab-to-previous-field ()
    (interactive)
    (when (or (mapcar #'looking-at csv-separators))
      (csv--previous-field)))

  (defun csv--new-line-or-next-field ()
    (cond ((and (looking-back "," (- (point) 2))
                (eq (point) (point-at-eol)))
           (delete-char -1)
           (unless (re-search-forward "," nil t)
             (newline)))
          (t
           (if (eq (point) (point-max))
               (newline)
             (next-line))))
    (csv--align-buffer))

  (defun csv-new-line-or-next-field ()
    (interactive)
    (when (mapcar #'looking-at csv-separators)
      (csv--new-line-or-next-field)))

  (general-define-key
   :keymaps 'csv-mode-map
    "<tab>" 'csv-tab-to-next-field
    "<backtab>" 'csv-backtab-to-previous-field
    "RET" 'csv-new-line-or-next-field))

;; ---------- D --------------------------------------------------
(use-package debian-control-mode
  :load-path "~/.emacs.d/private/dcf/"
  :commands debian-control-mode
  :mode (("DESCRIPTION" . debian-control-mode)))

(use-package dired
  :bind* (("C-x d" . dired-other-window)
          ("C-x C-d" . dired))
  :commands (dired)
  :config
  (use-package dired-x
    :bind* (("C-x C-'" . dired-jump))
    :commands (dired-omit-mode)
    :init
    (add-hook 'dired-load-hook (lambda () (load "dired-x")))
    (add-hook 'dired-mode-hook #'dired-omit-mode)
    :config
    (setq dired-omit-verbose nil)
    (setq dired-omit-files
          (concat dired-omit-files "\\|^\\..*$\\|^.DS_Store$\\|^.projectile$\\|^.git$")))

  (use-package dired-details+ :ensure t
    :config
    (dired-details-install)
    (setq-default dired-details-hidden-string " --- "
                  dired-details-hide-link-targets nil))

  (use-package dired-sort :ensure t
    :defines (hydra-dired-sort/body)
    :commands (hydra-dired-sort/body
               dired-sort-name
               dired-sort-size
               dired-sort-time
               dired-sort-ctime
               dired-sort-utime
               dired-sort-extension)
    :config
    (defhydra hydra-dired-sort
      (:color blue
       :hint nil
       :post (hydra-dired-main/body))
      "
_n_ame
_s_ize
_t_ime
_e_xtension"
      ("n" dired-sort-name)
      ("s" dired-sort-size)
      ("t" dired-sort-time)
      ("e" dired-sort-extension)))

  (use-package dired-quick-sort :ensure t
    ;; press S in dired to see a nice hydra for sorting
    :config
    (dired-quick-sort-setup))


  (let ((gls "/usr/local/bin/gls"))
    (if (file-exists-p gls)
        (setq insert-directory-program gls)))

  (setq dired-listing-switches "-XGalg --group-directories-first --human-readable --dired")
  (setq dired-dwim-target t)     ; guess copy target based on other dired window

  (defun dired-view-other-window ()
    "View the current file in another window (possibly newly created)."
    (interactive)
    (if (not (window-parent))
        (split-window))
    (let ((file (dired-get-file-for-visit))
          (dbuffer (current-buffer)))
      (other-window 1)
      (unless (equal dbuffer (current-buffer))
        (if (or view-mode (equal major-mode 'dired-mode))
            (kill-buffer)))
      (let ((filebuffer (get-file-buffer file)))
        (if filebuffer
            (switch-to-buffer filebuffer)
          (view-file file))
        (other-window -1))))

  (defun dired-mkdir-date (dir-name)
    "Make a directory with current date style"
    (interactive "sDirectory content: ")
    (mkdir (format "%s-%s" (format-time-string "%Y-%m-%d" (current-time)) dir-name))
    (revert-buffer))

  (defun dired-mkdir-date-rstyle (dir-name)
    (interactive "sDirectory content: ")
    (mkdir (format "%s.%s" dir-name (format-time-string "%Y%m%d" (current-time))))
    (revert-buffer))

  (bind-keys :map dired-mode-map
    ("SPC" . dired-view-other-window)
    ("."   . hydra-dired-main/body)
    ("t"   . dired-next-line)
    ("s"   . dired-previous-line)
    ("r"   . dired-find-file)
    ("c"   . dired-up-directory)
    ("'"   . eshell-here)
    ("8"   . dired-mkdir-date)
    ("9"   . dired-mkdir-date-rstyle)
    ("C-'" . shell)
    ("q"   . (lambda () (interactive) (quit-window 4)))))


(use-package display-time
  :commands
  display-time-mode
  :config
  (setq display-time-24hr-format t
        display-time-day-and-date t
        display-time-format))

(use-package dumb-jump :ensure t
  :bind (("M-g o" . dumb-jump-go-other-window)
         ("M-g g" . dumb-jump-go))
  :config
  (setq dumb-jump-selector 'ivy
        dumb-jump-searcher "rg"))

;; ---------- E --------------------------------------------------
(use-package ebib
  :quelpa (ebib :fetcher github :repo "joostkremers/ebib")
  :commands (ebib)
  :config
  (require 'org-ebib)

  (general-define-key
   :keymaps 'ebib-index-mode-map
    "." 'hydra-ebib/body
    "p" 'hydra-ebib/ebib-prev-entry
    "n" 'hydra-ebib/ebib-next-entry
    "C-p" 'hydra-ebib/ebib-push-bibtex-key-and-exit
    "C-n" 'hydra-ebib/ebib-search-next)

  (setq ebib-file-associations '(("pdf"  . "open")
                                 ("ps"   . "open")
                                 ("html" . "open")))

  (setq ebib-preload-bib-files '("~/Dropbox/bibliography/references.bib")
        ebib-notes-use-single-file "~/dotfile/bibliographie/notes.org")

  (defun my-ebib ()
    (interactive)
    (ebib)
    (my-ebib-reload-all-databases))

  (defun my-ebib-reload-all-databases ()
    (interactive)
    (shell-command "bash ~/Dropbox/bibliography/export-postprocess.bash")
    (ebib-reload-all-databases))

  (defhydra hydra-ebib (:hint nil :color blue)
    "
     ^Nav^            ^Open^           ^Search^        ^Action^
     ^---^            ^----^           ^------^        ^------^
  _n_: next        _e_: entry       _/_: search     _m_: mark
  _p_: prev        _i_: doi       _C-n_: next       _a_: add entry
_M-n_: next db     _u_: url         ^ ^             _r_: reload
_M-p_: prev db     _f_: file        ^ ^           _C-p_: push key
^   ^              _N_: note        ^ ^           ^   ^
"
    ("a" ebib-add-entry)
    ("e" ebib-edit-entry)
    ("f" ebib-view-file)
    ("g" ebib-goto-first-entry)
    ("G" ebib-goto-last-entry)
    ("i" ebib-browse-doi)
    ("m" ebib-mark-entry :color red)
    ("n" ebib-next-entry :color red)
    ("N" ebib-open-note)
    ("C-n" ebib-search-next :color red)
    ("M-n" ebib-next-database :color red)
    ("p" ebib-prev-entry :color red)
    ("C-p" ebib-push-bibtex-key)
    ("M-p" ebib-prev-database :color red)
    ("r" my-ebib-reload-all-databases :color red)
    ("u" ebib-browse-url)
    ("/" ebib-search :color red)
    ("?" ebib-info)
    ("q" ebib-quit "quit")
    ("." nil "toggle")))

(use-package edebug
  :defer t
  :config
  (setq edebug-active nil)
  (setq edebug-outside-windows t))

(use-package eldoc :ensure t
  :commands turn-on-eldoc-mode
  :diminish ""
  :init
  (add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
  (add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode))

(use-package elfeed :ensure t
  :bind* ("C-c E" . elfeed)
  :config

  (use-package elfeed-org :ensure t
    :config
    (setq rmh-elfeed-org-files (list "~/dotfile/emacs/elfeed.org"))
    (elfeed-org))

  (bind-keys
   :map elfeed-search-mode-map
    ("f" . hydra-elfeed-navigate/body)
    ("." . hydra-elfeed/body))

  (defhydra hydra-elfeed (:color pink :hint nil :columns 3)
    "
^ACTIONS^     ^ ^          ^MARK^       ^TAG^
_u_: update   _b_: browse  _r_: read    _+_: add
_g_: fetch    _y_: yank    _u_: unread  _-_: remove
_s_: search   _f_: filter
"
    ("u" elfeed-search-update--force)
    ("g" elfeed-search-fetch)
    ("s" elfeed-search-live-filter)
    ("b" elfeed-search-browse-url)
    ("y" elfeed-search-yank)
    ("r" elfeed-search-untag-all-unread)
    ("u" elfeed-search-tag-all-unread)
    ("+" elfeed-search-tag-all)
    ("-" elfeed-search-untag-all)
    ("f" hydra-elfeed-navigate/body :color blue)
    ("q" (message "Abort.") "Quit" :color blue))

  (defhydra hydra-elfeed-navigate (:hint nil :color pink :columns 1)
    "filter"
    ("*" (elfeed-search-set-filter "@6-months-ago +star") "Starred")
    ("a" (elfeed-search-set-filter "@6-months-ago -cs") "all")
    ("b" (elfeed-search-set-filter "@6-months-ago +bio") "bio")
    ("c" (elfeed-search-set-filter "@6-months-ago +compsci -pkg") "cs")
    ("e" (elfeed-search-set-filter "@6-months-ago +emacs") "emacs")
    ("i" (elfeed-search-set-filter "@6-months-ago +bioinfo") "bioinfo")
    ("n" (elfeed-search-set-filter "@6-months-ago +news") "news")
    ("p" (elfeed-search-set-filter "@6-months-ago +pkg") "pkg")
    ("r" (elfeed-search-set-filter "@6-months-ago +rstat") "rstat")
    ("T" (elfeed-search-set-filter "@1-day-ago") "Today")
    ("M" elfeed-toggle-star "Mark")
    ("q" hydra-elfeed/body "quit" :color blue))

  (setq-default elfeed-search-filter "@6-months-ago +unread -pkg -cran"))

(use-package emacs-lisp-mode
  :mode
  (("*scratch*" . emacs-lisp-mode))
  :init
  (add-hook 'emacs-lisp-mode-hook
            (lambda ()
              (setq-local lisp-indent-function #'Fuco1/lisp-indent-function)
              (setq-local outline-regexp ";; ----------\\|^;;;")))

  (general-define-key
   :keymaps 'emacs-lisp-mode-map
   :prefix "ê"
    "" '(:ignore t :which-key "Emacs Help")
    "f" 'counsel-describe-function
    "k" 'counsel-descbinds
    "v" 'counsel-describe-variable
    "e" 'eval-last-sexp
    "b" 'eval-buffer
    "c" '(sam--eval-current-form-sp :which-key "eval-current")
    "u" 'use-package-jump
    "t" '(lispy-goto :which-key "goto tag")))

(use-package emacsc :ensure t)

(use-package ereader :ensure t
  :mode (("\\.epub\\'" . ereader-mode)))

(use-package eshell
  :defines eshell-here
  :commands (eshell
             eshell-here)
  :config
  (use-package eshell-z :ensure t)

  (setq eshell-where-to-jump 'begin
        eshell-review-quick-commands nil
        eshell-smart-space-goes-to-end t
        eshell-list-files-after-cd t
        eshell-ls-initial-args "-alh")

  (setq eshell-directory-name "~/dotfile/emacs/eshell/")

  ;; from http://www.howardism.org/Technical/Emacs/eshell-fun.html
  (defun eshell-here ()
    "
Opens up a new shell in the directory associated with the
current buffer's file. The eshell is renamed to match that
directory to make multiple eshell windows easier.
"
    (interactive)
    (let* ((parent (if (buffer-file-name)
                       (file-name-directory (buffer-file-name))
                     default-directory))
           (height (/ (window-total-height) 3))
           (name   (car (last (split-string parent "/" t)))))
      (split-window-vertically (- height))
      (other-window 1)
      (eshell "new")
      (rename-buffer (concat "*eshell: " name "*"))

      (insert (concat "ls"))
      (eshell-send-input)))

  (defun eshell/ll ()
    (insert "ls -l")
    (eshell-send-input))

  (general-define-key
   :keymaps 'eshell-mode-map
    "<tab>" (lambda () (interactive) (pcomplete-std-complete))
    "C-'" (lambda () (interactive) (insert "exit") (eshell-send-input) (delete-window))))

(use-package ess-site
  :ensure ess
  :mode
  (("\\.sp\\'"           . S-mode)
   ("/R/.*\\.q\\'"       . R-mode)
   ("\\.[qsS]\\'"        . S-mode)
   ("\\.ssc\\'"          . S-mode)
   ("\\.SSC\\'"          . S-mode)
   ("\\.[rR]\\'"         . R-mode)
   ("\\.[rR]nw\\'"       . Rnw-mode)
   ("\\.[sS]nw\\'"       . Snw-mode)
   ("\\.[rR]profile\\'"  . R-mode)
   ("NAMESPACE\\'"       . R-mode)
   ("CITATION\\'"        . R-mode)
   ("\\.omg\\'"          . omegahat-mode)
   ("\\.hat\\'"          . omegahat-mode)
   ("\\.lsp\\'"          . XLS-mode)
   ("\\.do\\'"           . STA-mode)
   ("\\.ado\\'"          . STA-mode)
   ("\\.[Ss][Aa][Ss]\\'" . SAS-mode)
   ("\\.jl\\'"           . ess-julia-mode)
   ("\\.[Ss]t\\'"        . S-transcript-mode)
   ("\\.Sout"            . S-transcript-mode)
   ("\\.[Rr]out"         . R-transcript-mode)
   ("\\.Rd\\'"           . Rd-mode)
   ("\\.[Bb][Uu][Gg]\\'" . ess-bugs-mode)
   ("\\.[Bb][Oo][Gg]\\'" . ess-bugs-mode)
   ("\\.[Bb][Mm][Dd]\\'" . ess-bugs-mode)
   ("\\.[Jj][Aa][Gg]\\'" . ess-jags-mode)
   ("\\.[Jj][Oo][Gg]\\'" . ess-jags-mode)
   ("\\.[Jj][Mm][Dd]\\'" . ess-jags-mode))
  :commands
  (R stata julia SAS)

  :init
  (add-hook 'ess-mode-hook 'company-mode)
  (add-hook 'ess-mode-hook (lambda () (run-hooks 'prog-mode-hook 'company-mode-hook)))
  (add-hook 'ess-R-post-run-hook (lambda () (smartparens-mode 1)))
  (add-hook 'ess-mode-hook (lambda () (lesspy-mode 1)))
  (add-hook 'ess-mode-hook (lambda () (aggressive-indent-mode -1)))
  (add-hook 'ess-mode-hook (lambda () (setq-local outline-regexp "### ----------\\|^##' #\\|^#' #")))
  (add-hook 'inferior-ess-mode-hook (lambda () (setq-local outline-regexp "^>")))
  (setq ess-offset-continued 2           ; offset after first statement
        ess-expression-offset 2          ; offset for expression
        ess-nuke-trailing-whitespace-p t ;delete trailing whitespace
        ess-default-style 'RStudio)      ; set default style for R source file

  (setq ess-indent-with-fancy-comments nil)
  ;; do not truncate line in the R repl:
  (add-hook 'inferior-ess-mode-hook (lambda () (toggle-truncate-lines 1)))
  :config
  ;; config for R
  (load-file "~/dotfile/emacs/ess-config.el")

  (bind-keys :map julia-mode-map
    ("RET" . (lambda () (interactive) (ess-roxy-newline-and-indent)))))

(use-package esup :ensure t
  :commands esup)

(use-package etags-select :ensure t
  :defines (sam-find-tag
            build-ctags
            visit-project-tags)
  :bind* ("M-s-." . sam-find-tag)
  :commands (build-ctags
             visit-project-tags)
  :config
  ;; from http://mattbriggs.net/blog/2012/03/18/awesome-emacs-plugins-ctags/
  (defun build-ctags ()
    (interactive)
    (message "building project tags")
    (let ((root (projectile-project-root)))
      (shell-command (concat "ctags -e -R --extra=+fq --exclude=bin --exclude=db --exclude=test --exclude=.git --exclude=public -f " root "TAGS " root)))
    (visit-project-tags)
    (message "tags built successfully"))

  (defun visit-project-tags ()
    (interactive)
    (let ((tags-file (concat (projectile-project-root) "TAGS")))
      (visit-tags-table tags-file)
      (message (concat "Loaded " tags-file))))

  (defun sam-find-tag ()
    (interactive)
    (if (file-exists-p (concat (projectile-project-root) "TAGS"))
        (visit-project-tags)
      (build-ctags))
    (etags-select-find-tag-at-point)))

(use-package exec-path-from-shell :ensure t
  :defer 2
  :commands (exec-path-from-shell-initialize
             exec-path-from-shell-copy-env)
  :init
  (setq exec-path-from-shell-check-startup-files nil)
  :config
  (exec-path-from-shell-initialize))

(use-package expand-region :ensure t
  :defines hydra-expand-region/body
  :bind (("C-=" . er/expand-region)
         ("s-=" . hydra-expand-region/er/expand-region)
         ("C-°" . er/contract-region)
         ("s-°" . hydra-expand-region/er/contract-region))
  :config
  (setq expand-region-fast-keys-enabled nil)
  (defhydra hydra-expand-region (:color red :hint nil)
    "
^Expand region^   ^Cursors^
_c_: expand       _n_: next
_r_: contract     _p_: prev
_e_: exchange
_R_: reset
"
    ("c" er/expand-region)
    ("r" er/contract-region)
    ("e" exchange-point-and-mark)
    ("R" (lambda () (interactive)
           (let ((current-prefix-arg '(0)))
             (call-interactively #'er/contract-region))) :color blue)
    ("n" hydra-mc/mc/mark-next-like-this :color blue)
    ("p" hydra-mc/mc/mark-previous-like-this :color blue)
    ("q" nil "quit" :color blue)))

;; ---------- F --------------------------------------------------
(use-package fastx
  :load-path "~/.emacs.d/private/fastx"
  :mode (("\\.fasta$" . fastx-mode)
         ("\\.fa$" . fastx-mode)
         ("\\.fst$" . fastx-mode)
         ("\\.fastq$" . fastq-mode)
         ("\\.fq$" . fastq-mode))
  :bind (:map fastx-mode-map
         ("c" . fastx-hide-sequence)
         ("t" . fastx-next-sequence)
         ("s" . fastx-prev-sequence)
         ("r" . fastx-show-sequence)))


(use-package fish-mode :ensure t
  :mode (("\\.fish$" . fish-mode)))

(use-package flx :ensure t)

(use-package flycheck :ensure t
  :commands flycheck-mode
  :diminish (flycheck-mode . "ⓕ")
  :config
  (setq flycheck-highlighting-mode 'symbols))

;; ---------- G --------------------------------------------------
(use-package geiser :ensure t
  :defer t)

(use-package ggtags :ensure t
  :commands (ggtags-mode)
  :config
  (general-define-key :keymaps 'ggtags-mode-map
    "M-s-," 'ggtags-navigation-mode-abort
    "M-s-." 'ggtags-find-tag-dwim))

(use-package git-gutter :ensure t
  :disabled t
  :diminish ""
  :commands (global-git-gutter-mode)
  :init
  (global-git-gutter-mode +1)
  (setq git-gutter:modified-sign "|")
  (setq git-gutter:added-sign "|")
  (setq git-gutter:deleted-sign "|")
  :config
  (setq git-gutter:update-interval 20)
  (git-gutter:linum-setup))

(use-package google-this :ensure t
  :bind (("C-x g" . google-this-mode-submap)
         ("C-x G" . google-this)))

(use-package go-mode
  :load-path "~/.emacs.d/private/go-mode.el/"
  :mode (("\\.go\\'" . go-mode))
  :config
  (when (memq window-system '(mac ns x))
    (dolist (var '("GOPATH" "GO15VENDOREXPERIMENT"))
      (unless (getenv var)
        (exec-path-from-shell-copy-env var))))

  (use-package company-go :ensure t
    :config
    (setq company-go-gocode-command "~/bin/gocode")
    (setq company-go-show-annotation t)
    (add-hook 'go-mode-hook
              (lambda ()
                (set (make-local-variable 'company-backends) '(company-go))
                (company-mode))))

  (use-package go-eldoc :ensure t
    :config
    (add-hook 'go-mode-hook 'go-eldoc-setup))

  (use-package go-playground :ensure t
    :commands (go-playground))

  (use-package gorepl-mode :ensure t
    :commands (gorepl-run
               gorepl-mode)
    :init (add-hook 'go-mode-hook #'gorepl-mode))

  (use-package go-guru
    :config
    (add-hook 'go-mode-hook #'go-guru-hl-identifier-mode)

    (key-seq-define go-mode-map "xq" 'hydra-go-guru/body)
    (defhydra hydra-go-guru (:color pink :columns 2 :hint nil)
      "
^NAME^             ^TYPE^            ^CALL^           ^ALIAS^
_._: definition    _d_: describe     _lr_: callers     _p_: pointsto
_r_: referrers     _i_: implement    _le_: callees     _c_: peers
_f_: freevars      ^ ^               _s_: callstack    _e_: whicherrs"
      ("." go-guru-definition)
      ("r" go-guru-referrers)
      ("f" go-guru-freevars)
      ("d" go-guru-describe)
      ("i" go-guru-implements)
      ("lr" go-guru-callers)
      ("le" go-guru-callees)
      ("s" go-guru-callstack)
      ("p" go-guru-pointsto)
      ("c" go-guru-peers)
      ("e" go-guru-whicherrs)
      ("S" go-guru-set-scope "scope" :color blue)))

  (use-package flycheck-gometalinter :ensure t
    :config
    (setq flycheck-disabled-checkers '(go-gofmt go-golint go-vet go-build go-test go-errcheck))
    (flycheck-gometalinter-setup))

  (setq godoc-and-godef-command "/usr/local/bin/godoc")
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save)
  ;; set tab width
  (add-hook 'go-mode-hook (lambda () (setq-local tab-width 4)))

  (dolist (delim '("{" "(" "["))
    (sp-local-pair 'go-mode delim nil
                   :post-handlers '((sam--create-newline-and-enter-sexp "RET"))))

  ;; from https://github.com/syl20bnr/spacemacs/blob/master/layers/%2Blang/go/packages.el
  (defun go-run-main ()
    (interactive)
    (async-shell-command
     (format "go run %s"
             (shell-quote-argument (buffer-file-name)))))


  (defun my-go-mode-hook ()
    ;; Call Gofmt before saving
    (add-hook 'before-save-hook 'gofmt-before-save)
    (if (not (string-match "go" compile-command))
        (set (make-local-variable 'compile-command)
             "go build -v && go test -v && go vet"))
    ;; godef jump key binding
    (local-set-key (kbd "M-.") 'godef-jump)
    (local-set-key (kbd "M-*") 'pop-tag-mark))
  (add-hook 'go-mode-hook 'my-go-mode-hook)

  ;; keybindings
  (general-define-key
   :keymaps 'go-mode-map
    "C-," 'hydra-go/body)

  (defhydra hydra-go (:hint nil :color teal)
    "
         ^Command^      ^Imports^       ^Doc^
         ^-------^      ^-------^       ^---^
      _r_: run      _ig_: goto       _d_: doc at point
    [_g_]: guru     _ia_: add
    ^  ^            _ir_: remove
    "
    ("g" hydra-go-guru/body :color blue)
    ("r" go-run-main)
    ("d" godoc-at-point)
    ("ig" go-goto-imports )
    ("ia" go-import-add)
    ("ir" go-remove-unused-imports)
    ("q" nil "quit" :color blue)))

(use-package goto-chg :ensure t
  :commands (goto-last-change
             goto-last-change-reverse))

(use-package grab-mac-link :ensure t
  :commands grab-mac-link)

;; ---------- H --------------------------------------------------
(use-package haskell-mode :ensure t
  :mode (("\\.hs\\'" . haskell-mode))
  :config
  (use-package intero :ensure t
    :init
    (add-hook 'haskell-mode-hook 'intero-mode)
    :commands (intero-mode)
    :diminish " λ"))

(use-package helm-config
  :ensure helm
  ;; disabled for now, but I've copy and pasted here the advice from
  ;; tuhdo about helm.
  :disabled t
  :config
  (setq
   ;; open helm buffer inside current window, not occupy whole other window
   helm-split-window-in-side-p t
   ;; input close to where I type
   helm-echo-input-in-header-line t)

  (defun helm-hide-minibuffer-maybe ()
    "Hide minibuffer in Helm session if we use the header line as input field."
    (when (with-helm-buffer helm-echo-input-in-header-line)
      (let ((ov (make-overlay (point-min) (point-max) nil nil t)))
        (overlay-put ov 'window (selected-window))
        (overlay-put ov 'face
                     (let ((bg-color (face-background 'default nil)))
                       `(:background ,bg-color :foreground ,bg-color)))
        (setq-local cursor-type nil))))

  (add-hook 'helm-minibuffer-set-up-hook 'helm-hide-minibuffer-maybe)

  (setq helm-autoresize-max-height 0)
  (setq helm-autoresize-min-height 20)
  (helm-autoresize-mode 1))

(use-package helm-make
  :bind* (("C-c C" . helm-make)
          ("C-c p c" . helm-make-projectile))
  :config
  (setq helm-make-completion-method 'ivy))

(use-package helm-google :ensure t
  :commands (helm-google))

(use-package helm-gitignore :ensure t
  :commands helm-gitignore)

(use-package hideshow
  :commands hs-minor-mode
  :diminish hs-minor-mode
  :init
  (add-hook 'prog-mode-hook 'hs-minor-mode))

(use-package hjkl
  :load-path "~/.emacs.d/private/hjkl"
  :config

  (setq hjkl-up    (kbd "s"))
  (setq hjkl-down  (kbd "t"))
  (setq hjkl-left  (kbd "c"))
  (setq hjkl-right (kbd "r"))
  (setq hjkl-other (kbd "d"))
  (setq hjkl-eval  (kbd "e"))
  (setq hjkl-jump  (kbd "a"))
  (setq hjkl-mark  (kbd "m"))

  (setq
   hjkl-bindings
   '(;; (:keymap emacs-lisp-mode-map
     ;;  :bind (:up ((")" (lambda () (backward-list 2) (forward-list 1)) t)
     ;;              ("(" #'backward-list)
     ;;              (outline-regexp #'outline-previous-heading nil))
     ;;         :down ((")" (lambda () (forward-list)) t)
     ;;                ("(" (lambda () (forward-list 2) (backward-list)))
     ;;                (outline-regexp #'outline-next-heading nil))
     ;;         :left ((")" #'sp-backward-down-sexp t)
     ;;                ("(" #'sp-backward-up-sexp)
     ;;                (outline-regexp #'outline-hide-entry))
     ;;         :right ((")" #'sp-up-sexp t)
     ;;                 ("(" #'sp-down-sexp)
     ;;                 (outline-regexp #'outline-show-subtree))
     ;;         :other (("(\\|{\\|\\[" #'forward-list)
     ;;                 (")\\|}\\|]" #'backward-list t))
     ;;         :eval ((")" (lambda () (eval-last-sexp nil)) t)
     ;;                ("(" (lambda () (save-excursion
     ;;                             (forward-list)
     ;;                             (eval-last-sexp nil)))))
     ;;         :mark ((")"
     ;;                 (lambda ()
     ;;                   (backward-list)
     ;;                   (mark-sexp)
     ;;                   (exchange-point-and-mark))
     ;;                 t)
     ;;                ("(" #'mark-sexp))))

     ;; (:keymap text-mode-map
     ;;  :bind (:up (("\\.\\|?\\|!" (lambda () (backward-sentence) (backward-char)) t)
     ;;              (outline-regexp #'outline-previous-heading))
     ;;         :down (("\\.\\|?\\|!" #'forward-sentence t)
     ;;                (outline-regexp #'outline-next-heading))
     ;;         :left ((outline-regexp #'outline-hide-leaves))
     ;;         :right ((outline-regexp #'outline-show-subtree))))

     ))
  (hjkl-update-keys))

(use-package hl-line
  ;; souligne la ligne du curseur
  :init
  (global-hl-line-mode -1))

(use-package htmlize :ensure t
  :defer t)

(use-package hungry-delete :ensure t
  :diminish ""
  :config
  (global-hungry-delete-mode))

(use-package hydra :ensure t
  :config
  (setq hydra-is-helpful t))

(use-package hy-mode :ensure t
  :mode (("\\.hy\\'" . hy-mode))
  :init
  (add-hook 'hy-mode-hook (lambda () (lispy-mode 1))))

;; ---------- I --------------------------------------------------
(use-package ibuffer :ensure t
  :commands ibuffer
  :init
  (add-hook 'ibuffer-hook (lambda () (ibuffer-switch-to-saved-filter-groups "Default")))
  :config
  (use-package ibuffer-vc :ensure t
    :config
    (setq ibuffer-vc-set-filter-groups-by-vc-root t))

  (define-key ibuffer-mode-map "." 'hydra-ibuffer-main/body)
  (general-define-key
   :keymaps 'ibuffer-mode-map
    "." 'hydra-ibuffer-main/body
    "t" 'next-line
    "s" 'previous-line
    "r" 'ibuffer-visit-buffer
    "c" 'ibuffer-backward-filter-group
    "p" 'ibuffer-backward-filter-group
    "n" 'ibuffer-forward-filter-group)
  (setq-default ibuffer-saved-filter-groups
                `(("Default"
                   ("RStat" (mode . ess-mode))
                   ("Org" (mode . org-mode))
                   ("Markdown" (mode . markdown-mode))
                   ("Bash" (or (mode . shell-script-mode)))
                   ("Dired" (mode . dired-mode))
                   ("PDF" (mode . pdf-view-mode))
                   ("Mail" (or (mode . message-mode)
                               (mode . bbdb-mode)
                               (mode . mail-mode)
                               (mode . mu4e-compose-mode)))
                   ("Elisp" (mode . emacs-lisp-mode))
                   ("shell" (or (mode . eshell-mode)
                                (mode . shell-mode)))
                   ("Music" (or (mode . bongo-mode)
                                (mode . bongo-library-mode)
                                (mode . bongo-playlist-mode)))
                   ("Temp" (name . "\*.*\*")))))
  (setq ibuffer-show-empty-filter-groups nil)
  (setq ibuffer-display-summary t))

(use-package ido
  :defer t
  :config
  (general-define-key :keymaps 'ido-completion-map
    "C-n" 'ido-next-match
    "C-p" 'ido-prev-match))

(use-package iedit :ensure t
  :defines hydra-iedit/body
  :bind* (:map global-map
          ("C-*" . iedit-mode)
          :map iedit-mode-keymap
          ("M-n" . iedit-next-occurence)
          ("M-p" . iedit-prev-occurence))
  :config
  (defhydra hydra-iedit (:color pink :columns 1)
    "IEDIT"
    ("C-*" iedit-mode "toggle")
    ("C-p" iedit-prev-occurrence "prev")
    ("C-n" iedit-next-occurrence "next")
    ("C-g" iedit-quit :color blue "toggle")))

(use-package imenu-anywhere
  :quelpa (imenu-anywhere :fetcher github :repo "vspinu/imenu-anywhere")
  :bind* (("C-c i" . ivy-imenu-anywhere))
  )

(use-package indent-tools :ensure t
  :bind (("C-c C-i" . indent-tools-hydra/body)))

(use-package info
  :mode (("\\.info\\'" . Info-mode))
  :config
  (define-key Info-mode-map (kbd ".") #'hydra-info/body)

  (defhydra hydra-info (:color pink
                        :hint nil)
    "
Info-mode:

  ^^_]_ forward  (next logical node)       ^^_l_ast (←)        _u_p (↑)                             _f_ollow reference       _T_OC
  ^^_[_ backward (prev logical node)       ^^_r_eturn (→)      _m_enu (↓) (C-u for new window)      _i_ndex                  _d_irectory
  ^^_n_ext (same level only)               ^^_H_istory         _g_oto (C-u for new window)          _,_ next index item      _c_opy node name
  ^^_p_rev (same level only)               _<_/_t_op           _b_eginning of buffer                virtual _I_ndex          _C_lone buffer
  regex _s_earch (_S_ case sensitive)      ^^_>_ final         _e_nd of buffer                      ^^                       _a_propos

  _1_ .. _9_ Pick first .. ninth item in the node's menu.

"
    ("]"   Info-forward-node)
    ("["   Info-backward-node)
    ("n"   Info-next)
    ("p"   Info-prev)
    ("s"   Info-search)
    ("S"   Info-search-case-sensitively)

    ("l"   Info-history-back)
    ("r"   Info-history-forward)
    ("H"   Info-history)
    ("t"   Info-top-node)
    ("<"   Info-top-node)
    (">"   Info-final-node)

    ("u"   Info-up)
    ("^"   Info-up)
    ("m"   Info-menu)
    ("g"   Info-goto-node)
    ("b"   beginning-of-buffer)
    ("e"   end-of-buffer)

    ("f"   Info-follow-reference)
    ("i"   Info-index)
    (","   Info-index-next)
    ("I"   Info-virtual-index)

    ("T"   Info-toc)
    ("d"   Info-directory)
    ("c"   Info-copy-current-node-name)
    ("C"   clone-buffer)
    ("a"   info-apropos)

    ("1"   Info-nth-menu-item)
    ("2"   Info-nth-menu-item)
    ("3"   Info-nth-menu-item)
    ("4"   Info-nth-menu-item)
    ("5"   Info-nth-menu-item)
    ("6"   Info-nth-menu-item)
    ("7"   Info-nth-menu-item)
    ("8"   Info-nth-menu-item)
    ("9"   Info-nth-menu-item)

    ("?"   Info-summary "Info summary")
    ("h"   Info-help "Info help")
    ("q"   Info-exit "Info exit")
    ("C-g" nil "cancel" :color blue))
  )

(use-package "isearch"
  :bind* (("C-s" . isearch-forward)
          ("C-r" . isearch-backward))
  :config
  (defun symbol-name-at-point ()
    (let ((symbol (symbol-at-point)))
      (if symbol (symbol-name symbol) "")))

  (defun current-thing ()
    "Return the current \"thing\":
- if the region is active, return the region's text and deactivate the mark
- else return the symbol at point or the empty string."
    (let ((thing (if (region-active-p)
                     (buffer-substring (region-beginning) (region-end))
                   (symbol-name-at-point))))
      (deactivate-mark) thing))

  (defun isearch-thing ()
    "Search for the current \"thing\":
- if the region is active, return the region's text and deactivate the mark
- else return the symbol at point or the empty string."
    (interactive)
    (isearch-yank-string (current-thing)))

  (define-key isearch-mode-map (kbd "C-t") #'isearch-thing))

(use-package ispell :ensure t
  :defines ispell-word-then-abbrev
  :commands (ispell-word-then-abbrev
             ispell)
  :bind* (("s-:" . ispell)
          :map ctl-x-map
          ("C-i" . ispell-word-then-abbrev))
  :config

  (setq ispell-dictionary "francais")

  (defun ispell-word-then-abbrev (p)
    "Call `ispell-word', then create an abbrev for it.
With prefix P, create local abbrev. Otherwise it will
be global.
If there's nothing wrong with the word at point, keep
looking for a typo until the beginning of buffer. You can
skip typos you don't want to fix with `SPC', and you can
abort completely with `C-g'."
    (interactive "P")
    (let (bef aft)
      (save-excursion
        (while (if (setq bef (sam--simple-get-word))
                   ;; Word was corrected or used quit.
                   (if (ispell-word nil 'quiet)
                       nil              ; End the loop.
                     ;; Also end if we reach `bob'.
                     (not (bobp)))
                 ;; If there's no word at point, keep looking
                 ;; until `bob'.
                 (not (bobp)))
          (backward-word)
          (backward-char))
        (setq aft (sam--simple-get-word)))
      (if (and aft bef (not (equal aft bef)))
          (let ((aft (downcase aft))
                (bef (downcase bef)))
            (define-abbrev
              (if p local-abbrev-table global-abbrev-table)
              bef aft)
            (message "\"%s\" now expands to \"%s\" %sally"
                     bef aft (if p "loc" "glob")))
        (user-error "No typo at or before point")))))

(use-package isend-mode :ensure t
  :commands (isend-associate
             isend-send
             isend-send-buffer
             isend-send-defun
             isend-display-buffer)
  :bind (:map sh-mode-map
         ("C-<return>" . isend-send)))

(use-package ivy
  :quelpa (ivy :fetcher github :repo "abo-abo/swiper")
  :diminish (ivy-mode . "")
  :commands (ivy-switch-buffer
             ivy-switch-buffer-other-window)
  :config
  (ivy-mode 1)

  (setq ivy-use-virtual-buffers t)
  (setq ivy-height 10)
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-initial-inputs-alist nil)
  ;; from https://github.com/company-mode/company-statistics
  ;; ignore buffers in the ignore buffer list.
  (setq ivy-use-ignore-default 'always)
  (setq ivy-ignore-buffers '("company-statistics-cache.el" "company-statistics-autoload.el"))
  ;; if ivy-flip is t, presents results on top of query.
  (setq ivy-flip t)
  (setq ivy-overlay-at nil)
  (setq ivy-re-builders-alist '((t      . ivy--regex-ignore-order)))

  (defun ivy--matcher-desc ()
    (if (eq ivy--regex-function
            'ivy--regex-fuzzy)
        "fuzzy"
      "ivy"))

  (defhydra hydra-ivy (:hint nil
                       :color pink)
    "
^ ^ ^ ^ ^ ^ | ^Call^      ^ ^  | ^Cancel^ | ^Options^ | Action _b_/_é_/_p_: %-14s(ivy-action-name)
^-^-^-^-^-^-+-^-^---------^-^--+-^-^------+-^-^-------+-^^^^^^^^^^^^^^^^^^^^^^^^^^^^^---------------------------
^ ^ _s_ ^ ^ | _f_ollow occ_u_r | _i_nsert | _C_: calling %-5s(if ivy-calling \"on\" \"off\") _C-c_ase-fold: %-10`ivy-case-fold-search
_c_ ^+^ _r_ | _d_one      ^ ^  | _o_ops   | _m_: matcher %-5s(ivy--matcher-desc)^^^^^^^^^^^^ _T_runcate: %-11`truncate-lines
^ ^ _t_ ^ ^ | _g_o        ^ ^  | ^ ^      | _<_/_>_: shrink/grow^^^^^^^^^^^^^^^^^^^^^^^^^^^^ _D_efinition of this menu
"
    ;; arrows
    ("c" ivy-beginning-of-buffer)
    ("t" ivy-next-line)
    ("s" ivy-previous-line)
    ("r" ivy-end-of-buffer)
    ;; actions
    ("o" keyboard-escape-quit :exit t)
    ("C-g" keyboard-escape-quit :exit t)
    ("i" nil)
    ("C-o" nil)
    ("f" ivy-alt-done :exit nil)
    ("C-j" ivy-alt-done :exit nil)
    ("d" ivy-done :exit t)
    ("g" ivy-call)
    ("C-m" ivy-done :exit t)
    ("C" ivy-toggle-calling)
    ("m" ivy-toggle-fuzzy)
    (">" ivy-minibuffer-grow)
    ("<" ivy-minibuffer-shrink)
    ("b" ivy-prev-action)
    ("é" ivy-next-action)
    ("p" ivy-read-action)
    ("T" (setq truncate-lines (not truncate-lines)))
    ("C-c" ivy-toggle-case-fold)
    ("u" ivy-occur :exit t)
    ("D" (ivy-exit-with-action
          (lambda (_) (find-function 'hydra-ivy/body)))
     :exit t))

  (defun ivy-switch-project ()
    (interactive)
    (ivy-read
     "Switch to project: "
     (if (projectile-project-p)
         (cons (abbreviate-file-name (projectile-project-root))
               (projectile-relevant-known-projects))
       projectile-known-projects)
     :action #'projectile-switch-project-by-name))

  (global-set-key (kbd "C-c m") 'ivy-switch-project)

  (ivy-set-actions
   'ivy-switch-project
   '(("d" dired "Open Dired in project's directory")
     ("v" counsel-projectile "Open project root in vc-dir or magit")
     ("c" projectile-compile-project "Compile project")
     ("r" projectile-remove-known-project "Remove project(s)"))))

;; ---------- J --------------------------------------------------

;; ---------- K --------------------------------------------------

;; ---------- L --------------------------------------------------
(use-package lesspy
  :load-path "~/.emacs.d/private/lesspy"
  :diminish ""
  :commands (lesspy-mode)
  :config
  (general-define-key
   :keymaps 'lesspy-mode-map
    "a" 'lesspy-avy-jump
    "p" 'lesspy-eval-function-or-paragraph
    "h" 'lesspy-help
    "l" 'lesspy-eval-line
    "L" 'lesspy-eval-line-and-go
    "e" 'lesspy-eval-sexp
    "E" 'lesspy-avy-eval
    "c" 'lesspy-left
    "t" 'lesspy-down
    "s" 'lesspy-up
    "r" 'lesspy-right
    "d" 'lesspy-different
    "m" 'lesspy-mark
    "x" 'lesspy-execute
    "u" 'lesspy-undo
    "z" 'lesspy-to-shell
    "(" 'lesspy-paren
    "»" 'lesspy-forward-slurp
    "«" 'lesspy-backward-slurp
    "#" 'lesspy-comment
    "'" 'lesspy-roxigen
    "C" 'lesspy-cleanup-pipeline
    "C-d" 'lesspy-kill-forward
    "C-(" 'lesspy-paren-wrap-next
    "DEL" 'lesspy-kill-backward)
  (general-define-key
   :keymaps 'inferior-ess-mode-map
    "C-(" 'lesspy-paren-wrap-next))

(use-package lispy :ensure t
  ;; :disabled t
  :diminish (lispy-mode . " λ")
  :commands lispy-mode
  :init
  (add-hook 'emacs-lisp-mode-hook (lambda () (lispy-mode 1)))
  (add-hook 'lisp-mode-hook (lambda () (lispy-mode 1)))

  :config
  ;; adapté au bépo
  (lispy-define-key lispy-mode-map "s" 'lispy-up)
  (lispy-define-key lispy-mode-map "ß" 'lispy-move-up)
  (lispy-define-key lispy-mode-map "t" 'lispy-down)
  (lispy-define-key lispy-mode-map "þ" 'lispy-move-down)
  (lispy-define-key lispy-mode-map "c" 'lispy-left)
  (lispy-define-key lispy-mode-map "h" 'lispy-clone)
  (lispy-define-key lispy-mode-map "r" 'lispy-right)
  (lispy-define-key lispy-mode-map "®" 'lispy-forward)
  (lispy-define-key lispy-mode-map "©" 'lispy-backward)
  (lispy-define-key lispy-mode-map "C" 'lispy-ace-symbol-replace)
  (lispy-define-key lispy-mode-map "H" 'lispy-convolute)
  (lispy-define-key lispy-mode-map "»" 'lispy-slurp)
  (lispy-define-key lispy-mode-map "«" 'lispy-barf)
  (lispy-define-key lispy-mode-map "l" 'lispy-raise) ; replace "r" `lispy-raise' with "l"
  (lispy-define-key lispy-mode-map "j" 'lispy-teleport)
  (lispy-define-key lispy-mode-map "X" 'special-lispy-x)

  ;; change avy-keys to default bépo home row keys.
  (setq lispy-avy-keys '(?a ?u ?i ?e ?t ?s ?r ?n ?m)))

(use-package lorem-ipsum :ensure t
  :commands
  (lorem-ipsum-insert-list
   lorem-ipsum-insert-sentences
   lorem-ipsum-insert-paragraphs))

(use-package lua-mode :ensure t
  :defer t)

;; ---------- M --------------------------------------------------
(use-package magit
  :quelpa (magit :fetcher github :repo "magit/magit")
  :commands (magit-blame
             magit-commit
             magit-commit-popup
             magit-diff-popup
             magit-diff-unstaged
             magit-fetch-popup
             magit-init
             magit-log-popup
             magit-pull-popup
             magit-push-popup
             magit-revert
             magit-stage-file
             magit-status
             magit-unstage-file
             magit-blame-mode)
  :bind (("s-v" . magit-status))

  :config
  (use-package git-modes
    :quelpa (git-modes :fetcher github :repo "magit/git-modes"))

  (global-git-commit-mode)

  (general-define-key
   :keymaps 'magit-mode-map
    "'" #'eshell-here)

  (use-package magit-popup :ensure t)
  (use-package git-commit :ensure t :defer t)

  (use-package magit-gitflow :ensure t
    :commands
    turn-on-magit-gitflow
    :general
    (:keymaps 'magit-mode-map
     "%" 'magit-gitflow-popup)
    :init
    (add-hook 'magit-mode-hook 'turn-on-magit-gitflow))

  (setq magit-completing-read-function 'ivy-completing-read))

(use-package makefile-mode :defer t
  :init
  ;; (add-hook 'makefile-mode-hook 'makefile-gmake-mode)
  (add-hook 'makefile-bsdmake-mode-hook 'makefile-gmake-mode)
  (add-hook 'makefile-mode-hook (lambda () (aggressive-indent-mode 0)
                                  (setq-local outline-regexp "^## ----------")))
  :config
  (add-to-list 'company-backends 'company-shell))

(use-package markdown-mode :ensure t
  :mode (("\\.md\\'" . markdown-mode)
         ("README\\'"   . markdown-mode))
  :config
  (add-hook 'markdown-mode-hook (lambda () (auto-fill-mode 0)))

  (defhydra hydra-markdown (:hint nil)
    "
Formatting         _s_: bold          _e_: italic     _b_: blockquote   _p_: pre-formatted    _c_: code
Headings           _h_: automatic     _1_: h1         _2_: h2           _3_: h3               _4_: h4
Lists              _m_: insert item
Demote/Promote     _l_: promote       _r_: demote     _U_: move up      _D_: move down
Links, footnotes   _L_: link          _U_: uri        _F_: footnote     _W_: wiki-link      _R_: reference
undo               _u_: undo
"


    ("s" markdown-insert-bold)
    ("e" markdown-insert-italic)
    ("b" markdown-insert-blockquote :color blue)
    ("p" markdown-insert-pre :color blue)
    ("c" markdown-insert-code)

    ("h" markdown-insert-header-dwim)
    ("1" markdown-insert-header-atx-1)
    ("2" markdown-insert-header-atx-2)
    ("3" markdown-insert-header-atx-3)
    ("4" markdown-insert-header-atx-4)

    ("m" markdown-insert-list-item)

    ("l" markdown-promote)
    ("r" markdown-demote)
    ("D" markdown-move-down)
    ("U" markdown-move-up)

    ("L" markdown-insert-link :color blue)
    ("U" markdown-insert-uri :color blue)
    ("F" markdown-insert-footnote :color blue)
    ("W" markdown-insert-wiki-link :color blue)
    ("R" markdown-insert-reference-link-dwim :color blue)

    ("u" undo :color teal)
    )

  (general-define-key
   :keymaps 'markdown-mode-map
   :prefix "C-,"
    "," 'hydra-markdown/body
    "=" 'markdown-promote
    "°" 'markdown-promote-subtree
    "-" 'markdown-demote
    "8" 'markdown-demote-subtree
    "o" 'markdown-follow-thing-at-point
    "j" 'markdown-jump
    "»" 'markdown-indent-region
    "«" 'markdown-exdent-region
    "gc" 'markdown-forward-same-level
    "gr" 'markdown-backward-same-level
    "gs" 'markdown-up-heading)

  (which-key-add-major-mode-key-based-replacements 'markdown-mode
    "C-c C-a" "insert"
    "C-c C-c" "export"
    "C-c TAB" "images"
    "C-c C-s" "text"
    "C-c C-t" "header"
    "C-c C-x" "move"))

(use-package matlab-mode :ensure t
  :mode (("\\.m\\'" . matlab-mode)))

(use-package move-text :ensure t
  :commands
  (move-text-down
   move-text-up))

(use-package multiple-cursors
  :quelpa (multiple-cursors :fetcher github :repo "magnars/multiple-cursors.el")
  :general
  ("M-s-s" 'mc/mark-previous-like-this
   "M-s-t" 'mc/mark-next-like-this
   "M-s-S" 'mc/unmark-next-like-this
   "M-s-T" 'mc/unmark-previous-like-this
   "H-SPC" 'hydra-mc/body)
  :commands
  (hydra-mc/mc/mark-previous-like-this
   hydra-mc/mc/mark-next-like-this)
  :config

  ;; from https://github.com/abo-abo/hydra/wiki/multiple-cursors
  (defhydra hydra-mc (:hint nil)
    "
     ^Up^            ^Down^        ^Other^
----------------------------------------------
[_p_]   Next    [_n_]   Next    [_l_] Edit lines
[_P_]   Skip    [_N_]   Skip    [_a_] Mark all
[_M-p_] Unmark  [_M-n_] Unmark  [_r_] Mark by regexp
^ ^             ^ ^             [_q_] Quit
"
    ("l" mc/edit-lines :exit t)
    ("a" mc/mark-all-like-this :exit t)
    ("n" mc/mark-next-like-this)
    ("N" mc/skip-to-next-like-this)
    ("M-p" mc/unmark-next-like-this)
    ("p" mc/mark-previous-like-this)
    ("P" mc/skip-to-previous-like-this)
    ("M-n" mc/unmark-previous-like-this)
    ("r" mc/mark-all-in-region-regexp :exit t)
    ("q" nil :color blue)
    (" " nil "quit" :color blue)))

(use-package mu4e
  :commands (mu4e)
  :defines (hydra-mu4e/body)
  :bind* (("C-c M" . hydra-mu4e/body))
  :load-path "/usr/local/share/emacs/site-lisp/mu4e"
  :init
  ;; (add-hook 'mu4e-compose-mode-hook (lambda () (openwith-mode -1)))
  (add-hook 'message-mode-hook 'turn-on-orgtbl)
  (add-hook 'message-mode-hook 'turn-on-orgstruct++)
  :config
  (use-package smtpmail)

  ;; use mu4e as emacs default mail program
  (setq mail-user-agent 'mu4e-user-agent)

  (setq mu4e-maildir (expand-file-name "~/Maildir/")
        mu4e-drafts-folder "/drafts"
        mu4e-sent-folder "/sent"
        mu4e-trash-folder "/trash"
        mu4e-get-mail-command "mbsync -a"
        mu4e-html2text-command "w3m -I UTF-8 -O UTF-8 -T text/html"
        mu4e-headers-auto-update t
        mu4e-use-fancy-chars nil
        mu4e-confirm-quit nil
        mu4e-compose-format-flowed nil)

  ;; does not include myself when replying
  (setq mu4e-compose-dont-reply-to-self t)

  (setq mu4e-maildir-shortcuts
        '(("/gmail/inbox" . ?i)
          ("/univ/inbox"  . ?u)
          ("/sent"        . ?s)
          ("/trash"       . ?t)
          ("/drafts"      . ?d)))

  (setq mu4e-bookmarks
        `(("date:today..now AND NOT flag:trashed" "Today" ,?t)
          ("flag:unread AND NOT flag:trashed" "Unread" ,?s)
          ("date:7d..now AND NOT flag:trashed" "Week" ,?r)
          ("maildir:/univ/inbox" "Univ" ,?n)
          ("maildir:/gmail/inbox" "Gmail" ,?m)))

  (setq mu4e-compose-reply-to-address "samuel.barreto8@gmail.com"
        user-mail-address "samuel.barreto8@gmail.com"
        user-full-name "Samuel Barreto")

  ;; send message
  (setq message-send-mail-function 'message-send-mail-with-sendmail)
  (setq sendmail-program "/usr/local/bin/msmtp")
  ;; tell msmtp to choose the smtp server according to the from field
  (setq message-send-mail-extra-arguments '("--read-envelope-from"))
  (setq message-sendmail-f-is-evil 't)

  ;; show images
  (setq mu4e-show-images t
        mu4e-view-show-images t)

  ;; use imagemagick, if available
  (when (fboundp 'imagemagick-register-types)
    (imagemagick-register-types))

  ;; view mail in browser if possible
  (add-to-list
   'mu4e-view-actions
   '("browser" . mu4e-action-view-in-browser) t)

  ;; attach files from dired
  (require 'gnus-dired)
  ;; make the `gnus-dired-mail-buffers' function also work on
  ;; message-mode derived modes, such as mu4e-compose-mode
  (defun gnus-dired-mail-buffers ()
    "Return a list of active message buffers."
    (let (buffers)
      (save-current-buffer
        (dolist (buffer (buffer-list t))
          (set-buffer buffer)
          (when (and (derived-mode-p 'message-mode)
                     (null message-sent-message-via))
            (push (buffer-name buffer) buffers))))
      (nreverse buffers)))

  (setq gnus-dired-mail-mode 'mu4e-user-agent)
  (add-hook 'dired-mode-hook 'turn-on-gnus-dired-mode)

  ;; keybindings
  (bind-keys
   :map mu4e-main-mode-map
    ("n" . next-line)
    ("p" . previous-line)
    :map mu4e-headers-mode-map
    ("s-c" . mu4e-headers-query-prev)
    ("s-r" . mu4e-headers-query-next))

  (defhydra hydra-mu4e
    (:hint nil
     :color blue
     :columns 1)
    "MAIL:"
    ("c" mu4e-compose-new "compose mail")
    ("m" mu4e-headers-search-bookmark "mail")
    ("u" mu4e-update-mail-and-index "update" :color red)
    ("s" mu4e-headers-search "search")))

(use-package multi-line :ensure t
  :bind* (("C-c d" . multi-line))
  :config
  ;; TODO définir une bonne expression pour multi-liner les longues
  ;; lignes dans un script R
  ;;
  ;; (multi-line-defhook ess
  ;;   (make-instance
  ;;    multi-line-strategy
  ;;    :find (make-instance
  ;;           multi-line-forward-sexp-find-strategy
  ;;           :split-regex "[[:space:]\n]+"
  ;;           :done-regex "[[:space:]]*)]}"
  ;;           :split-advance-fn 'multi-line-lisp-advance-fn )
  ;;    :respace multi-line-lisp-respacer))
  )

(use-package multi-term :ensure t
  :commands (multi-term
             multi-term-next
             multi-term-prev
             multi-term-dedicated-open
             multi-term-dedicated-close
             multi-term-dedicated-select
             multi-term-dedicated-toggle)
  :init
  (setq multi-term-program "/usr/local/bin/bash"))

;; ---------- N --------------------------------------------------
(use-package nlinum :ensure t
  :commands (global-nlinum-mode
             nlinum-mode)
  :init
  (defun sam--fix-linum-size ()
    "Fixe la taille de charactère dans linum mode"
    (interactive)
    (set-face-attribute 'linum nil :height 100 :foreground "#93a1a1"))
  (add-hook 'nlinum-mode-hook 'sam--fix-linum-size)
  :config
  (global-nlinum-mode))

(use-package nlinum-relative :ensure t
  :disabled t
  :commands (nlinum-relative-mode -1)
  :init
  (add-hook 'prog-mode-hook 'nlinum-relative-mode))

;; ---------- O --------------------------------------------------
(use-package osx-clipboard :ensure t
  :if (not (window-system))
  :init
  (osx-clipboard-mode +1))

(use-package openwith :ensure t
  :disabled t
  :config
  (openwith-mode 1)
  (setq openwith-associations
        '(("\\.pdf\\'" "open -a Preview" (file))
          ("\\.xlsx\\'" "open -a Microsoft\\ Excel" (file))
          ("\\.xls\\'" "open -a Microsoft\\ Excel" (file))
          ("\\.html\\'" "open -a Google\\ Chrome" (file)))))

;; TODO work on outline hydra. useful for tex
(use-package outline
  :bind (("H-<tab>" . hydra-outline/body))
  :commands (outline-hide-body
             outline-show-all
             outline-minor-mode
             hydra-outline/body)
  :general ("M-s-c" 'outline-previous-heading
            "M-s-r" 'outline-next-heading)
  :diminish ((outline-minor-mode . "")
             (outline-mode . ""))
  :config
  (outline-minor-mode)

  (defun outline-narrow-to-subtree ()
    (interactive)
    (outline-mark-subtree)
    (narrow-to-region (region-beginning) (region-end)))

  (defun outline-indent-subtree ()
    (interactive)
    (save-excursion
      (outline-mark-subtree)
      (indent-region (region-beginning) (region-end))
      (message nil)))

  (bind-key "C-c @ n" 'outline-narrow-to-subtree)
  (bind-key "C-c @ i" 'outline-indent-subtree)

  (add-hook 'outline-minor-mode-hook
            (lambda ()
              (add-to-list 'hjkl-bindings
                           '(:keymap outline-minor-mode-map
                             :bind (:up    ((outline-regexp #'outline-previous-heading))
                                    :down  ((outline-regexp #'outline-next-heading))
                                    :left  ((outline-regexp #'outline-hide-leaves))
                                    :right ((outline-regexp #'outline-show-subtree))))
                           t)
              (hjkl-update-keys)))


  (defhydra hydra-outline
    (:hint nil :body-pre (outline-minor-mode 1))
    "
Outline

^CURRENT^    ^ALL^      ^LEAVES^      ^MANIPULATE^
_c_: hide    _C_: hide  _C-c_: hide    _M-r_: demote
_t_: next    ^ ^        _C-r_: show    _M-c_: promote
_s_: prev    ^ ^        ^   ^          _M-t_: move down
_r_: show    _R_: show  ^   ^          _M-s_: move up
"
    ("C" outline-hide-body)
    ("t" outline-next-visible-heading)
    ("s" outline-previous-visible-heading)
    ("R" outline-show-all)
    ("c" outline-hide-subtree)
    ("r" outline-show-subtree)

    ("C-c" outline-hide-leaves)
    ("C-r" outline-show-subtree)

    ("M-r" outline-demote)
    ("M-c" outline-promote)
    ("M-t" outline-move-subtree-down)
    ("M-s" outline-move-subtree-up)

    ("i" outline-insert-heading "insert heading" :color blue)
    ("q" nil "quit" :color blue)))

;; ---------- P --------------------------------------------------
(use-package paradox :ensure t
  :commands (paradox-list-packages
             package-list-packages))

(use-package pbcopy :ensure t
  :if (not (display-graphic-p))
  :init
  (turn-on-pbcopy))

(use-package pdf-tools :ensure t
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (setq pdf-tools-enabled-modes
        '(pdf-isearch-minor-mode
          pdf-links-minor-mode
          pdf-misc-minor-mode
          pdf-outline-minor-mode
          pdf-misc-size-indication-minor-mode
          pdf-misc-menu-bar-minor-mode
          pdf-sync-minor-mode
          pdf-misc-context-menu-minor-mode
          pdf-cache-prefetch-minor-mode
          pdf-view-auto-slice-minor-mode))
  (setq pdf-info-epdfinfo-program "/usr/local/bin/epdfinfo")
  (require 'pdf-occur)
  (require 'pdf-links)
  (require 'pdf-outline)
  (require 'pdf-sync)
  (pdf-tools-install)

  (setq pdf-view-continuous t)

  (defun pdf-view-open-in-external-app ()
    (interactive)
    (shell-command (format "open -a Preview %s" (buffer-file-name))))

  (defun pdf-view-finder ()
    (interactive)
    (shell-command "open -a Finder ./"))

  (bind-keys :map pdf-view-mode-map
    ("r" . pdf-view-next-page)
    ("c" . pdf-view-previous-page)
    ("O" . pdf-view-open-in-external-app)
    ("s" . pdf-view-previous-line-or-previous-page)
    ("t" . pdf-view-next-line-or-next-page)))

(use-package cperl
  :mode ("\\.pl\\'". cperl-mode)
  :defines (cperl-eldoc-documentation-function)
  :init
  (defalias 'perl-mode 'cperl-mode)

  (defun cperl-eldoc-documentation-function ()
    "Return meaningful doc string for `eldoc-mode'."
    (car
     (let ((cperl-message-on-help-error nil))
       (cperl-get-help))))

  (add-hook 'cperl-mode-hook
            (lambda ()
              (set (make-local-variable 'eldoc-documentation-function)
                   'cperl-eldoc-documentation-function)
              (my-pde-load)))

  :config
  (use-package plsense :ensure t
    :config
    (plsense-config-default))

  ;; (use-package perl-completion :ensure t
  ;;   :init
  ;;   (add-hook 'cperl-mode-hook
  ;;             (lambda ()
  ;;               (require 'perl-completion)
  ;;               (perl-completion-mode t))))

  (use-package pde-load
    :load-path "~/src/github.com/wenbinye/emacs-pde/lisp"
    :defines (my-pde-load)
    :commands (my-pde-load)
    :init
    (setq pde-extra-setting t)
    (setq inf-perl-shell-program (expand-file-name "~/anaconda/bin/re.pl"))
    :config
    (defun my-pde-load ()
      (interactive)
      (load "pde-load"))

    (bind-keys :map cperl-mode-map
      ("C-<return>" . inf-perl-send-line)))

  (setq cperl-invalid-face (quote off))
  (setq cperl-invalid-face nil)

  (sp-local-pair 'perl-mode "{" nil
                 :post-handlers '((sam--create-newline-and-enter-sexp "RET")))
  (sp-local-pair 'perl-mode "\"\"" nil
                 :post-handlers '((sam--create-newline-and-enter-sexp "RET"))))

(use-package persp-mode
  :defer t
  :quelpa (persp-mode :fetcher github :repo "Bad-ptr/persp-mode.el")
  :diminish (persp-mode . "")
  :commands (persp-mode
             persp-next
             persp-prev
             pers-switch)
  :config

  (setq wg-morph-on nil)                ; switch off animation ?
  (setq persp-autokill-buffer-on-remove 'kill-weak)
  (setq persp-nil-name "nil")

  (defhydra hydra-persp (:hint nil :color blue)
    "
^Nav^        ^Buffer^      ^Window^     ^Manage^      ^Save/load^
^---^        ^------^      ^------^     ^------^      ^---------^
_n_: next    _a_: add      ^ ^          _r_: rename   _w_: save
_p_: prev    _b_: → to     ^ ^          _c_: copy     _W_: save subset
_s_: → to    _i_: import   _S_: → to    _C_: kill     _l_: load
^ ^          ^ ^           ^ ^          ^ ^           _L_: load subset
"
    ("n" persp-next :color red)
    ("p" persp-prev :color red)
    ("s" persp-switch)
    ("S" persp-window-switch)
    ("r" persp-rename)
    ("c" persp-copy)
    ("C" persp-kill)
    ("a" persp-add-buffer)
    ("b" persp-switch-to-buffer)
    ("i" persp-import-buffers-from)
    ("I" persp-import-win-conf)
    ("o" persp-mode)
    ("w" persp-save-state-to-file)
    ("W" persp-save-to-file-by-names)
    ("l" persp-load-state-from-file)
    ("L" persp-load-from-file-by-names)
    ("q" nil "quit"))

  (global-set-key (kbd "H-p") 'persp-prev)
  (global-set-key (kbd "H-n") 'persp-next))

(use-package perspeen
  :defines (hydra-perspeen/body)
  :bind* ("s-<return>" . hydra-perspeen/body)
  :ensure t
  :init
  (setq perspeen-use-tab nil)
  :config
  (perspeen-mode)
  (defhydra hydra-perspeen
    (:hint nil
     :color blue)
    "
_t_ _n_ext   _k_: delete   _c_reate
_s_ _p_rev   _r_: rename
"
    ("c" perspeen-create-ws)
    ("n" perspeen-next-ws :color red)
    ("t" perspeen-next-ws :color red)
    ("s" perspeen-previous-ws :color red)
    ("p" perspeen-previous-ws :color red)
    ("k" perspeen-delete-ws :color red)
    ("r" perspeen-rename-ws)
    ("q" (message "Abort"))))

(use-package shell-pop :ensure t
  :bind* (("s-'" . shell-pop))
  :config
  (setq shell-pop-default-directory nil
        shell-pop-shell-type '("shell" "*shell-pop*" (lambda nil (shell shell-pop-term-shell)))
        shell-pop-term-shell "/usr/local/bin/bash"
        shell-pop-window-height 20
        shell-pop-full-span t
        shell-pop-window-position "bottom"))

;; TODO what is that ?

(use-package pretty-mode :ensure t
  :disabled t
  :commands turn-on-pretty-mode
  :init
  (add-hook 'ess-mode-hook 'turn-on-pretty-mode))

(use-package prog-mode
  :config
  (global-prettify-symbols-mode))

(use-package projectile :ensure t
  :defines hydra-projectile/body
  :diminish (projectile-mode . " ⓟ")
  :bind* (("C-c p p" . projectile-switch-project))
  :commands (projectile-ag
             projectile-switch-to-buffer
             projectile-invalidate-cache
             projectile-find-dir
             projectile-find-file
             projectile-find-file-dwim
             projectile-find-file-in-directory
             projectile-ibuffer
             projectile-kill-buffers
             projectile-multi-occur
             projectile-switch-project
             projectile-recentf
             projectile-remove-known-project
             projectile-cleanup-known-projects
             projectile-cache-current-file
             projectile-project-root
             projectile-mode
             projectile-project-p)
  :bind (("s-p" . hydra-projectile/body)
         ("s-b" . projectile-switch-to-buffer))
  :config
  (projectile-global-mode 1)

  (use-package org-projectile :ensure t
    :config
    (org-projectile:per-repo)
    (setq org-projectile:per-repo-filename "project_todo.org")
    (setq org-agenda-files (append org-agenda-files (org-projectile:todo-files)))
    (add-to-list 'org-capture-templates (org-projectile:project-todo-entry "p")))

  (setq projectile-switch-project-action 'projectile-dired)
  (setq projectile-completion-system 'ivy)
  (add-to-list 'projectile-globally-ignored-files ".DS_Store")
  (defun hydra-projectile-if-projectile-p ()
    (interactive)
    (if (projectile-project-p)
        (hydra-projectile/body)
      (counsel-projectile)))

  (defhydra hydra-projectile
    (:color teal :hint nil
     :pre (projectile-mode))
    "
     PROJECTILE: %(projectile-project-root)

    ^FIND FILE^        ^SEARCH/TAGS^        ^BUFFERS^       ^CACHE^                    ^PROJECT^
    _f_: file          _a_: ag              _i_: Ibuffer    _c_: cache clear           _p_: switch proj
    _F_: file dwim     _g_: update gtags    _b_: switch to  _x_: remove known project
  _C-f_: file pwd      _o_: multi-occur   _s-k_: Kill all   _X_: cleanup non-existing
    _r_: recent file   ^ ^                  ^ ^             _z_: cache current
    _d_: dir

   ^SHELL^
   _e_: eshell
"
    ("e"   projectile-run-eshell)
    ("a"   projectile-ag)
    ("b"   projectile-switch-to-buffer)
    ("c"   projectile-invalidate-cache)
    ("d"   projectile-find-dir)
    ("f"   projectile-find-file)
    ("F"   projectile-find-file-dwim)
    ("C-f" projectile-find-file-in-directory)
    ("g"   ggtags-update-tags)
    ("s-g" ggtags-update-tags)
    ("i"   projectile-ibuffer)
    ("K"   projectile-kill-buffers)
    ("s-k" projectile-kill-buffers)
    ("m"   projectile-multi-occur)
    ("o"   projectile-multi-occur)
    ("p"   projectile-switch-project)
    ("r"   projectile-recentf)
    ("x"   projectile-remove-known-project)
    ("X"   projectile-cleanup-known-projects)
    ("z"   projectile-cache-current-file)
    ("q"   nil "cancel" :color blue)))

(use-package python
  :ensure python-mode
  :mode
  (("\\.py\\'" . python-mode)
   ("\\.pyx\\'" . python-mode)
   ("\\.wsgi$" . python-mode))
  :interpreter
  (("ipython" . python-mode)
   ("python"  . python-mode))
  :init
  (add-hook 'python-mode-hook (lambda () (aggressive-indent-mode -1)))

  :config
  (load-file "~/dotfile/emacs/python-config.el"))

;; ---------- Q --------------------------------------------------
;; ---------- R --------------------------------------------------

(use-package rainbow-delimiters  :ensure t
  :commands rainbow-delimiters-mode
  :init
  (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(use-package ranger :ensure t
  :commands
  (ranger
   deer)
  :general
  (:keymaps 'ranger-mode-map
   "t" 'ranger-next-file		; j
   "s" 'ranger-prev-file		; k
   "r" 'ranger-find-file		; l
   "c" 'ranger-up-directory		; c
   "j" 'ranger-toggle-mark		; t
   )

  :config
  (setq ranger-cleanup-eagerly t))

(use-package recentf
  :commands (recentf-mode
             counsel-recentf)
  :config
  (setq recentf-max-saved-items 50))

(use-package restart-emacs :ensure t
  :commands restart-emacs)

(use-package rg :ensure t
  :commands (rg))

(use-package rtf-mode
  :quelpa (rtf-mode :fetcher wiki))
;; ---------- S --------------------------------------------------

(use-package scss-mode :ensure t
  :mode ("\\.scss\\'" . scss-mode))

(use-package selected
  :ensure t
  :commands selected-minor-mode
  :bind (:map selected-keymap
         ("q" . selected-off)
         ("u" . upcase-region)
         ("d" . downcase-region)
         ("w" . count-words-region)
         ("m" . apply-macro-to-region-lines)))

(use-package shift-number :ensure t
  :bind (("s--" . shift-number-down)
         ("s-+" . shift-number-up)))

(use-package shell
  :config
  (setq explicit-shell-file-name "/usr/local/bin/bash"))

(use-package solarized-color-themes
  :disabled t
  :quelpa (solarized-color-themes :fetcher github :repo "sellout/emacs-color-theme-solarized")
  :init
  (add-to-list 'custom-theme-load-path "~/.emacs.d/elpa/color-theme-solarized-20160626.743/")
  (set-frame-parameter (selected-frame) 'background-mode 'dark)
  (load-theme 'solarized t)

  (setq-default cursor-type 'box)
  (add-to-list 'default-frame-alist '(cursor-color . "#d33682"))
  (set-cursor-color "#d33682")

  (defun solarized--dark-or-light (bgd)
    (set-frame-parameter (selected-frame) 'background-mode bgd)
    (enable-theme 'solarized)
    (set-cursor-color "#d33682")))

(use-package sh-script :defer t
  :mode
  ( ("\\.zsh\\'" . sh-mode)
    ("zlogin\\'" . sh-mode)
    ("zlogout\\'" . sh-mode  )
    ("zpreztorc\\'" . sh-mode )
    ("zprofile\\'" . sh-mode )
    ("zshenv\\'" . sh-mode )
    ("zshrc\\'" . sh-mode))
  :config

  (use-package company-shell
    :quelpa (company-shell :fetcher github :repo "Alexander-Miller/company-shell")
    :config
    (add-to-list 'company-backends 'company-shell)))

(use-package slime
  :ensure t
  :commands (slime)
  :mode (("\\.cl\\'" . common-lisp-mode)
         ("\\.lisp\\'" . common-lisp-mode))
  :config
  (load (expand-file-name "~/quicklisp/slime-helper.el"))
  ;; Replace "sbcl" with the path to your implementation
  (setq inferior-lisp-program "sbcl")
  (setq slime-contribs '(slime-fancy)))

(use-package smartparens
  :ensure t
  :diminish (smartparens-mode . "")
  :defines hydra-sp/body
  :commands (smartparens-global-mode
             hydra-sp/body)
  :bind* (("C-M-f" . sp-forward-sexp)
          ("C-M-b" . sp-backward-sexp)
          ("C-M-d" . sp-down-sexp)
          ("C-M-a" . sp-backward-down-sexp)
          ("C-S-d" . sp-beginning-of-sexp)
          ("C-S-a" . sp-end-of-sexp)
          ("C-M-e" . sp-up-sexp)
          ("C-M-u" . sp-backward-up-sexp)
          ("C-M-t" . sp-transpose-sexp)
          ("C-S-r" . sp-forward-slurp-sexp)
          ("C-S-c" . sp-forward-barf-sexp)
          ("C-S-s" . sp-backward-slurp-sexp)
          ("C-S-t" . sp-backward-barf-sexp)
          ("C-{"   . sp-backward-barf-sexp)
          ("C-}"   . sp-slurp-hybrid-sexp)
          ("C-S-b" . sp-backward-symbol)
          ("C-S-f" . sp-forward-symbol)
          ("C-ß"   . sp-splice-sexp))
  :init
  (add-hook 'after-init-hook (lambda () (smartparens-global-mode)))
  (add-hook 'prog-mode-hook (lambda () (smartparens-strict-mode)))

  :config
  ;; Only use smartparens in web-mode
  (sp-local-pair 'markdown-mode "_" "_")
  (sp-local-pair 'markdown-mode "**" "**")
  (sp-local-pair 'markdown-mode "`" "`")
  (sp-local-pair 'web-mode "<% " " %>")
  (sp-local-pair 'web-mode "{ " " }")
  (sp-local-pair 'web-mode "<%= "  " %>")
  (sp-local-pair 'web-mode "<%# "  " %>")
  (sp-local-pair 'web-mode "<%$ "  " %>")
  (sp-local-pair 'web-mode "<%@ "  " %>")
  (sp-local-pair 'web-mode "<%: "  " %>")
  (sp-local-pair 'web-mode "{{ "  " }}")
  (sp-local-pair 'web-mode "{% "  " %}")
  (sp-local-pair 'web-mode "{%- "  " %}")
  (sp-local-pair 'web-mode "{# "  " #}")
  (sp-local-pair 'org-mode "$" "$")
  (sp-pair "'" nil :actions :rem)

  ;; from hydra wiki
  (defhydra hydra-sp (:hint nil)
    "
       ^Navigate^   ^^              ^Slurp - Barf^    ^Splice^          ^Commands^
       ^--------^   ^^              ^------------^    ^------^          ^--------^
    _b_: bwd      _f_: fwd       _c_: slurp bwd      _ll_: splice    _x_: del char
    _T_: bwd ↓    _S_: bwd ↑     _r_: slurp fwd      _lf_: fwd       _é_: del word
    _t_: ↓        _s_: ↑       _C-c_: barf bwd       _lb_: bwd       _(_: del sexp
    _p_: prev     _n_: next    _C-r_: barf fwd       _la_: around    _w_: unwrap
  _M-p_: end    _M-n_: begin   ^   ^                 ^  ^
       ^------^     ^^             ^------------^
       ^Symbol^     ^^             ^join - split^
       ^------^     ^^             ^------------^
  _C-b_: bwd    _C-b_: fwd       _j_: join
      ^^            ^^           _v_: split
"
    ("b" sp-backward-sexp )
    ("f" sp-forward-sexp )
    ("T" sp-backward-down-sexp )
    ("S" sp-backward-up-sexp )
    ("t" sp-down-sexp )                 ; root - towards the root
    ("s" sp-up-sexp )
    ("n" sp-next-sexp )
    ("p" sp-previous-sexp )
    ("M-n" sp-beginning-of-sexp)
    ("M-p" sp-end-of-sexp )
    ("x" sp-delete-char )
    ("é" sp-kill-word )
    ("(" sp-kill-sexp )
    ("w" sp-unwrap-sexp ) ;; Strip!
    ("r" sp-forward-slurp-sexp )
    ("C-r" sp-forward-barf-sexp )
    ("c" sp-backward-slurp-sexp )
    ("C-c" sp-backward-barf-sexp )
    ("ll" sp-splice-sexp )
    ("lf" sp-splice-sexp-killing-forward )
    ("lb" sp-splice-sexp-killing-backward )
    ("la" sp-splice-sexp-killing-around )
    ("C-f" sp-forward-symbol )
    ("C-b" sp-backward-symbol )
    ("j" sp-join-sexp ) ;;Good
    ("v" sp-split-sexp )
    ("u" undo "undo")
    ("q" nil "quit" :color blue))

  (sp-local-pair 'c-mode "{" nil
                 :post-handlers '((sam--create-newline-and-enter-sexp "RET")))

  (defun sam--create-newline-and-enter-sexp (&rest _ignored)
    "Open a new brace or bracket expression, with relevant newlines and indent. "
    ;; from https://github.com/Fuco1/smartparens/issues/80
    (newline)
    (indent-according-to-mode)
    (forward-line -1)
    (indent-according-to-mode)))

(use-package smex
  :quelpa (smex :fetcher github :repo "abo-abo/smex"))

(use-package smooth-scrolling :ensure t
  :config
  (smooth-scrolling-mode)
  (setq smooth-scroll-margin 5))

(use-package spotlight :ensure t
  :bind (("C-c C-s" . spotlight)
         ("C-c C-S-s" . spotlight-fast)))

(use-package string-inflection :ensure t
  :bind ("C-x M-s" . hydra-string-inflection/body)
  :config


  (defhydra hydra-string-inflection
    (:color pink
     :columns 3
     :pre (iedit-mode))
    "STRING INFLECTION"
    ("t" string-inflection-toggle  "toggle")
    ("l" string-inflection-lower-camelcase "lower-camelcase")
    ("L" string-inflection-camelcase "camelcase")
    ("i" string-inflection-lisp "lisp")
    ("c" string-inflection-cycle "cycle")
    ("u" string-inflection-upcase "upcase")
    ("a" string-inflection-all-cycle "all-cycle")
    ("k" string-inflection-kebab-case "kebab-case")
    ("u" string-inflection-underscore "underscore")
    ("*" iedit-mode "iedit" :exit nil)
    ("q" nil "quit" :color blue)))

(use-package subword :defer t
  :init
  (add-hook 'prog-mode-hook (lambda () (subword-mode 1)))
  :diminish "")

(use-package swiper :ensure t
  :bind* (("M-s" . swiper)
          ("M-S" . swiper-all)
          :map swiper-map
          ("C-s" . ivy-previous-history-element)
          ("C-t" . ivy-yank-word)))
;; ---------- T --------------------------------------------------

(use-package term
  :config
  (defun terminal ()
    "switch to terminal, launch if non-existent."
    (interactive)
    (let ((buf "*eshell*"))
      (if (get-buffer buf)
          (switch-to-buffer buf)
        (eshell-here )))
    (get-buffer-process "*ansi-term*"))
  (defalias 'tt 'terminal)

  (defun dired-open-term ()
    (interactive)
    (let ((current-dir (dired-current-directory)))
      (term-send-string
       (terminal)
       (if (file-remote-p current-dir)
           (let ((v (tramp-dissect-file-name current-dir t)))
             (format "ssh %s@%s\n" (aref v 1) (aref v 2)))
         (format "cd '%s'\n" current-dir))))))

(use-package terminal-here :ensure t
  :bind (("H-'" . terminal-here-launch)))

(use-package tetris
  :commands (tetris))

(use-package tex
  :ensure auctex
  :commands init-auctex
  :defines init-auctex
  :mode (("\\.tex\\'" . LaTeX-mode))
  :init
  (add-hook 'LaTeX-mode-hook #'init-auctex)
  (add-hook 'LaTeX-mode-hook 'latex-auto-fill-mode)
  (add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
  (add-hook 'LaTeX-mode-hook 'TeX-source-correlate-mode)
  (add-hook 'LaTeX-mode-hook 'TeX-PDF-mode)
  :config
  (defun init-auctex ()
    "Toggle loading of auctex. Use it when there is needs for
auctex in the editing session. Otherwise emacs falls back to the
integrated Tex-mode. "
    (interactive)
    (require 'latex)
    (require 'tex)
    (load-file "~/dotfile/emacs/latex-config.el")
    (message "Auctex loaded")))

(use-package textpy
  :disabled t
  :load-path "~/.emacs.d/private/textpy"
  :diminish "☉"
  :init
  (add-hook 'text-mode-hook (lambda () (textpy-minor-mode 1)))
  :commands
  (textpy-minor-mode)
  :config
  (general-define-key
   :keymaps 'text-mode-map
    "A" 'textpy-avy-sentence
    "a" 'textpy-avy-jump
    "b" 'textpy-backward-sentence
    "c" 'textpy-correct
    "d" 'textpy-delete-buffer
    "f" 'textpy-forward-sentence
    "q" 'textpy-fill-paragraph
    "s" 'textpy-save
    "v" 'textpy-git
    "/" 'textpy-search))

(use-package tile :ensure t
  :defines (hydra-tile/body)
  :bind* (("C-c t" . hydra-tile/body)
          ("s-t" . tile))
  :config
  (defhydra hydra-tile (:hint nil :color red :columns 4
                        :body-pre (winner-mode 1))
    "tile "
    ("a" (tile :strategy tile-tall-3) "tall 3")
    ("u" (tile :strategy (tile-split-n-tall 4)) "tall 4")
    ("i" (tile :strategy (tile-split-n-wide 2)) "wide 2")
    ("e" (tile :strategy (tile-split-n-wide 3)) "wide 3")
    ("c" (tile :strategy tile-master-left-3) "left 3")
    ("t" (tile :strategy tile-master-bottom-3) "bottom 3")
    ("s" (tile :strategy tile-master-top-3) "top 3")
    ("r" (tile :strategy tile-master-right-3) "right 3")

    ("m" tile-select "chose")
    ("w" (tile :strategy tile-one) "one")
    ("n" tile "tile")
    ("C-u" winner-undo "undo")
    ("M-u" winner-redo "redo")
    ("é" hydra-window/body "windows" :color blue)

    ("q" nil :color blue "quit"))

  (setq tile-cycler
        (tile-strategies :strategies
          (list tile-tall-3
                tile-master-left-3
                tile-master-top-3
                tile-one))))

(use-package tiny :ensure t
  :bind* (("C-;" . tiny-expand)))

(use-package treemacs
  :quelpa (treemacs :fetcher github :repo "Alexander-Miller/treemacs")
  :commands (treemacs-toggle))

;; ---------- U --------------------------------------------------

(use-package undo-tree :ensure t
  :diminish undo-tree-mode
  :bind* (("C-x u" . undo-tree-visualize)
          ("C-z" . undo-tree-undo)
          ("C-S-z" . undo-tree-redo))
  :config
  (general-define-key
   :keymaps 'undo-tree-visualizer-mode-map
    "RET" 'undo-tree-visualizer-quit
    "t" 'undo-tree-visualize-redo
    "s" 'undo-tree-visualize-undo
    "c" 'undo-tree-visualize-switch-branch-left
    "r" 'undo-tree-visualize-switch-branch-right))
;; ---------- V --------------------------------------------------

(use-package visual-regexp-steroids :ensure t
  :bind* (("s-%" . vr/replace)
          ("M-s-%" . vr/query-replace))
  :config
  (setq vr/auto-show-help nil))

(use-package visual-fill-column :ensure t
  :config
  (global-visual-fill-column-mode +1)
  (toggle-word-wrap +1))
;; ---------- W --------------------------------------------------

(use-package web-mode :ensure t
  :mode
  (("\\.phtml\\'"      . web-mode)
   ("\\.tpl\\.php\\'"  . web-mode)
   ("\\.twig\\'"       . web-mode)
   ("\\.html\\'"       . web-mode)
   ("\\.htm\\'"        . web-mode)
   ("\\.[gj]sp\\'"     . web-mode)
   ("\\.as[cp]x?\\'"   . web-mode)
   ("\\.eex\\'"        . web-mode)
   ("\\.erb\\'"        . web-mode)
   ("\\.mustache\\'"   . web-mode)
   ("\\.handlebars\\'" . web-mode)
   ("\\.hbs\\'"        . web-mode)
   ("\\.eco\\'"        . web-mode)
   ("\\.ejs\\'"        . web-mode)
   ("\\.djhtml\\'"     . web-mode))
  :config
  (use-package company-web :ensure t
    :config
    (add-to-list 'company-backends 'company-web-html))
  (add-hook 'web-mode-hook (lambda ()
                             (setq-local tab-width 2)
                             (setq-local outline-regexp "<!--*"))))

(use-package wgrep :ensure t :defer t)

(use-package which-key :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode)
  (which-key-setup-side-window-bottom)
  ;; simple then alphabetic order.
  (setq which-key-sort-order 'which-key-prefix-then-key-order)
  (setq which-key-popup-type 'side-window
        which-key-side-window-max-height 0.5
        which-key-side-window-max-width 0.33
        which-key-idle-delay 0.5
        which-key-min-display-lines 7))

(use-package window-numbering :ensure t
  :commands
  (window-numbering-mode
   select-window-0
   select-window-1
   select-window-2
   select-window-3
   select-window-4
   select-window-5
   select-window-6
   select-window-7
   select-window-8
   select-window-9)
  :config
  (defun window-numbering-install-mode-line (&optional position)
    "Do nothing, the display is handled by the powerline.")
  (window-numbering-install-mode-line))

(use-package wrap-region :ensure t
  :diminish ""
  :config
  (wrap-region-mode 1)
  (wrap-region-add-wrappers
   '(("$" "$")
     (" " " ")
     ("{-" "-}" "#")
     ("/" "/" nil (ruby-mode org-mode))
     ("=" "=" nil (org-mode))
     ("/* " " */" "#" (java-mode javascript-mode css-mode))
     ("`" "`" nil (markdown-mode ruby-mode))
     ("*" "*" nil (markdown-mode org-mode))
     ("_" "_" nil (markdown-mode)))))

(use-package writegood-mode
  :load-path "~/.emacs.d/private/writegood-mode"
  :bind (("C-c w" . writegood-mode))
  :commands (writegood-reading-ease
             writegood-grade-level))
;; ---------- X --------------------------------------------------

(use-package xterm-color
  :quelpa (xterm-color :fetcher github :repo "atomontage/xterm-color")
  :config
  ;; comint install
  (progn
    (add-hook 'comint-preoutput-filter-functions 'xterm-color-filter)
    (setq comint-output-filter-functions
          (remove 'ansi-color-process-output comint-output-filter-functions))))
;; ---------- Y --------------------------------------------------

(use-package yaml-mode :ensure t :defer t)

(use-package yasnippet
  :diminish yas-minor-mode
  :commands (yas-global-mode)
  :defer 10
  :init
  (with-eval-after-load 'yasnippet
    (progn
      (setq yas-snippet-dirs
            (append yas-snippet-dirs '("~/dotfile/emacs/snippets")))))
  :config
  (yas-global-mode)
  (setq yas-indent-line 'none))

;; ---------- Z --------------------------------------------------
(use-package zenburn-theme :ensure t
  :disabled t
  ;; :commands (sam-load-zenburn)
  ;; :defines (sam-load-zenburn)
  :config
  (defun sam-load-zenburn ()
    (interactive)
    (load-theme 'zenburn t)))

(use-package zerodark-theme :ensure t
  :disabled t
  :init
  (setq-default cursor-type 'hbar)
  (add-to-list 'default-frame-alist '(cursor-color . "#d33682"))
  :config
  (zerodark-setup-modeline-format)
  (load-theme 'zerodark t)
  (set-cursor-color "#d33682"))



(use-package zoom-frm :ensure t
  :commands
  (zoom-frm-in
   zoom-frm-out
   zoom-frm-unzoom
   zoom-in
   zoom-out)
  :config
  (setq zoom-frame/buffer 'buffer))

;;; -------------------------------------------------------------------

;;; personal functions
(load-file "~/dotfile/emacs/functions.el")
;;; org
(load-file "~/dotfile/emacs/org.el")
;; ---------- keybindings -------------------------------------------------
(load-file "~/dotfile/emacs/keybindings.el")

;;; custom
(setq custom-file "~/.emacs.d/emacs-custom.el")
(load custom-file)
(put 'erase-buffer 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; TODO check out https://www.youtube.com/watch?v=m_Oj_6Bjryw
;; TODO check out https://github.com/Kungsgeten/selected.el
;; TODO check out https://vxlabs.com/2017/02/07/mu4e-0-9-18-e-mailing-with-emacs-now-even-better/
;; TODO check out https://github.com/atgreen/paperless
;; TODO check out https://github.com/masasam/emacs-easy-hugo
