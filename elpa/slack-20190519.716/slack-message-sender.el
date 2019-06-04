;;; slack-message-sender.el --- slack message concern message sending  -*- lexical-binding: t; -*-

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
(require 'json)
(require 'slack-util)
(require 'slack-room)
(require 'slack-im)
(require 'slack-group)
(require 'slack-message)
(require 'slack-channel)
(require 'slack-conversations)
(require 'slack-buffer)
(require 'slack-usergroup)

(defvar slack-completing-read-function)
(defvar slack-buffer-function)

(defun slack-escape-message (message)
  "Escape '<,' '>' & '&' in MESSAGE."
  (replace-regexp-in-string
   ">" "&gt;"
   (replace-regexp-in-string
    "<" "&lt;"
    (replace-regexp-in-string "&" "&amp;" message))))

(defun slack-link-users (message team)
  "Add links to all references to valid users in MESSAGE."
  (replace-regexp-in-string
   "@\\<\\([A-Za-z0-9._\-]+\\)\\>"
   #'(lambda (text)
       (let ((id (match-string 1 text)))
         (slack-if-let* ((user (slack-user--find id team))
                         (username (slack-user--name user team)))
             (format "<@%s>" id)
           (slack-if-let* ((group (slack-usergroup-find id team)))
               (format "<!subteam^%s>" id)
             (cond
              ((string= id "here") "<!here>")
              ((cl-find id '("channel" "group") :test #'string=) "<!channel>")
              ((string= id "everyone") "<!everyone>")
              (t text))))))
   message t))

(defun slack-link-channels (message team)
  "Add links to all references to valid channels in MESSAGE."
  (let ((channel-ids
         (mapcar #'(lambda (x)
                     (let ((channel (cdr x)))
                       (cons (slack-room-name channel team)
                             (slot-value channel 'id))))
                 (slack-channel-names team))))
    (replace-regexp-in-string
     "#\\<\\([A-Za-z0-9_\-]+\\)\\>"
     #'(lambda (text)
         (let* ((channel (match-string 1 text))
                (id (cdr (assoc channel channel-ids))))
           (if id
               (format "<#%s|%s>" id channel)
             text)))
     message t)))

(defun slack-message-prepare-links (message team)
  (slack-link-channels (slack-link-users message team) team))

(defun slack-message-send-internal (message room team)
  (if (and (slack-channel-p room)
           (not (oref room is-member)))
      (slack-conversations-join
       room team
       #'(lambda (_data) (slack-message-send-internal message
                                                      room
                                                      team)))
    (with-slots (message-id self-id) team
      (let* ((channel-id (oref room id))
             (m (list :id message-id
                      :channel channel-id
                      :type "message"
                      :user self-id
                      :text (slack-message-prepare-links
                             (slack-escape-message message)
                             team))))
        (slack-team-send-message team m)))))

(defun slack-message-read-room (team)
  (let* ((list (slack-message-room-list team))
         (choices (mapcar #'car list))
         (room-name (slack-message-read-room-list "Select Room: " choices))
         (room (cdr (cl-assoc room-name list :test #'string=))))
    room))

(defun slack-message-read-room-list (prompt choices)
  (let ((completion-ignore-case t))
    (funcall slack-completing-read-function (format "%s" prompt)
             choices nil t nil nil choices)))

(defun slack-message-room-list (team)
  (append (slack-group-names team)
          (slack-im-names team)
          (slack-channel-names team)))

(defun slack-message-embed-channel ()
  (interactive)
  (slack-if-let* ((buf slack-current-buffer))
      (with-slots (team) buf
        (slack-select-from-list
            ((slack-channel-names team) "Select Channel: ")
            (insert (concat "#" (slack-room-name selected team)))))))

(defun slack-message-embed-mention ()
  (interactive)
  (slack-if-let* ((buf slack-current-buffer))
      (with-slots (team) buf
        (let* ((keyworkds (list (list "here" :name "here" :type 'keyword)
                                (list "channel" :name "channel" :type 'keyword)
                                (list "everyone" :name "everyone" :type 'keyword)))
               (usergroups (mapcar #'(lambda (e) (list (oref e handle)
                                                       :name (oref e handle)
                                                       :type 'usergroup))
                                   (cl-remove-if #'slack-usergroup-deleted-p
                                                 (oref team usergroups))))
               (alist (append keyworkds (slack-user-names team) usergroups)))
          (slack-select-from-list
              (alist "Select User: ")
              (cl-case (plist-get selected :type)
                (keyword
                 (insert (concat (propertize (concat "@" (plist-get selected :name))
                                             'rear-nonsticky t
                                             'face 'slack-message-mention-keyword-face)
                                 " ")))
                (usergroup
                 (insert (concat (propertize (concat "@" (plist-get selected :id))
                                             'rear-nonsticky t
                                             'face 'slack-message-mention-keyword-face)
                                 " ")))
                (t
                 (insert (concat (propertize (concat "@" (plist-get selected :id))
                                             'rear-nonsticky t
                                             'display (concat "@" (slack-user--name
                                                                   selected team))
                                             'face 'slack-message-mention-face)
                                 " ")))))))))

(provide 'slack-message-sender)
;;; slack-message-sender.el ends here
