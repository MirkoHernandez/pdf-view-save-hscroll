;;; pdf-view-save-hscroll.el --- A minor mode that provides saving the hscroll value  per page of a PDF document. -*- lexical-binding: t -*-

;; Copyright (C) 2024 Mirko Hernandez

;; Author: Mirko Hernandez <mirkoh@fastmail.com>
;; Maintainer: Mirko Hernandez <mirkoh@fastmail.com>>
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Version: 0.1.0
;; Keywords: pdf, pdf-tools, convenience 
;; URL: https://github.com/MirkoHernandez/pdf-view-save-hscroll
;; Package-Requires: ((emacs "27.1") (pdf-tools "1.0.0"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This packages  provides a  minor mode that  saves and  restores the
;; horizontal scroll position of pages of a PDF document.

(defvar pdf-view-save-hscroll-directory (expand-file-name "pdf-view-save-hscroll" user-emacs-directory))
(defvar pdf-view-save-hscroll-file (expand-file-name "hscroll-table" pdf-view-save-hscroll-directory))

(defvar pdf-view-save-hscroll-table nil
  "Table that stores  the hscroll values. For each key  (the document name)
the value should be a hash table (page as key and hscroll as value).")

(defun pdf-view-save-hscroll-table-to-file ()
 "Save the content of `pdf-view-save-hscroll-table' to the file specified by `pdf-view-save-hscroll-file'" 
  (with-temp-file pdf-view-save-hscroll-file
    (prin1 pdf-view-save-hscroll-table (current-buffer))))

(defun pdf-view-save-hscroll-load ()
  "Set     `pdf-view-save-hscroll-table'     to      the     content     of
`pdf-view-save-hscroll-file', or (if the file is empty) to a new hash table"
  (let ((directory (file-name-directory pdf-view-save-hscroll-file)))
    (unless (file-exists-p  directory)
      (mkdir directory)))
  (unless (file-exists-p pdf-view-save-hscroll-file)
    (make-empty-file pdf-view-save-hscroll-file))
  (let* ((file-contents (with-temp-buffer 
			  (insert-file-contents pdf-view-save-hscroll-file)
			  (buffer-string)))
	 (table (and file-contents
		     (not (string-empty-p file-contents))
		     t
		     (read file-contents))))
    (if table
	(setq pdf-view-save-hscroll-table table) 
      (setq pdf-view-save-hscroll-table
	    (make-hash-table :size 1024 :test 'equal)))))


;; NOTE: arg  is used here so that `advice-add' works.
(defun pdf-save-hscroll-save (&optional arg)
  "Save the horizontal scroll value associated with the page of the current
PDF document." 
  (let* ((document (buffer-name))
	 (pages-scroll-table (or (gethash document pdf-view-save-hscroll-table)
				 (puthash document
					  (make-hash-table :size 2048 :test 'equal)
					  pdf-view-save-hscroll-table))))
    (puthash (pdf-view-current-page)
	     (window-hscroll)
	     pages-scroll-table))
  (pdf-view-save-hscroll-table-to-file))

(defun pdf-save-hscroll-restore (&optional arg)
 "Restore window hscroll value associated with the current page." 
  (let* ((document (buffer-name))
	 (pages-scroll-table (gethash document pdf-view-save-hscroll-table))
	 (hscroll (and pages-scroll-table
		       (gethash (pdf-view-current-page) pages-scroll-table))))
	 (when (and hscroll (>= hscroll 0))
	   (image-set-window-hscroll hscroll))))

;;;###autoload
(define-minor-mode pdf-view-save-hscroll
  "pdf-view-save-hscroll" 
  :init-value nil
  :group 'pdf-view-save-hscroll
  (if pdf-view-save-hscroll
      (progn
	(pdf-view-save-hscroll-load)
        (advice-add 'image-forward-hscroll :after 'pdf-save-hscroll-save)
        (advice-add 'image-backward-hscroll :after 'pdf-save-hscroll-save)
        (advice-add 'pdf-view-next-page :after 'pdf-save-hscroll-restore)
        (advice-add 'pdf-view-previous-page :after 'pdf-save-hscroll-restore)
        (advice-add 'pdf-view-next-line-or-next-page :after 'pdf-save-hscroll-restore)
	(advice-add 'pdf-view-previous-line-or-previous-page :after 'pdf-save-hscroll-restore))
    (progn
      (advice-remove 'image-forward-hscroll #'pdf-save-hscroll-save)
      (advice-remove 'image-backward-hscroll #'pdf-save-hscroll-save)
      (advice-remove 'pdf-view-next-page #'pdf-save-hscroll-restore)
      (advice-remove 'pdf-view-previous-page #'pdf-save-hscroll-restore)
      (advice-remove 'pdf-view-next-line-or-next-page #'pdf-save-hscroll-restore)
      (advice-remove 'pdf-view-previous-line-or-previous-page #'pdf-save-hscroll-restore))))

(provide 'pdf-view-save-hscroll)
;;; pdf-view-save-hscroll.el ends here
