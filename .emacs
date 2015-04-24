;;; git https://github.com/kvic74/my_emacs
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")))
(require 'package)
; initialize package.el
(package-initialize)

;; Парные скобки
(setq show-paren-style 'expression)
(show-paren-mode 2)

;; turn on automatic bracket insertion by pairs. New in emacs 24
;; http://ergoemacs.org/emacs/emacs_insert_brackets_by_pair.html
(electric-pair-mode 1)
;; make electric-pair-mode work on more brackets
(setq electric-pair-pairs '(
                            (?\" . ?\")
                            (?\{ . ?\})
                            ) )
;; turn on highlight matching brackets when cursor is on one
;; http://ergoemacs.org/emacs/emacs_highlight_parenthesis.html
(show-paren-mode 1)
(setq show-paren-style 'expression) ; highlight entire bracket expression

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(show-paren-match ((((class color) (background light)) (:background "azure2")))))

;; http://www.emacswiki.org/emacs/ColorTheme
;; Tools -> Color themes
;;(add-to-list 'load-path "~/.emacs.d/plugin/color-theme/")
(require 'color-theme)
(color-theme-initialize)
(setq color-theme-is-global t)
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

(if window-system
    (load-theme 'zenburn t) ;; С этой темой emacs будет в X11
(color-theme-classic))

;; (color-theme-robin-hood)


;;display-time-format is the variable to control the format, and display-time-string-forms for the more complex requirements (such as InternetTime).
(display-time-mode 1)

(setq make-backup-files         nil) ; Don't want any backup files
(setq auto-save-list-file-name  nil) ; Don't want any .saves files
(setq auto-save-default         nil) ; Don't want any auto saving

; start auto-complete with emacs
(require 'auto-complete)
; do default config for auto-complete
(require 'auto-complete-config)
(ac-config-default)
; start yasnippet with emacs
(require 'yasnippet)
(yas-global-mode 1)

;; x11 cut & past
(setq x-select-enable-clipboard t)


;; Run Current File
;; http://ergoemacs.org/emacs/elisp_run_current_file.html
(defun xah-run-current-file ()
  "Execute the current file.
For example, if the current buffer is the file xx.py, then it'll call 「python xx.py」 in a shell.
The file can be php, perl, python, ruby, javascript, bash, ocaml, vb, elisp.
File suffix is used to determine what program to run.

If the file is modified, ask if you want to save first.

URL `http://ergoemacs.org/emacs/elisp_run_current_file.html'
version 2014-10-28"
  (interactive)
  (let* (
         (suffixMap
          ;; (‹extension› . ‹shell program name›)
          `(
            ("php" . "php")
            ("pl" . "perl")
            ("py" . "python")
            ("py3" . ,(if (string-equal system-type "windows-nt") "c:/Python32/python.exe" "python3"))
            ("rb" . "ruby")
            ("js" . "node") ; node.js
            ("sh" . "bash")
            ("clj" . "java -cp /home/xah/apps/clojure-1.6.0/clojure-1.6.0.jar clojure.main")
            ("ml" . "ocaml")
            ("vbs" . "cscript")
            ;; ("pov" . "/usr/local/bin/povray +R2 +A0.1 +J1.2 +Am2 +Q9 +H480 +W640")
            ))
         (fName (buffer-file-name))
         (fSuffix (file-name-extension fName))
         (progName (cdr (assoc fSuffix suffixMap)))
         (cmdStr (concat progName " \""   fName "\"")))

    (when (buffer-modified-p)
      (when (y-or-n-p "Buffer modified. Do you want to save first?")
        (save-buffer)))

    (if (string-equal fSuffix "el") ; special case for emacs lisp
        (load fName)
      (if progName
          (progn
            (message "Running…")
            (shell-command ξcmdStr "*xah-run-current-file output*" ))
        (message "No recognized program file suffix for this file.")))))
(global-set-key (kbd "<f8>") 'xah-run-current-file)

;; c++

;; let's define a function which initializes auto-complete-c-headers
;; and gets called for c/c++ hooks
(defun my:ac-c-header-init ()
  (require 'auto-complete-c-headers)
  (add-to-list 'ac-sources 'ac-source-c-headers)
  (add-to-list 'achead:include-directories '"/usr/include/c++/4.7")
)
; now let's call this function from c/c++ hooks
(add-hook 'c++-mode-hook 'my:ac-c-header-init)
(add-hook 'c-mode-hook 'my:ac-c-header-init)

; Fix iedit bug in Mac
(define-key global-map (kbd "C-c ;") 'iedit-mode)

; start flymake-google-cpplint-load
; let's define a function for flymake initialization
(defun my:flymake-google-init () 
  (require 'flymake-google-cpplint)
  (custom-set-variables
   '(flymake-google-cpplint-command "/usr/local/lib/python2.7/dist-packages/cpplint"))
  (flymake-google-cpplint-load)
)
(add-hook 'c-mode-hook 'my:flymake-google-init)
(add-hook 'c++-mode-hook 'my:flymake-google-init)

; start google-c-style with emacs
(require 'google-c-style)
(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

; turn on Semantic
(semantic-mode 1)
; let's define a function which adds semantic as a suggestion backend to auto complete
; and hook this function to c-mode-common-hook
(defun my:add-semantic-to-autocomplete()
  (add-to-list 'ac-sources 'ac-source-semantic))
(add-hook 'c-mode-common-hook 'my:add-semantic-to-autocomplete)
; turn on ede mode
(global-ede-mode 1)
; create a project for our program.
(ede-cpp-root-project "my project" :file "~/Documents/Projects/c++/main.cpp"
		      :include-path '("/../inc"))
; you can use system-include-path for setting up the system header file locations.
; turn on automatic reparsing of open buffers in semantic
(global-semantic-idle-scheduler-mode 1)

;; compilie
(require 'compile)

(add-hook 'c++-mode-hook
   (lambda ()
     (unless (file-exists-p "Makefile")
       (set (make-local-variable 'compile-command)
 	   (let ((file (file-name-nondirectory buffer-file-name)))
 	     (concat "g++ -g -O2 -Wall -o " 
 		     (file-name-sans-extension file)
 		     " " file))))))

(add-hook 'c-mode-hook
           (lambda ()
	     (unless (file-exists-p "Makefile")
	       (set (make-local-variable 'compile-command)
                    ;; emulate make's .c.o implicit pattern rule, but with
                    ;; different defaults for the CC, CPPFLAGS, and CFLAGS
                    ;; variables:
                    ;; $(CC) -c -o $@ $(CPPFLAGS) $(CFLAGS) $<
		    (let ((file (file-name-nondirectory buffer-file-name)))
                      (format "%s -c -o %s.o %s %s %s"
                              (or (getenv "CC") "gcc")
                              (file-name-sans-extension file)
                              (or (getenv "CPPFLAGS") "-DDEBUG=9")
                              (or (getenv "CFLAGS") "-ansi -pedantic -Wall -g")
			      file))))))

(global-set-key [(f9)] 'compile)
(global-set-key [(f5)] 'gdb)


;; python

(elpy-enable)

;; Fixing a key binding bug in elpy
(define-key yas-minor-mode-map (kbd "C-c k") 'yas-expand)
 ;; Fixing another key binding bug in iedit mode
(define-key global-map (kbd "C-c o") 'iedit-mode)

(setenv "PYTHONPATH" "/usr/bin/python") 

;; lisp

;(setq inferior-lisp-program "sbcl")
;(load (expand-file-name "~/quicklisp/slime-helper.el"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pretty print xml region
(defun pretty-print-xml-region (begin end)
  "Pretty format XML markup in region. You need to have nxml-mode
http://www.emacswiki.org/cgi-bin/wiki/NxmlMode installed to do
this.  The function inserts linebreaks to separate tags that have
nothing but whitespace between them.  It then indents the markup
by using nxml's indentation rules."
  (interactive "r")
  (save-excursion
    (nxml-mode)
    (goto-char begin)
    ;; split <foo><foo> or </foo><foo>, but not <foo></foo>
    (while (search-forward-regexp ">[ \t]*<[^/]" end t)
      (backward-char 2) (insert "\n") (incf end))
    ;; split <foo/></foo> and </foo></foo>
    (goto-char begin)
    (while (search-forward-regexp "<.*?/.*?>[ \t]*<" end t)
      (backward-char) (insert "\n") (incf end))
    (indent-region begin end nil)
    (normal-mode))
  (message "All indented!"))

;; arduino
;(require 'arduino-mode)
;(setq auto-mode-alist (cons '("\\.\\(pde\\|ino\\)$" . arduino-mode) auto-mode-alist))
;(autoload 'arduino-mode "arduino-mode" "Arduino editing mode." t)

;;
;;(load "~/quicklisp/setup.lisp")
(load (expand-file-name "~/quicklisp/slime-helper.el"))
(setq inferior-lisp-program "sbcl")

;; default browser

(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "conkeror")


;; newsticker
(require 'newsticker)

; W3M HTML renderer isn't essential, but it's pretty useful.
(require 'w3m)
(setq newsticker-html-renderer 'w3m-region)

; We want our feeds pulled every 10 minutes.
(setq newsticker-retrieval-interval 600)

; Setup the feeds. We'll have a look at these in just a second.
(setq newsticker-url-list-defaults nil)
(setq newsticker-url-list '("..."))

; Optionally bind a shortcut for your new RSS reader.
(global-set-key (kbd "C-c r") 'newsticker-treeview)

(setq newsticker-url-list '(
                       ("emacs-fu" "http://emacs-fu.blogspot.com/feeds/posts/default" nil nil nil)
                       ("abandonia" "http://www.abandonia.com/en/rss.xml" nil nil nil)
                       ("arch linux" "https://www.archlinux.org/feeds/news/" nil nil nil)
                       ("Planet Emacsen" "http://planet.emacsen.org/atom.xml" nil nil nil)
                       ("slashdot" "http://rss.slashdot.org/Slashdot/slashdot" nil nil nil)
                       ("Jävligt gott" "http://www.javligtgott.se/feed/" nil nil nil)
                       ("Kmandla" "http://kmandla.wordpress.com/feed/" nil nil nil)
                       ("mojäng" "http://www.mojang.com/feed" nil nil nil)
                       ("SMBC" "http://www.smbc-comics.com/rss.php" nil nil nil)
                       ("xkcd" "https://www.xkcd.com/rss.xml" nil nil nil)
                       ("laserbrain" "http://laserbrainstudios.com/feed/" nil nil nil)
                       ;;("imdb" "http://rss.imdb.com/daily/poll" nil nil nil)
                       ("rotten" "https://www.rottentomatoes.com/syndication/rss/top_news.xml" nil nil nil)
                       ;;("BBC World" "http://feeds.bbci.co.uk/news/world/rss.xml" nil nil nil)
                       ("BBC Sci" "http://feeds.bbci.co.uk/news/science_and_environment/rss.xml" nil nil nil)
                       ;;("Coursera" "http://blog.coursera.org/rss" nil nil nil)
                       ;;("stallman" "http://www.stallman.org/rss/rss.xml" nil nil nil)
                       ("emacs rocks" "http://emacsrocks.com/atom.xml" nil nil nil)
                       ("endlessparentheses" "http://endlessparentheses.com/atom.xml" nil nil nil)
                       ;;("blabbermouth" "http://feeds.feedburner.com/blabbermouth" nil nil nil)
                       ("sds" "http://www.sydsvenskan.se/rss.xml" nil nil nil)
                       ("di" "http://di.se/rss" nil nil nil)
                       ("affärsvärlden" "http://www.affarsvarlden.se/?service=rss" nil nil nil)
                       ("börspodden" "http://borspodden.se/feed/" nil nil nil)
                       ("veckans aktie" "http://feeds.soundcloud.com/users/soundcloud:users:2000425/sounds.rss" nil nil nil)
                       ("dividend mantra" "http://feeds.feedburner.com/DividendMantra/" nil nil nil)
                       ("avpixlat" "http://avpixlat.info/feed/" nil nil nil)
                       ;;("recepten" "http://www.recepten.se/feed/blog_rss2.xhtml" nil nil nil)
                       ;;("Hacker News" "http://news.ycombinator.com/rss" nil nil nil)
                       ("veckans aktie" "http://feeds.soundcloud.com/users/soundcloud:users:2000425/sounds.rss" nil nil nil)
                       ("screen junkies" "http://www.youtube.com/rss/user/screenjunkies/feed.rss" nil nil nil)
                       ("Matte Northice" "http://www.youtube.com/rss/user/gurskit8/feed.rss" nil nil nil)
                       ("failarmy" "http://www.youtube.com/rss/user/failarmy/feed.rss" nil nil nil)
 		       ("planet emacsen ru" "http://planet.emacsen.org/ru/atom.xml" nil nil nil)
                       ))

; Don't forget to start it!
(newsticker-start)

;; epub mode
;; http://inasmuch.as/2011/04/06/opening-epub-in-emacs/

(setq auto-mode-alist
 (append
 (list
 '("\\.epub$" . archive-mode))
 auto-mode-alist))
(setq auto-coding-alist
 (append
 (list
 '("\\.epub$" . no-conversion))
 auto-coding-alist))

;; magit
(setq magit-auto-revert-mode nil)
(setq magit-last-seen-setup-instructions "1.4.0")







