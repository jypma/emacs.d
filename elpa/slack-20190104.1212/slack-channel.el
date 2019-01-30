;;; slack-channel.el ---slack channel implement      -*- lexical-binding: t; -*-

;; Copyright (C) 2015  yuya.minami

;; Author: yuya.minami <yuya.minami@yuyaminami-no-MacBook-Pro.local>
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
(require 'slack-room)
(require 'slack-group)
(require 'slack-buffer)
(require 'slack-util)
(require 'slack-request)
(require 'slack-conversations)

(defvar slack-buffer-function)
(defvar slack-completing-read-function)

(defconst slack-channel-buffer-name "*Slack - Channel*")
(defconst slack-channel-update-mark-url "https://slack.com/api/channels.mark")

(defclass slack-channel (slack-group)
  ((is-member :initarg :is_member :initform nil)
   (num-members :initarg :num_members :initform 0)))

(cl-defmethod slack-merge ((this slack-channel) other)
  (cl-call-next-method)
  (with-slots (is-member num-members) this
    (setq is-member (oref other is-member))
    (setq num-members (oref other num-members))))

(cl-defmethod slack-room-buffer-name ((room slack-channel) team)
  (concat slack-channel-buffer-name
          " : "
          (slack-room-display-name room team)))

(defun slack-channel-names (team &optional filter)
  (with-slots (channels) team
    (slack-room-names channels team filter)))

(cl-defmethod slack-room-member-p ((room slack-channel))
  (oref room is-member))

(defun slack-channel-list-update (&optional team after-success)
  (interactive)
  (let ((team (or team (slack-team-select))))
    (cl-labels
        ((success (channels _groups _ims)
                  (slack-merge-list (oref team channels)
                                    channels)
                  (when (functionp after-success)
                    (funcall after-success team))
                  (mapc #'(lambda (room)
                            (slack-request-worker-push
                             (slack-conversations-info-request room team)))
                        (oref team channels))
                  (slack-log "Slack Channel List Updated"
                             team :level 'info)))
      (slack-conversations-list team #'success (list "public_channel")))))

(cl-defmethod slack-room-update-mark-url ((_room slack-channel))
  slack-channel-update-mark-url)

(defun slack-create-channel ()
  (interactive)
  (let ((team (slack-team-select)))
    (slack-conversations-create team "false")))

(defun slack-channel-rename ()
  (interactive)
  (let* ((team (slack-team-select))
         (room (slack-current-room-or-select
                (slack-channel-names team #'(lambda (channels)
                                              (cl-remove-if #'slack-room-member-p
                                                            channels))))))
    (slack-conversations-rename room team)))

(defun slack-channel-invite ()
  (interactive)
  (let* ((team (slack-team-select))
         (room (slack-current-room-or-select
                (slack-channel-names team
                                     #'(lambda (rooms)
                                         (cl-remove-if #'slack-room-archived-p
                                                       rooms))))))
    (slack-conversations-invite room team)))

(defun slack-channel-leave (&optional team)
  (interactive)
  (let* ((team (or team (slack-team-select)))
         (channel (slack-current-room-or-select
                   (slack-channel-names
                    team
                    #'(lambda (channels)
                        (cl-remove-if-not #'slack-room-member-p
                                          channels))))))
    (slack-conversations-leave channel team)))

(defun slack-channel-join (&optional team)
  (interactive)
  (cl-labels
      ((filter-channel (channels)
                       (cl-remove-if
                        #'(lambda (c)
                            (or (slack-room-member-p c)
                                (slack-room-archived-p c)))
                        channels)))
    (let* ((team (or team (slack-team-select)))
           (channel (slack-current-room-or-select
                     (slack-channel-names team
                                          #'filter-channel))))
      (slack-conversations-join channel team))))

(defun slack-channel-archive ()
  "Archive selected channel."
  (interactive)
  (let* ((team (slack-team-select))
         (channel (slack-current-room-or-select
                   #'(lambda ()
                       (slack-channel-names
                        team
                        #'(lambda (channels)
                            (cl-remove-if #'slack-room-archived-p
                                          channels)))))))
    (slack-conversations-archive channel team)))

(defun slack-channel-unarchive ()
  "Unarchive selected channel."
  (interactive)
  (let* ((team (slack-team-select))
         (channel (slack-current-room-or-select
                   #'(lambda ()
                       (slack-channel-names
                        team
                        #'(lambda (channels)
                            (cl-remove-if-not #'slack-room-archived-p
                                              channels)))))))
    (slack-conversations-unarchive channel team)))

(cl-defmethod slack-room-subscribedp ((room slack-channel) team)
  (with-slots (subscribed-channels) team
    (let ((name (slack-room-name room team)))
      (and name
           (memq (intern name) subscribed-channels)))))

(cl-defmethod slack-room-hidden-p ((room slack-channel))
  (slack-room-archived-p room))

(cl-defmethod slack-room-member-p ((this slack-channel))
  (oref this is-member))

(provide 'slack-channel)
;;; slack-channel.el ends here
