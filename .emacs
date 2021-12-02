;; Prevent ssl from complaining on OSX - at one point this was needed,
;; along with `brew install libressl`
(require 'gnutls)
(add-to-list 'gnutls-trustfiles "/usr/local/etc/openssl/cert.pem")
(setq create-lockfiles nil)

;; Load a preinstalled use-package (I sometimes preinstall it from bash). To get it:
;;   mkdir ~/_emacs_use_package
;;   git clone git@github.com:jwiegley/use-package.git ~/_emacs_use_package/use-package
;;
(eval-when-compile
    ;; Following line is not needed if use-package.el is in ~/.emacs.d
      (add-to-list 'load-path "~/_emacs_use_package/use-package")
        (require 'use-package))

;; Devserver specific goodies
(if (require 'fb-master nil t)
 (setq url-proxy-services
      '(("no_proxy" . "^\\(localhost\\|10.*\\)")
        ("http" . "fwdproxy:8080")
        ("https" . "fwdproxy:8080"))))


;; *************
;; Virtual-Emacs
;; *************
;;
;; This code makes it so that I can override almost all of the emacs setup by
;; setting an EMACSDIR environment variable.
;;
;; By default it will use  `~/.emacs.d` (or, if I'm in aquamacs, `~/aquamacs.d`
;; but this allows me to run any combination of different setups: from scratch,
;; doom, spacemacs, etc.
;;
;; It also makes experimenting with new configs (e.g. a spacemacs upgrade) easy:
;; just clone the directory and use a different EMACSDIR.
;;
;; I usually make little executable scripts that look like this to run
;; various emacs configurations:
;;  #!/usr/bin/env bash
;;  EMACSDIR=~/<DIRECTORY> nohup emacs "$@" </dev/$HOME/<DIRECTORY>.log 2>&1 &
;;
;; It was adapted from
;; https://emacs.stackexchange.com/questions/19936/running-spacemacs-alongside-regular-emacs-how-to-keep-a-separate-emacs-d/20508#20508
(let* ((is-aquamacs
        (fboundp 'aquamacs-elisp-reference))
       (user-init-dir-default
        (file-name-as-directory (if is-aquamacs
                                    "~/aquamacs.d"
                                    "~/.emacs.d")))
       (user-init-dir
        (file-name-as-directory (or (getenv "EMACSDIR")
                                    user-init-dir-default)))
       (user-init-file-1
        (expand-file-name "init" user-init-dir)))
  (setq user-emacs-directory user-init-dir)
  (with-eval-after-load "server"
    (setq server-name
          (let ((server--name (file-name-nondirectory
                               (directory-file-name user-emacs-directory))))
            (if (equal server--name ".emacs.d")
                "server"
              server--name))))
  (setq user-init-file t)
  (load user-init-file-1 t t)
  (when (eq user-init-file t)
    (setq user-emacs-directory user-init-dir-default)
    (load (expand-file-name "init" user-init-dir-default) t t)))

(provide '.emacs)
