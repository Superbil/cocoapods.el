;;; cocoapods.el --- Manage cocoapods from Emacs

;; Copyright (C) 2016 Cheng, Kai-Yuan

;; Author: Cheng, Kai-Yuan
;; Version: 0.1.0
;; Keywords: tools
;; Created: 19 Jul 2016
;; Package-Requires: ((emacs "24.3"))
;; URL: https://github.com/Superbil/cocoapods.el

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Cocoapods is a project management tool for cocoa developer that helps
;; use it in Emacs.

;;; Code:

(defgroup cocoapods nil
  "Customzation group for `cocoapods.el'."
  :group 'tools)

(defcustom cocoapods-command-path "pod"
  "Cocoapods command path."
  :group 'cocoapods
  :type 'string)

(defvar-local cocoapods-podfile nil
  "Default path to Podfile")


;;;; Internal functions

(defun cocoapods--locate-podfile (&optional dir)
  "Find Podfile for DIR."
  (or (locate-dominating-file (or dir default-directory) "Podfile")
      (or cocoapods-podfile
          (error "No Podfile found in %s or any parent directory" dir))))

(defun cocoapods--command (sub-command &optional use-async dir)
  "Execute cocoapods with SUB-COMMAND at root of the project.
USE-ASYNC Execute command in async buffer or sync buffer.
DIR use for `cocoapods--locate-podfile'."
  (let* ((default-directory (file-name-directory (cocoapods--locate-podfile dir)))
         (command (format "%s %s" cocoapods-command-path sub-command))
         (name (concat "*Cocopoads-" (if use-async "Async" "Sync") "*")))
    (if use-async
        ;; TODO: executable custom script(hook)
        (async-shell-command command name)
      (shell-command command name))))

(defun cocoapods-projectile-command (sub-command &optional use-async)
  "Execute cocoapods and SUB-COMMAND with projectitle.
USE-ASYNC execute command in async buffer or sync buffer."
  (projectile-with-default-dir (projectile-project-root)
    (cocoapods--command sub-command use-async (projectile-project-root))))


;;;; Public API

;;;###autoload
(defun cocoapods-version ()
  "Cococapods version."
  (interactive)
  (message "Cocoapods-version %s"
           (substring
            (shell-command-to-string (format "%s --version" cocoapods-command-path))
            0 -1)))

;;;###autoload
(defun cocoapods-init ()
  "Execute 'pod init' at root of the project."
  (interactive)
  (cocoapods--command "init" t))

;;;###autoload
(defun cocoapods-install ()
  "Execute 'pod install' at root of the project."
  (interactive)
  (cocoapods--command "install" t))

;;;###autoload
(defun cocoapods-update ()
  "Execute 'pod update' at root of the project."
  (interactive)
  (cocoapods--command "update" t))

(defun cocoapods-open ()
  "Execute 'pod open' at root of the project.

Opens the workspace in xcode. If no workspace found in the current
directory looks up until finds one."
  (interactive)
  ;; TOOD: check cocoapods-open is installed.
  (cocoapods--command "open" nil))

(defun cocoapods-reinstall ()
  "Execute 'pod reinstall' at root of the project.

Runs 'pod install' fefor trying to reopen the workspace with 'pod open'."
  (interactive)
  (cocoapods--command "reinstall" t))

(after-load 'projectile
  (defun cocoapods-init@projectile ()
    "Execute 'pod init' at root of the project."
    (interactive)
    (cocoapods-projectile-command "init" t))

  (defun cocoapods-command-install@projectitle ()
    "Execute 'pod install' at root of the project."
    (interactive)
    (cocoapods-projectile-command "install" t))

  (defun cocoapods-update@projectile ()
    "Execute 'pod update' at root of the project."
    (interactive)
    (projectile-cocoapods-command "update" t))

  (defun cocoapods-open@projectile ()
    "Execute 'pod open' at root of the project.

Opens the workspace in xcode. If no workspace found in the current
directory looks up until finds one."
    (interactive)
    ;; TOOD: check cocoapods-open is installed.
    (cocoapods-projectile-command "open" nil))

  (defun cocoapods-reinstall@projectile ()
    "Execute 'pod reinstall' at root of the project.

Runs 'pod install' fefor trying to reopen the workspace with 'pod open'."
    (interactive)
    (cocoapods-projectile-command "reinstall" t))
  )

(provide 'cocoapods)

;;; cocoapods.el ends here
