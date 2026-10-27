;;; init.el -*- lexical-binding: t; -*-

(tool-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode)
(global-visual-line-mode)
(global-so-long-mode)
(delete-selection-mode)
(save-place-mode)
(global-auto-revert-mode)
(which-key-mode)
(editorconfig-mode)
(recentf-mode)
(winner-mode)
(put 'downcase-region 'disabled nil)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-hook 'prog-mode-hook 'subword-mode)
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

(setq locale-coding-system 'utf-8)
(set-charset-priority 'unicode)
(set-terminal-coding-system 'utf-8-unix)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(global-set-key (kbd "<f9>") 'compile)
(global-set-key (kbd "C-j") 'join-line)
(global-set-key (kbd "M-j") (lambda () (interactive) (join-line -1)))

(defun mrjtjmn/delete-current-file-and-buffer ()
  "Delete the file associated with the current buffer and kill the buffer."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if filename
        (when (yes-or-no-p (format "Really delete '%s'? " filename))
          (delete-file filename)
          (message "File deleted and buffer killed.")
          (kill-buffer))
      (error "No file is associated with this buffer"))))

(global-set-key (kbd "C-c D") 'mrjtjmn/delete-current-file-and-buffer)

(defun mrjtjmn/rename-current-file-and-buffer (new-name)
  "Rename the file visited by the current buffer and update the buffer."
  (interactive
   (progn
     (unless (buffer-file-name)
       (error "Current buffer is not visiting a file"))
     (list (read-file-name
            (format "Rename %s to: "
                    (file-name-nondirectory (buffer-file-name)))))))
  (when (string-empty-p new-name)
    (error "Rename canceled"))
  (setq new-name (if (file-directory-p new-name)
                     (expand-file-name (file-name-nondirectory (buffer-file-name)) new-name)
                   (expand-file-name new-name)))
  (when (file-exists-p (buffer-file-name))
    (rename-file (buffer-file-name) new-name 1))
  (let ((was-modified (buffer-modified-p)))
    (set-visited-file-name new-name)
    (if was-modified
        (save-buffer)
      (set-buffer-modified-p nil)))
  (setq default-directory (file-name-directory new-name))
  (message "Renamed to %s." new-name))

(global-set-key (kbd "C-c R") 'mrjtjmn/rename-current-file-and-buffer)

(defun mrjtjmn/sort-words (reverse beg end)
  "Sort words in region alphabetically, in REVERSE if negative.
  Prefixed with negative \\[universal-argument], sorts in reverse.

  The variable `sort-fold-case' determines whether alphabetic case
  affects the sort order.

  See `sort-regexp-fields'."
  (interactive "*P\nr")
  (sort-regexp-fields reverse "\\w+" "\\&" beg end))

(defun mrjtjmn/toggle-delete-other-windows ()
  "Delete other windows in frame if any, or restore previous window config."
  (interactive)
  (if (and winner-mode
           (equal (selected-window) (next-window)))
      (winner-undo)
    (delete-other-windows)))

(global-set-key (kbd "C-x 1") 'mrjtjmn/toggle-delete-other-windows)

(defun mrjtjmn/close-window-or-kill-buffer (&optional arg)
  (interactive "P")
  (if arg
      (dolist (buf (buffer-list))
        (unless (or (string= (buffer-name buf) "*scratch*")
                    (string= (buffer-name buf) "*Messages*"))
          (kill-buffer buf)))
    (let ((buf (current-buffer)))
      (if (> (length (get-buffer-window-list buf)) 1)
          (delete-window)
        (if (one-window-p)
            (kill-current-buffer)
          (kill-buffer-and-window))))))

(global-set-key (kbd "C-x k") 'mrjtjmn/close-window-or-kill-buffer)

(defun mrjtjmn/setup-font-height (height)
  (interactive "nFont height: ")
  (dolist (face '(default fixed-pitch fixed-pitch-serif))
    (set-face-attribute face nil :family "Comic Code" :height height :weight 'bold)))

(add-hook 'after-init-hook (lambda () (mrjtjmn/setup-font-height 130)))

(set-fontset-font t 'unicode (font-spec :family "Symbola"))
(set-fontset-font t 'han (font-spec :family "LXGW WenKai"))

(setq user-mail-address "meritamen@sdf.org"
      read-process-output-max (* 4 1024 1024)
      warning-minimum-level :error
      custom-file (expand-file-name "custom.el" user-emacs-directory)
      mac-command-modifier 'meta
      mac-option-modifier 'super
      confirm-kill-processes nil
      confirm-nonexistent-file-or-buffer nil
      window-resize-pixelwise t
      frame-resize-pixelwise t
      history-delete-duplicates t
      ring-bell-function 'ignore
      vc-follow-symlinks nil
      hscroll-margin 2
      hscroll-step 1
      scroll-conservatively 10
      scroll-margin 0
      scroll-preserve-screen-position t
      auto-window-vscroll nil
      mouse-wheel-scroll-amount '(2 ((shift) . hscroll))
      mouse-wheel-scroll-amount-horizontal 2
      require-final-newline t
      load-prefer-newer t
      use-short-answers t
      use-dialog-box nil
      frame-inhibit-implied-resize t
      ns-use-proxy-icon nil
      frame-title-format nil
      auto-revert-interval 1
      global-auto-revert-non-file-buffers t
      kill-do-not-save-duplicates t
      save-interprogram-paste-before-kill t
      backup-directory-alist '(("." . "~/.emacs.d/backup"))
      delete-old-versions t
      ffap-machine-p-known 'reject
      echo-keystrokes 0.01
      delete-trailing-lines nil
      elisp-fontify-semantically t
      imenu-auto-rescan t
      compilation-scroll-output 'first-error
      column-number-indicator-zero-based nil
      find-file-visit-truename t)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default c-basic-offset 4)
(setq-default fill-column 80)
(setq-default cursor-in-non-selected-windows nil)
(setq-default bidi-display-reordering  'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

(progn
  (require 'package)

  (setq package-check-signature nil
        package-enable-at-startup nil)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (package-initialize)

  (defmacro mrjtjmn/require (package-spec &rest body)
    (declare (indent defun))
    (let* ((vc-spec-p (consp package-spec))
           (package-name (if vc-spec-p (car package-spec) package-spec)))
      `(progn
         (unless (assq ',package-name package-alist)
           (if ,vc-spec-p
               (package-vc-install ',package-spec)
             (package-install ',package-name)))
         ,@body))))

(when (native-comp-available-p)
  (setq package-native-compile t
        native-comp-jit-compilation t
        native-comp-async-jobs-number (num-processors)
        native-comp-async-report-warnings-errors 'silent))

(progn
  (defun mrjtjmn/load-this-file ()
    "Load the current file or buffer.
The current directory is temporarily added to `load-path'.  When
there is no current file, eval the current buffer."
    (interactive)
    (let ((load-path (cons default-directory load-path))
          (file (buffer-file-name)))
      (if file
          (progn
            (save-some-buffers nil (apply-partially 'derived-mode-p 'emacs-lisp-mode))
            (load-file (buffer-file-name))
            (message "Loaded %s" file))
        (eval-buffer)
        (message "Evaluated %s" (current-buffer)))))

  (with-eval-after-load 'lisp-mode
    (define-key emacs-lisp-mode-map (kbd "C-c C-l") 'mrjtjmn/load-this-file)))

(progn
  (setq hippie-expand-try-functions-list
        '(try-expand-list
          try-expand-dabbrev-visible
          try-expand-dabbrev
          try-expand-all-abbrevs
          try-expand-dabbrev-all-buffers
          try-complete-file-name-partially
          try-complete-file-name
          try-expand-dabbrev-from-kill
          try-expand-whole-kill
          try-expand-line
          try-complete-lisp-symbol-partially
          try-complete-lisp-symbol))

  (global-set-key [remap dabbrev-expand] #'hippie-expand)

  (defun mrjtjmn/+he-subst-suffix-overlap (ins rem)
    "The longest suffix of the string INS that is a prefix of REM.
This is intended to be used when INS is a newly inserted string and REM is the
remainder of the line, to allow for handling potentially duplicated content."
    (let ((len (min (length ins) (length rem))))
      (while (and (> len 0)
                  (not (eq 't (compare-strings ins (- len) nil rem 0 len))))
        (setq len (1- len)))
      len))

  (defun mrjtjmn/+he-suffix-strip-a (args)
    "Filter ARG list for `he-substitute-string', truncating duplicated suffix.
ARGS is the raw argument list (STRING &optional TRANS-CASE)."
    (pcase-let* ((`(,ins &optional ,trans-case) args)
                 (rem (save-excursion
                        (goto-char (marker-position he-string-end))
                        (buffer-substring-no-properties
                         (point) (line-end-position))))
                 (ov (mrjtjmn/+he-subst-suffix-overlap ins rem)))
      (when (>= ov 0)
        (setq ins (substring ins 0 (- (length ins) ov))))
      (list ins trans-case)))

  (advice-add #'he-substitute-string :filter-args #'mrjtjmn/+he-suffix-strip-a))

(progn
  (require 'recentf)
  (setq recentf-max-saved-items 300
        recentf-exclude
        '("\\.?cache" ".cask" "url" "COMMIT_EDITMSG\\'" "bookmarks"
          "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
          "\\.?ido\\.last$" "\\.revive$" "/G?TAGS$" "/.elfeed/"
          "^/tmp/" "^/var/folders/.+$" "^/ssh:" "/persp-confs/"
          (lambda (file) (file-in-directory-p file package-user-dir))))
  (push (expand-file-name recentf-save-file) recentf-exclude))

(progn
  (setq xref-history-storage 'xref-window-local-history
        xref-search-program 'ripgrep))

(progn
  (setq dired-auto-revert-buffer t
        dired-isearch-filenames 'dwim
        dired-dwim-target t
        dired-kill-when-opening-new-dired-buffer t
        dired-recursive-deletes 'always
        dired-recursive-copies 'always))

(progn
  (global-set-key (kbd "C-x m") 'eshell)

  (setq eshell-buffer-maximum-lines 4096
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input 'all
        eshell-destroy-buffer-when-process-dies t)

  (setq eshell-visual-commands
        '("vi" "vim" "nvim" "less" "more" "htop" "top" "man"
          "ssh" "fzf" "watch" "python" "ipython" "bash"))

  (setq eshell-visual-subcommands
        '(("git" "log" "diff" "show")
          ("ghcup" "tui")))

  (with-eval-after-load 'eshell
    (add-to-list 'eshell-modules-list 'eshell-xtra)))

(progn
  ;; auto exit shell-mode buffer if the shell exited
  (defun mrjtjmn/shell-kill-buffer-on-exit ()
    (set-process-sentinel (get-buffer-process (current-buffer))
                          (lambda (proc event)
                            (when (memq (process-status proc) '(exit signal))
                              (kill-buffer (process-buffer proc))))))

  (add-hook 'shell-mode-hook #'mrjtjmn/shell-kill-buffer-on-exit))

(progn
  (setq python-shell-interpreter "python3"
        python-indent-offset 4)

  (add-hook 'python-mode-hook 'lsp))

(progn
  (setq isearch-allow-motion t))

(progn
  (show-paren-mode)

  ;; we will call `blink-matching-open` ourselves...
  (remove-hook 'post-self-insert-hook #'blink-paren-post-self-insert-function)

  (setq blink-matching-paren 'show)

  (defvar mrjtjmn/ov nil)

  (advice-add
   #'show-paren-function :after
   (defun mrjtjmn/show-paren--off-screen+ (&rest _args)
     "Display matching line for off-screen paren."
     (when (overlayp mrjtjmn/ov)
       (delete-overlay mrjtjmn/ov))
     ;; check if it's appropriate to show match info,
     ;; see `blink-paren-post-self-insert-function'
     (when (and (overlay-buffer show-paren--overlay)
                (not (or cursor-in-echo-area
                         executing-kbd-macro
                         noninteractive
                         (minibufferp)
                         this-command))
                (and (not (bobp))
                     (memq (char-syntax (char-before)) '(?\) ?\$)))
                (= 1 (logand 1 (- (point)
                                  (save-excursion
                                    (forward-char -1)
                                    (skip-syntax-backward "/\\")
                                    (point))))))
       ;; rebind `minibuffer-message' called by
       ;; `blink-matching-open' to handle the overlay display
       (cl-letf (((symbol-function #'minibuffer-message)
                  (lambda (msg &rest args)
                    (let ((msg (apply #'format-message msg args)))
                      (setq mrjtjmn/ov (mrjtjmn/display-line-overlay+
                                        (window-start) msg))))))
         (blink-matching-open)))))

  (defun mrjtjmn/display-line-overlay+ (pos str &optional face)
    "Display line at POS as STR with FACE.

FACE defaults to inheriting from default and highlight."
    (let ((ol (save-excursion
                (goto-char pos)
                (make-overlay (line-beginning-position)
                              (line-end-position)))))
      (overlay-put ol 'display str)
      (overlay-put ol 'face
                   (or face '(:background null :inherit highlight)))
      ol)))

(progn
  (setq erc-nick "meritamen"
        erc-sasl-user "meritamen"
        erc-server "irc.libera.chat"
        erc-autojoin-channels-alist '(("libera.chat" "#haskell" "#emacs" "#ghc"))
        erc-sasl-auth-source-function 'erc-sasl-auth-source-password-as-host)

  (with-eval-after-load 'erc
    (defalias 'erc 'erc-tls)
    (add-to-list 'erc-modules 'sasl)))

(progn
  (setq ispell-program-name "aspell")
  (add-hook 'text-mode-hook 'flyspell-mode)
  (add-hook 'prog-mode-hook 'flyspell-prog-mode)

  (with-eval-after-load 'flyspell-mode
    (define-key flyspell-mode-map (kbd "C-;") 'flyspell-correct-wrapper)))

(progn
  (require 'desktop)
  (setq desktop-restore-frames t)
  (desktop-save-mode))

(progn
  (require 'org)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((haskell . t)))

  (setq org-src-content-indentation 0)

  (with-eval-after-load 'org
    (setf (alist-get "H" org-structure-template-alist nil nil #'equal) "src haskell")))

(mrjtjmn/require exec-path-from-shell
  (when (memq window-system '(mac ns x))
    (require 'exec-path-from-shell)
    (add-to-list 'exec-path-from-shell-variables "LSP_USE_PLISTS")
    (exec-path-from-shell-initialize)))

(mrjtjmn/require flycheck)

(mrjtjmn/require haskell-mode
  (setq haskell-interactive-popup-errors nil
        haskell-process-auto-import-loaded-modules nil
        haskell-process-suggest-remove-import-lines t
        haskell-process-log t)

  (add-hook 'haskell-mode-hook 'interactive-haskell-mode)
  (add-hook 'haskell-mode-hook 'haskell-auto-insert-module-template)

  (with-eval-after-load 'haskell-mode
    (define-key haskell-mode-map (kbd "C-c C-s") 'haskell-sort-imports)
    (define-key haskell-mode-map (kbd "C-c c") 'haskell-compile))

  (with-eval-after-load 'haskell-cabal
    (define-key haskell-cabal-mode-map (kbd "C-c c") 'haskell-compile)
    (define-key haskell-cabal-mode-map (kbd "C-c C-z") 'haskell-interactive-switch))

  (define-advice haskell-process-get-repl-completions
      (:around (orig &rest arg) company)
    (unless (haskell-process-evaluating-p (haskell-interactive-process))
      (apply orig arg)))

  (define-derived-mode haskell-iface-mode fundamental-mode "Haskell Iface"
    "View the contents of Haskell interface files, by invoking `ghc --show-iface'.

This mode is not reliable: the ghc version will probably not
match that of the file."
    (delete-region (point-min) (point-max))
    (call-process "ghc" nil t nil "--show-iface" (buffer-file-name))
    (read-only-mode)
    (set-buffer-modified-p nil)
    (goto-char (point-min)))

  (add-to-list 'auto-mode-alist '("\\.hi\\'" . haskell-iface-mode)))

(mrjtjmn/require ormolu
  (with-eval-after-load 'haskell-mode
    (define-key haskell-mode-map (kbd "C-c C-f") 'ormolu-format-buffer)))

(mrjtjmn/require yasnippet (add-hook 'prog-mode-hook 'yas-minor-mode))

(mrjtjmn/require lsp-mode
  (setq lsp-headerline-breadcrumb-enable nil
        lsp-idle-delay 0.1
        lsp-restart 'ignore
        lsp-modeline-diagnostics-enable nil
        lsp-enable-snippet t
        lsp-keymap-prefix "C-c l"
        lsp-warn-no-matched-clients nil)

  (defun mrjtjmn/lsp-booster--advice-json-parse (old-fn &rest args)
    "Try to parse bytecode instead of json."
    (or
     (when (equal (following-char) ?#)
       (let ((bytecode (read (current-buffer))))
         (when (byte-code-function-p bytecode)
           (funcall bytecode))))
     (apply old-fn args)))

  (advice-add (if (progn (require 'json)
                         (fboundp 'json-parse-buffer))
                  'json-parse-buffer
                'json-read)
              :around
              #'mrjtjmn/lsp-booster--advice-json-parse)

  (defun mrjtjmn/lsp-booster--advice-final-command (old-fn cmd &optional test?)
    "Prepend emacs-lsp-booster command to lsp CMD."
    (let ((orig-result (funcall old-fn cmd test?)))
      (if (and (not test?)
               (not (file-remote-p default-directory))
               lsp-use-plists
               (not (functionp 'json-rpc-connection))
               (executable-find "emacs-lsp-booster"))
          (progn
            (when-let* ((command-from-exec-path (executable-find (car orig-result))))
              (setcar orig-result command-from-exec-path))
            (message "Using emacs-lsp-booster for %s!" orig-result)
            (cons "emacs-lsp-booster" orig-result))
        orig-result)))

  (advice-add 'lsp-resolve-final-command :around #'mrjtjmn/lsp-booster--advice-final-command)

  (setq lsp-clients-clangd-args `(,(concat "-j=" (number-to-string (num-processors)))
                                  "--log=error"
                                  "--background-index"
                                  "--header-insertion=never"
                                  "--completion-style=detailed"))

  (add-hook 'c-mode-hook 'lsp)
  (add-hook 'c++-mode-hook 'lsp)

  (add-hook 'c-mode-common-hook (lambda () (local-set-key (kbd "RET") #'c-context-line-break)))

  (defun mrjtjmn/insert-include-guards ()
    (interactive)
    (let* ((filename (buffer-name)))
      (when (and (string-match-p "\\.hpp\\|\\.hxx\\|\\.h\\'" filename)
                 (zerop (buffer-size)))
        (let ((result (upcase (replace-regexp-in-string (regexp-quote ".") "_" filename))))
          (insert (concat "#ifndef " result "\n"))
          (insert (concat "#define " result "\n\n\n\n"))
          (insert "#endif")
          (forward-line -2)))))

  (add-hook 'c-mode-hook 'mrjtjmn/insert-include-guards)
  (add-hook 'c++-mode-hook 'mrjtjmn/insert-include-guards))

(mrjtjmn/require lsp-ui
  (setq lsp-ui-sideline-enable t
        lsp-ui-sideline-show-symbol nil
        lsp-ui-sideline-show-diagnostics t)

  (add-hook 'lsp-mode-hook 'lsp-ui-mode)

  (with-eval-after-load 'lsp-ui
    (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
    (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)))

(mrjtjmn/require lsp-haskell
  (add-hook 'haskell-mode-hook 'lsp)
  (setq lsp-haskell-server-args `("-j" ,(number-to-string (num-processors))
                                  "-l" "/tmp/hls.log")
        lsp-haskell-plugin-import-lens-code-lens-on nil)

  ;; HACK: Override default M-. binding after loading haskell.el
  ;; In lsp-mode, Use lsp-ui-peek-find-references instead of
  ;; haskell-mode-jump-to-def-or-tag. This wore me out......
  (with-eval-after-load 'haskell
    (define-key interactive-haskell-mode-map
                (kbd "M-.") #'lsp-ui-peek-find-definitions)))

(mrjtjmn/require company
  (setq company-tooltip-align-annotations t
        company-transformers '(company-sort-by-occurrence))
  (add-hook 'after-init-hook 'global-company-mode))

(mrjtjmn/require vundo (global-set-key (kbd "C-c v") 'vundo))

(mrjtjmn/require magit
  (setq magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1
        magit-auto-revert-mode t
        magit-clone-default-directory "~/Repositories/")

  (with-eval-after-load 'magit
    (define-key magit-status-mode-map (kbd "M-RET") 'magit-diff-visit-file-other-window))

  (global-set-key (kbd "C-x G") 'magit-dispatch))

(mrjtjmn/require magit-todos (with-eval-after-load 'magit (magit-todos-mode)))

(mrjtjmn/require magit-delta (add-hook 'magit-mode-hook 'magit-delta-mode))

(mrjtjmn/require spacemacs-theme
  (setq custom-safe-themes t
        spacemacs-theme-comment-bg nil
        spacemacs-theme-comment-italic t
        spacemacs-theme-keyword-italic t
        spacemacs-theme-underline-parens nil)

  (advice-add 'load-theme
              :after
              (lambda (theme &rest _)
                (when (eq theme 'spacemacs-light)
                  (set-cursor-color "#655370")
                  (with-eval-after-load 'spaceline
                    (spaceline-compile)))))

  (advice-add 'load-theme
              :after
              (lambda (theme &rest _)
                (when (eq theme 'spacemacs-dark)
                  (set-cursor-color "#b2b2b2")
                  (with-eval-after-load 'spaceline
                    (spaceline-compile)))))

  (load-theme 'spacemacs-light t)

  (advice-add 'load-theme
              :before (lambda (theme &optional no-confirm no-enable)
                        (disable-theme (car custom-enabled-themes)))))

(mrjtjmn/require helm
  (setq helm-completions-detailed nil
        helm-move-to-line-cycle-in-source nil
        helm-show-action-window-other-window nil
        helm-split-window-inside-p t
        helm-display-function 'spacemacs//display-helm-window
        helm-echo-input-in-header-line t)

  (helm-mode)

  (global-set-key (kbd "C-x b") 'helm-buffers-list)
  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "M-y") 'helm-show-kill-ring)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  (global-set-key (kbd "C-c i") 'helm-imenu)
  (global-set-key (kbd "C-c C") 'helm-occur)
  (global-set-key (kbd "C-c I") 'helm-imenu-in-all-buffers)
  (global-set-key (kbd "C-x C-r") 'helm-recentf)

  (with-eval-after-load 'helm
    (define-key helm-map (kbd "TAB") 'helm-execute-persistent-action)
    (define-key helm-map (kbd "C-j") 'helm-select-action))

  (defvar spacemacs/helm-display-help-buffer-regexp '("*.*Helm.*Help.**"))

  (defvar spacemacs/helm-display-buffer-regexp
    `("*.*helm.**"
      (display-buffer-in-side-window)
      (inhibit-same-window . t)
      (side . bottom)
      (window-width . 0.6)
      (window-height . 0.4)))

  (defun spacemacs//display-helm-window (buffer &optional resume)
    "Display the Helm window respecting `helm-position'."
    (let ((display-buffer-alist
           (list spacemacs/helm-display-help-buffer-regexp
                 spacemacs/helm-display-buffer-regexp)))
      (helm-default-display-buffer buffer))))

(mrjtjmn/require helm-hoogle
  (with-eval-after-load 'haskell
    (define-key haskell-mode-map (kbd "C-c H") 'helm-hoogle)
    (define-key haskell-cabal-mode-map (kbd "C-c H") 'helm-hoogle)))

(mrjtjmn/require helm-xref)

(mrjtjmn/require projectile
  (setq projectile-completion-system 'helm
        projectile-enable-caching 'persistent
        projectile-indexing-method 'hybrid
        projectile-sort-order 'recentf
        projectile-project-search-path '("~/Repositories/"))

  (projectile-mode)

  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "<f8>")   #'projectile-compile-project)
  (define-key projectile-mode-map (kbd "M-<f8>") #'kill-compilation))

(mrjtjmn/require helm-projectile (helm-projectile-mode))

(mrjtjmn/require ibuffer-projectile
  (add-hook 'ibuffer-hook
    (lambda ()
      (ibuffer-projectile-set-filter-groups)
      (unless (eq ibuffer-sorting-mode 'alphabetic)
        (ibuffer-do-sort-by-alphabetic))))

  (setq ibuffer-formats
        '((mark modified read-only " "
                (name 18 18 :left :elide)
                " "
                (size 9 -1 :right)
                " "
                (mode 16 16 :left :elide)
                " "
                project-relative-file))

        ibuffer-never-show-predicates '("^\\*helm"))

  (global-set-key [remap list-buffers] 'ibuffer))

(mrjtjmn/require macrostep (define-key emacs-lisp-mode-map (kbd "C-c e") 'macrostep-expand))

(mrjtjmn/require cmake-mode)

(mrjtjmn/require ninja-mode)

(mrjtjmn/require markdown-mode)

(mrjtjmn/require diminish
  (with-eval-after-load 'which-key (diminish 'which-key-mode))
  (with-eval-after-load 'flycheck (diminish 'flycheck-mode))
  (with-eval-after-load 'yasnippet (diminish 'yas-minor-mode))
  (with-eval-after-load 'haskell (diminish 'interactive-haskell-mode))
  (with-eval-after-load 'lsp-lens (diminish 'lsp-lens-mode)))

(mrjtjmn/require immortal-scratch
  (add-hook 'after-init-hook 'immortal-scratch-mode))

(mrjtjmn/require gcmh
  (add-hook 'after-init-hook 'gcmh-mode)
  (setq gcmh-idle-delay 'auto
        gcmh-auto-idle-delay-factor 10
        gcmh-high-cons-threshold #x4000000))

(mrjtjmn/require clang-format
  (add-hook 'c-mode-hook 'clang-format-on-save-mode)
  (add-hook 'c++-mode-hook 'clang-format-on-save-mode))

(mrjtjmn/require ns-auto-titlebar
  (when (eq system-type 'darwin) (ns-auto-titlebar-mode)))

(mrjtjmn/require yaml-mode)

(mrjtjmn/require csv-mode (add-hook 'csv-mode-hook 'csv-align-mode))

(mrjtjmn/require sml-mode)

(mrjtjmn/require adaptive-wrap (add-hook 'visual-line-mode-hook 'adaptive-wrap-prefix-mode))

(mrjtjmn/require eshell-z (add-hook 'eshell-mode-hook (lambda () (require 'eshell-z))))

(mrjtjmn/require fd-dired (global-set-key (kbd "C-c f") 'fd-dired))

(mrjtjmn/require cmm-mode)

(mrjtjmn/require vimrc-mode)

(mrjtjmn/require dockerfile-mode)

(progn
  (load-file (let ((coding-system-for-read 'utf-8))
               (shell-command-to-string "agda --emacs-mode locate")))
  (add-to-list 'auto-mode-alist '("\\.lagda.md\\'" . agda2-mode))
  (global-set-key (kbd "C-c C-k") 'describe-char)
  (setq agda2-highlight-level 'none))

(mrjtjmn/require git-timemachine (global-set-key (kbd "C-c g") 'git-timemachine-toggle))

(mrjtjmn/require string-inflection
  (global-set-key (kbd "C-` `") 'string-inflection-all-cycle)
  (global-set-key (kbd "C-` t") 'string-inflection-toggle)
  (global-set-key (kbd "C-` c") 'string-inflection-camel-case)
  (global-set-key (kbd "C-` d") 'string-inflection-lower-camel-case)
  (global-set-key (kbd "C-` k") 'string-inflection-kebab-case)
  (global-set-key (kbd "C-` _") 'string-inflection-snake-case)
  (global-set-key (kbd "C-` u") 'string-inflection-capital-snake-case)
  (global-set-key (kbd "C-` U") 'string-inflection-upcase))

(mrjtjmn/require treemacs
  (global-set-key (kbd "M-0") 'treemacs-select-window)
  (global-set-key (kbd "C-x t t") 'treemacs)
  (global-set-key (kbd "C-x t B") 'treemacs-bookmark)
  (global-set-key (kbd "C-x t C-t") 'treemacs-find-file)

  (mrjtjmn/require treemacs-magit)

  (mrjtjmn/require treemacs-projectile))

(mrjtjmn/require slime (setq inferior-lisp-program "sbcl"))

(mrjtjmn/require tuareg)

(mrjtjmn/require bison-mode (add-to-list 'auto-mode-alist '("\\.bison\\'" . bison-mode)))

(mrjtjmn/require spaceline
  (mrjtjmn/require winum
    (setq winum-auto-setup-mode-line nil)
    (winum-mode))

  (mrjtjmn/require fancy-battery (fancy-battery-mode))

  (setq powerline-default-separator 'wave
        spaceline-window-numbers-unicode t
        spaceline-highlight-face-func 'spaceline-highlight-face-evil-state)

  (spaceline-spacemacs-theme)
  (spaceline-helm-mode)
  (spaceline-toggle-input-method-on)
  (spaceline-toggle-evil-state-on)

  (setq powerline-height 28)

  (spaceline-compile)

  (defvar spacemacs--diminished-minor-modes nil
    "List of diminished modes to unicode or ascii values.")

  (defmacro spacemacs|diminish (mode &optional unicode ascii)
    "Diminish MODE name in mode line to UNICODE or ASCII depending on the value
`dotspacemacs-mode-line-unicode-symbols'.
If ASCII is not provided then UNICODE is used instead. If neither are provided,
the mode will not show in the mode line."
    (when (and unicode
               (not (display-graphic-p))
               (= (length unicode) 3))
      (setq unicode (spacemacs/terminal-fix-mode-line-indicator-overlap unicode)))
    `(let ((cell (assq ',mode spacemacs--diminished-minor-modes)))
       (if cell
           (setcdr cell '(,unicode ,ascii))
         (push '(,mode ,unicode ,ascii) spacemacs--diminished-minor-modes))))

  (defun spacemacs/diminish-undo (mode)
    "Restore the diminished lighter."
    (interactive
     (list (read (completing-read
                  "Restore what diminished mode: "
                  (cons (list "diminished-modes")
                        (mapcar (lambda (x) (list (symbol-name (car x))))
                                diminished-mode-alist))
                  nil t nil 'diminish-history-symbols))))
    (setq spacemacs--diminished-minor-modes
          (delq nil (mapcar (lambda (x) (unless (eq (car x) mode) x))
                            spacemacs--diminished-minor-modes)))
    (diminish-undo mode))

  (defmacro spacemacs|hide-lighter (mode)
    "Diminish MODE name in mode line to LIGHTER."
    `(eval-after-load 'diminish '(diminish ',mode)))

  (defun spacemacs/terminal-fix-mode-line-indicator-overlap (str)
    "Add a space between two mode line indicators,
to fix an overlapping issue, that occurs when
Spacemacs is started in a terminal,
and a modes mode line name is diminished to:
- A unicode character followed by a non unicode character, ex: \" Ⓔh\"
- Or to two unicode characters, ex: \" Ⓔⓗ\""
    (let ((first-char (substring str 1 2))
          second-char)
      (if (equal (char-charset (string-to-char first-char)) 'unicode)
          (progn
            (setq second-char (substring str 2 3))
            (concat first-char " " second-char))
        str)))

  (defun spacemacs/diminish-hook ()
    (dolist (mm spacemacs--diminished-minor-modes)
      (let ((mode (car mm))
            (unic (cadr mm))
            (asci (caddr mm)))
        (setq spaceline-minor-modes-separator
            (if (display-graphic-p) "" " "))
        (when (and (boundp mode) (symbol-value mode))
          (diminish mode (if (display-graphic-p) unic asci))))))

  (with-eval-after-load 'abbrev (spacemacs|diminish abbrev-mode " ⓐ" " a"))
  (with-eval-after-load 'isearch (spacemacs|diminish isearch-mode " ⓘ" " i"))
  (with-eval-after-load 'gcmh (spacemacs|diminish gcmh-mode " ⓖ" " g"))
  (with-eval-after-load 'eldoc (spacemacs|diminish eldoc-mode " ⓔ" " e"))
  (with-eval-after-load 'projectile (spacemacs|diminish projectile-mode " ⓟ" " p"))
  (with-eval-after-load 'flyspell (spacemacs|diminish flyspell-mode " ⓕ" " f"))
  (with-eval-after-load 'flyspell (spacemacs|diminish flyspel-prog-mode " ⓕ" " f"))
  (with-eval-after-load 'simple (spacemacs|diminish visual-line-mode " ⓥ" " v"))
  (with-eval-after-load 'subword (spacemacs|diminish subword-mode " ⓢ" " s"))
  (with-eval-after-load 'helm (spacemacs|diminish helm-mode " ⓗ" " h"))
  (with-eval-after-load 'company (spacemacs|diminish company-mode " ⓒ" " c"))
  (with-eval-after-load 'lsp-mode (spacemacs|diminish lsp-mode " Ⓛ" " L"))
  (with-eval-after-load 'vi-tilde-fringe (spacemacs|diminish vi-tilde-fringe-mode " Ⓥ" " V"))

  (add-hook 'spaceline-pre-hook 'spacemacs/diminish-hook))

(mrjtjmn/require vi-tilde-fringe (global-vi-tilde-fringe-mode))

(mrjtjmn/require diff-hl
  (setq diff-hl-update-async t)
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode))

(mrjtjmn/require anzu
  (global-anzu-mode)
  (diminish 'anzu-mode)
  (setq anzu-mode-lighter ""
        anzu-search-threshold 1000
        anzu-replace-to-string-separator " => ")

  (cl-defun spacemacs/anzu-update-mode-line (here total)
    "Custom update function which does not propertize the status."
    (when (bound-and-true-p anzu--state)
      (let ((status
             (cl-case anzu--state
               (search (format "(%s/%d%s)"
                               (anzu--format-here-position here total)
                               total (if (and (boundp 'anzu--overflow-p) anzu--overflow-p) "+" "")))
               (replace-query (format "(%d replace)" total))
               (replace (format "(%d/%d)" here total)))))
        status)))

  (setq anzu-mode-line-update-function 'spacemacs/anzu-update-mode-line
        anzu-cons-mode-line-p nil)

  (global-set-key [remap query-replace] #'anzu-query-replace)
  (global-set-key [remap query-replace-regexp] #'anzu-query-replace-regexp))

(mrjtjmn/require yasnippet-snippets)

(mrjtjmn/require rg
  (rg-enable-default-bindings)

  (mrjtjmn/require wgrep
    (setq wgrep-auto-save-buffer t)))

(mrjtjmn/require multiple-cursors
  (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this))

(mrjtjmn/require rust-mode
  (add-hook 'rust-mode-hook 'lsp)
  (mrjtjmn/require cargo-mode))

(when (file-exists-p custom-file) (load custom-file 'noerror))
