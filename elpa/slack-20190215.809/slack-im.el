;;; slack-im.el ---slack direct message interface    -*- lexical-binding: t; -*-

;; Copyright (C) 2015  南優也

;; Author: 南優也 <yuyaminami@minamiyuunari-no-MacBook-Pro.local>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'eieio)
(require 'slack-util)
(require 'slack-room)
(require 'slack-buffer)
(require 'slack-user)
(require 'slack-request)
(require 'slack-conversations)

(defvar slack-buffer-function)
(defvar slack-display-team-name)
(defvar slack-completing-read-function)

(defconst slack-im-buffer-name "*Slack - Direct Messages*")
(defconst slack-im-update-mark-url "https://slack.com/api/im.mark")

(defclass slack-im (slack-room)
  ((user :initarg :user :initform "")
   (is-open :initarg :is_open :initform t)
   (is-user-deleted :initarg :is_user_deleted :initform nil)))

(cl-defmethod slack-merge ((this slack-im) other)
  (cl-call-next-method)
  (with-slots (user is-open) this
    (setq user (oref other user))
    (setq is-open (oref other is-open))))

(cl-defmethod slack-room-open-p ((room slack-im))
  (oref room is-open)
  (not (oref room is-user-deleted)))

(cl-defmethod slack-im-user-presence ((room slack-im) team)
  (slack-user-presence-to-string (slack-user-find room team)))

(cl-defmethod slack-im-user-dnd-status ((room slack-im) team)
  (slack-user-dnd-status-to-string (slack-user-find room
                                                    team)))

(cl-defmethod slack-room-name ((room slack-im) team)
  (with-slots (user) room
    (slack-user-name user team)))

(cl-defmethod slack-room-display-name ((room slack-im) team)
  "To Display emoji in minibuffer configure `emojify-inhibit-in-buffer-functions'"
  (let* ((status (slack-user-status (oref room user) team))
         (room-name (or (and status
                             (format "%s %s"
                                     (slack-room-name room team)
                                     status))
                        (slack-room-name room team))))
    (if slack-display-team-name
        (format "%s - %s"
                (slack-team-name team)
                room-name)
      room-name)))

(defun slack-im-user-name (im team)
  (with-slots (user) im
    (slack-user-name user team)))

(defun slack-im-names (team)
  (cl-labels
      ((filter (ims)
               (cl-remove-if #'(lambda (im) (not (oref im is-open)))
                             ims)))
    (slack-room-names (oref team ims)
                      team
                      #'filter)))

(cl-defmethod slack-room-buffer-name ((room slack-im) team)
  (concat slack-im-buffer-name
          " : "
          (slack-room-display-name room team)))

(defun slack-im-list-update (&optional team after-success)
  (interactive)
  (let ((team (or team (slack-team-select))))
    (cl-labels
        ((success (_channels _groups ims)
                  (slack-merge-list (oref team ims)
                                    ims)
                  (when (functionp after-success)
                    (funcall after-success team))
                  (mapc #'(lambda (room)
                            (slack-request-worker-push
                             (slack-conversations-info-request room team)))
                        (oref team ims))
                  (slack-log "Slack Im List Updated"
                             team :level 'info)
                  (slack-team-send-presence-sub team)))
      (slack-conversations-list team #'success (list "im")))))

(cl-defmethod slack-room-update-mark-url ((_room slack-im))
  slack-im-update-mark-url)

(defun slack-im-close ()
  "Close direct message."
  (interactive)
  (let* ((team (slack-team-select))
         (im (slack-current-room-or-select
              #'(lambda ()
                  (cl-remove-if #'(lambda (im-names)
                                    (not (oref (cdr im-names) is-open)))
                                (slack-im-names team))))))
    (slack-conversations-close im team)))

(defun slack-im-open ()
  (interactive)
  (let* ((team (slack-team-select))
         (user (slack-select-from-list
                   ((slack-user-name-alist
                     team
                     :filter #'(lambda (users)
                                 (cl-remove-if #'slack-user-hidden-p users)))
                    "Select User: "))))
    (slack-conversations-open team
                              :user-ids (list (plist-get user :id)))))

(cl-defmethod slack-room-label-prefix ((room slack-im) team)
  (format "%s "
          (or
           (slack-im-user-dnd-status room team)
           (slack-im-user-presence room team))))

(cl-defmethod slack-room-get-members ((room slack-im))
  (list (oref room user)))

(defun slack-im-find-by-user-id (user-id team)
  (cl-find-if #'(lambda (im) (string= user-id (oref im user)))
              (oref team ims)))

(provide 'slack-im)
;;; slack-im.el ends here
