;;; lib-brb-event.el --- Barberry Garden event-related helpers -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2015-2022, Boris Buliga <boris@d12frosted.io>
;;
;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;;
;; Created: 29 Sep 2022
;;
;; URL: https://github.com/d12frosted/environment/tree/master/emacs
;;
;; License: GPLv3
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see
;; <http://www.gnu.org/licenses/>.
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;; Code:

(require 'org-ml)

(defun brb-event-select ()
  "Interactively select an event note."
  (let* ((tags '("wine" "event"))
         (event (when (and (eq major-mode 'org-mode)
                           (buffer-file-name))
                  (let* ((id (save-excursion
                               (goto-char (point-min))
                               (org-id-get)))
                         (note (vulpea-db-get-by-id id)))
                    (when (--every-p (-contains-p (vulpea-note-tags note) it) tags)
                      note)))))
    (vulpea-select-from
     "Event"
     (vulpea-db-query-by-tags-every tags)
     :require-match t
     :initial-prompt (when event (vulpea-note-title event)))))

(defun brb-event-wines (event)
  "Return list of wines from EVENT."
  (vulpea-utils-with-note event
    (let ((bound (save-excursion
                   (goto-char (point-min))
                   (re-search-forward org-heading-regexp)
                   (beginning-of-line)
                   (point))))
      (save-excursion
        (goto-char (point-min))
        (when (search-forward "1. " bound 'no-error)
          (beginning-of-line)
          (->> (org-ml-parse-element-at (point))
               (org-ml-get-children)
               (-map #'org-ml-item-get-paragraph)
               (-map #'car)
               (--map (org-ml-get-property :path it))
               (vulpea-db-query-by-ids)
               (--remove (vulpea-note-primary-title it))))))))

(defun brb-event-participants (event)
  "Return list of participants from EVENT."
  (vulpea-utils-with-note event
    (save-excursion
      (goto-char (point-min))
      (re-search-forward (format org-complex-heading-regexp-format (regexp-quote "Preparation")))
      (search-forward "1. ")
      (beginning-of-line)
      (->> (org-ml-parse-element-at (point))
           (org-ml-get-children)
           (-map #'org-ml-item-get-paragraph)
           (-map #'car)
           (--map (org-ml-get-property :path it))
           (vulpea-db-query-by-ids)
           (--remove (vulpea-note-primary-title it))))))

(provide 'lib-brb-event)
;;; lib-brb-event.el ends here