;;; slack-websocket.el --- slack websocket interface  -*- lexical-binding: t; -*-

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
(require 'websocket)
(require 'slack-util)
(require 'slack-request)
(require 'slack-team)
(require 'slack-team-ws)
(require 'slack-reply)
(require 'slack-file)
(require 'slack-dialog-buffer)
(require 'slack-user)
(require 'slack-group)
(require 'slack-channel)
(require 'slack-im)
(require 'slack-thread)
(require 'slack-bot)
(require 'slack-usergroup)
(require 'slack-slash-commands)
(require 'slack-star)
(require 'slack-message-notification)
;; (require 'slack-message-buffer)
(declare-function slack-buffer-load-missing-messages "slack-message-buffer")
(require 'slack-room-buffer)
(require 'slack-authorize)
(require 'slack-typing)
(require 'slack-stars-buffer)
(require 'slack-conversations)

(defconst slack-api-test-url "https://slack.com/api/api.test")

(cl-defmethod slack-ws-open ((ws slack-team-ws) team &key (on-open nil) (ws-url nil))
  (slack-if-let* ((conn (oref ws conn))
                  (state (websocket-ready-state conn)))
      (cond ((websocket-openp conn)
             (slack-log "Websocket is Already Open" team))
            ((eq state 'connecting)
             (slack-log "Websocket is connecting" team))
            ((eq state 'closed)
             (slack-log "Websocket is closed" team)))

    (progn
      (cl-labels
          ((on-timeout ()
                       (slack-log (format "websocket open timeout")
                                  team)
                       (slack-ws--close ws team)
                       (slack-ws-reconnect ws team)))
        (slack-ws-set-connect-timeout-timer ws #'on-timeout))

      (cl-labels
          ((on-message (_websocket frame)
                       (slack-ws-on-message ws frame team))
           (handle-on-open (_websocket)
                           (oset ws reconnect-count 0)
                           (oset ws connected t)
                           (slack-log "WebSocket on-open"
                                      team :level 'debug)
                           (when (functionp on-open)
                             (funcall on-open)))
           (on-close (websocket)
                     (oset ws conn nil)
                     (oset ws connected nil)
                     (slack-log (format "Websocket on-close: STATE: %s"
                                        (websocket-ready-state websocket))
                                team :level 'debug)
                     (unwind-protect
                         (progn
                           (unless (oref ws inhibit-reconnection)
                             (slack-ws-reconnect ws team)))
                       (oset ws inhibit-reconnection nil)))
           (on-error (_websocket type err)
                     (slack-log (format "Error on `websocket-open'. TYPE: %s, ERR: %s"
                                        type err)
                                team
                                :level 'error)))
        (oset ws conn
              (condition-case error-var
                  (websocket-open (or ws-url (oref ws url))
                                  :on-message #'on-message
                                  :on-open #'handle-on-open
                                  :on-close #'on-close
                                  :on-error #'on-error
                                  :nowait (oref ws nowait))
                (error
                 (slack-ws-cancel-connect-timeout-timer ws)
                 (slack-ws--close ws team)
                 (slack-log (format (concat "An Error occured while "
                                            "opening websocket connection: %s")
                                    error-var)
                            team
                            :level 'error)
                 nil)))))))

(defun slack-ws-close ()
  (interactive)
  (mapc #'(lambda (team) (slack-ws--close (oref team ws) team t))
        slack-teams)
  (slack-request-worker-quit))

(cl-defun slack-ws--close (ws team &optional (close-reconnection nil))
  (cl-labels
      ((close (ws team)
              (slack-ws-cancel-ping-timer ws)
              (slack-ws-cancel-ping-check-timers ws)
              (when close-reconnection
                (slack-ws-cancel-reconnect-timer ws)
                (oset ws inhibit-reconnection t))
              (with-slots (connected conn last-pong) ws
                (when conn
                  (websocket-close conn)
                  (slack-log "Slack Websocket Closed" team)))))
    (close ws team)
    (slack-request-worker-remove-request team)))

(defun slack-ws-payload-ping-p (payload)
  (string= "ping" (plist-get payload :type)))

(defun slack-ws-payload-presence-sub-p (payload)
  (string= "presence_sub" (plist-get payload :type)))

(defun slack-ws-retryable-payload-p (payload)
  (and (not (slack-ws-payload-ping-p payload))
       (not (slack-ws-payload-presence-sub-p payload))))

(cl-defmethod slack-ws-send ((ws slack-team-ws) payload team)
  (slack-log-websocket-payload payload team t)
  (with-slots (waiting-send conn) ws
    (when (slack-ws-retryable-payload-p payload)
      (push payload waiting-send))
    (cl-labels
        ((reconnect ()
                    (slack-ws--close ws team)
                    (slack-ws-reconnect ws team)))
      (if (websocket-openp conn)
          (condition-case err
              (websocket-send-text conn (json-encode payload))
            (error
             (slack-log (format "Error in `slack-ws-send`: %s" err)
                        team :level 'debug)
             (reconnect)))
        (reconnect)))))

(cl-defmethod slack-ws-resend ((ws slack-team-ws) team)
  (with-slots (waiting-send) ws
    (let ((candidate waiting-send))
      (setq waiting-send nil)
      (cl-loop for msg in candidate
               do (slack-ws-send ws msg team)))))

(cl-defmethod slack-ws-ping ((ws slack-team-ws) team)
  (with-slots (message-id) team
    (let* ((time (number-to-string (time-to-seconds (current-time))))
           (m (list :id message-id
                    :type "ping"
                    :time time)))
      (cl-labels
          ((on-timeout ()
                       (slack-log "Slack Websocket PING Timeout." team :level 'warn)
                       (slack-ws--close ws team)
                       (slack-ws-reconnect ws team)))
        (slack-ws-set-ping-check-timer ws time #'on-timeout))
      (slack-team-send-message team m)
      (slack-log (format "Send PING: %s" time)
                 team :level 'trace))))

(defvar slack-disconnected-timer nil)
(defun slack-notify-abandon-reconnect (team)
  (unless slack-disconnected-timer
    (setq slack-disconnected-timer
          (run-with-idle-timer 5 t
                               #'(lambda ()
                                   (slack-log
                                    "Reconnect Count Exceeded. Manually invoke `slack-start'."
                                    team :level 'error))))))

(defun slack-cancel-notify-adandon-reconnect ()
  (if (and slack-disconnected-timer
           (timerp slack-disconnected-timer))
      (progn
        (cancel-timer slack-disconnected-timer)
        (setq slack-disconnected-timer nil))))

(defun slack-request-api-test (team &optional after-success)
  (cl-labels
      ((on-success (&key data &allow-other-keys)
                   (slack-request-handle-error
                    (data "slack-request-api-test")
                    (if after-success
                        (funcall after-success)))))
    (slack-request
     (slack-request-create
      slack-api-test-url
      team
      :type "POST"
      :success #'on-success))))

(cl-defmethod slack-ws--reconnect ((ws slack-team-ws) team &optional force)
  (cl-labels ((abort ()
                     (slack-notify-abandon-reconnect team)
                     (slack-ws--close ws team t))
              (use-reconnect-url ()
                                 (slack-log "Reconnect with reconnect-url" team)
                                 (slack-ws-open ws team
                                                :ws-url (oref ws reconnect-url)))
              (on-authorize-error (&key error-thrown symbol-status &allow-other-keys)
                                  (slack-log (format "Reconnect Failed: %s, %s"
                                                     error-thrown
                                                     symbol-status)
                                             team)
                                  (slack-ws-reconnect ws team))
              (on-open ()
                       (slack-conversations-list-update team)
                       ;; (slack-user-list-update team)
                       (cl-loop for buffer in (oref team slack-message-buffer)
                                do (slack-if-let*
                                       ((live-p (buffer-live-p buffer))
                                        (buffer (with-current-buffer buffer
                                                  (and (bound-and-true-p
                                                        slack-current-buffer)
                                                       slack-current-buffer))))
                                       (slack-buffer-load-missing-messages buffer)))
                       (slack-team-kill-buffers
                        team :except '(slack-message-buffer
                                       slack-message-edit-buffer
                                       slack-message-share-buffer
                                       slack-room-message-compose-buffer)))
              (on-authorize-success (data)
                                    (let ((team-data (plist-get data :team))
                                          (self-data (plist-get data :self)))
                                      (slack-team-set-ws-url team (plist-get data :url))
                                      (oset team domain (plist-get team-data :domain))
                                      (oset team id (plist-get team-data :id))
                                      (oset team name (plist-get team-data :name))
                                      (oset team self self-data)
                                      (oset team self-id (plist-get self-data :id))
                                      (oset team self-name (plist-get self-data :name))
                                      (slack-ws-open ws team :on-open #'on-open)))
              (do-reconnect ()
                            (slack-ws-inc-reconnect-count ws)
                            (slack-ws--close ws team)
                            (if (slack-ws-use-reconnect-url-p ws)
                                (slack-request-api-test team #'use-reconnect-url)
                              (slack-authorize team
                                               #'on-authorize-error
                                               #'on-authorize-success))
                            (slack-log (format "Reconnecting... [%s/%s]"
                                               (oref ws reconnect-count)
                                               (oref ws reconnect-count-max))
                                       team
                                       :level 'warn)))
    (if (and (not force)
             (slack-ws-reconnect-count-exceed-p ws))
        (abort)
      (do-reconnect))))

(cl-defmethod slack-ws-reconnect ((ws slack-team-ws) team &optional force)
  "Reconnect if `reconnect-count' is not exceed `reconnect-count-max'.
if FORCE is t, ignore `reconnect-count-max'.
TEAM is one of `slack-teams'"
  (slack-ws-set-reconnect-timer ws #'slack-ws--reconnect ws team force))

;; Message handler

(cl-defmethod slack-ws-handle-pong ((ws slack-team-ws) payload team)
  (slack-ws-remove-from-resend-queue ws payload team)
  (let* ((key (plist-get payload :time))
         (timer (gethash key (oref ws ping-check-timers))))
    (slack-log (format "Receive PONG: %s" key)
               team :level 'trace)
    (slack-ws-set-ping-timer ws #'slack-ws-ping ws team)
    (when timer
      (cancel-timer timer)
      (remhash key (oref ws ping-check-timers))
      (slack-log (format "Remove PING Check Timer: %s" key)
                 team :level 'trace))))

;; (:type error :error (:msg Socket URL has expired :code 1))
(cl-defmethod slack-ws-handle-error ((ws slack-team-ws) payload team)
  (let* ((err (plist-get payload :error))
         (code (plist-get err :code)))
    (cond
     ((eq 1 code)
      (slack-ws--close ws team)
      (slack-ws-reconnect ws team))
     (t (slack-log (format "Unknown Error: %s, MSG: %s"
                           code (plist-get err :msg))
                   team)))))

(cl-defmethod slack-ws-on-message ((ws slack-team-ws) frame team)
  ;; (message "%s" (slack-request-parse-payload
  ;;                (websocket-frame-payload frame)))
  (when (websocket-frame-completep frame)
    (let* ((payload (slack-request-parse-payload
                     (websocket-frame-payload frame)))
           (decoded-payload (and payload (slack-decode payload)))
           (type (and decoded-payload
                      (plist-get decoded-payload :type))))
      ;; (message "%s" decoded-payload)
      (when (slack-team-event-log-enabledp team)
        (slack-log-websocket-payload decoded-payload team))
      (when decoded-payload
        (cond
         ((string= type "error")
          (slack-ws-handle-error ws decoded-payload team))
         ((string= type "pong")
          (slack-ws-handle-pong ws decoded-payload team))
         ((string= type "hello")
          (slack-ws-cancel-connect-timeout-timer ws)
          (slack-ws-cancel-reconnect-timer ws)
          (slack-cancel-notify-adandon-reconnect)
          (slack-ws-set-ping-timer ws #'slack-ws-ping ws team)
          (slack-ws-resend ws team)
          (slack-log "Slack Websocket Is Ready!" team :level 'info))
         ((plist-get decoded-payload :reply_to)
          (slack-ws-handle-reply ws decoded-payload team))
         ((string= type "message")
          (slack-ws-handle-message decoded-payload team))
         ((string= type "reaction_added")
          (slack-ws-handle-reaction-added decoded-payload team))
         ((string= type "reaction_removed")
          (slack-ws-handle-reaction-removed decoded-payload team))
         ((string= type "channel_created")
          (slack-ws-handle-channel-created decoded-payload team))
         ((or (string= type "channel_archive")
              (string= type "group_archive"))
          (slack-ws-handle-room-archive decoded-payload team))
         ((or (string= type "channel_unarchive")
              (string= type "group_unarchive"))
          (slack-ws-handle-room-unarchive decoded-payload team))
         ((string= type "channel_deleted")
          (slack-ws-handle-channel-deleted decoded-payload team))
         ((or (string= type "channel_rename")
              (string= type "group_rename"))
          (slack-ws-handle-room-rename decoded-payload team))
         ((or (string= type "channel_left")
              (string= type "group_left"))
          (slack-ws-handle-room-left decoded-payload team))
         ((string= type "channel_joined")
          (slack-ws-handle-channel-joined decoded-payload team))
         ((string= type "group_joined")
          (slack-ws-handle-group-joined decoded-payload team))
         ((string= type "presence_change")
          (slack-ws-handle-presence-change decoded-payload team))
         ((or (string= type "bot_added")
              (string= type "bot_changed"))
          (slack-ws-handle-bot decoded-payload team))
         ((string= type "file_created")
          (slack-ws-handle-file-created decoded-payload team))
         ((or (string= type "file_deleted")
              (string= type "file_unshared"))
          (slack-ws-handle-file-deleted decoded-payload team))
         ((or (string= type "im_marked")
              (string= type "channel_marked")
              (string= type "group_marked"))
          (slack-ws-handle-room-marked decoded-payload team))
         ((string= type "thread_marked")
          (slack-ws-handle-thread-marked decoded-payload team))
         ((string= type "thread_subscribed")
          (slack-ws-handle-thread-subscribed decoded-payload team))
         ((string= type "im_open")
          (slack-ws-handle-im-open decoded-payload team))
         ((or (string= type "im_close")
              (string= type "group_close"))
          (slack-ws-handle-close decoded-payload team))
         ((string= type "team_join")
          (slack-ws-handle-team-join decoded-payload team))
         ((string= type "user_typing")
          (slack-ws-handle-user-typing decoded-payload team))
         ((string= type "user_change")
          (slack-ws-handle-user-change decoded-payload team))
         ((string= type "member_joined_channel")
          (slack-ws-handle-member-joined-channel decoded-payload team))
         ((string= type "member_left_channel")
          (slack-ws-handle-member-left_channel decoded-payload team))
         ((or (string= type "dnd_updated")
              (string= type "dnd_updated_user"))
          (slack-ws-handle-dnd-updated decoded-payload team))
         ((string= type "star_added")
          (slack-ws-handle-star-added decoded-payload team))
         ((string= type "star_removed")
          (slack-ws-handle-star-removed decoded-payload team))
         ((string= type "reconnect_url")
          (slack-ws-handle-reconnect-url ws decoded-payload team))
         ((string= type "app_conversation_invite_request")
          (slack-ws-handle-app-conversation-invite-request decoded-payload team))
         ((string= type "commands_changed")
          (slack-ws-handle-commands-changed decoded-payload team))
         ((string= type "dialog_opened")
          (slack-ws-handle-dialog-opened decoded-payload team))
         ((string= type "subteam_created")
          (slack-ws-handle-subteam-created decoded-payload team))
         ((string= type "subteam_updated")
          (slack-ws-handle-subteam-updated decoded-payload team))
         ((string= type "pin_removed")
          (slack-ws-handle-pin-removed decoded-payload team))
         ((string= type "pin_added")
          (slack-ws-handle-pin-added decoded-payload team))
         )))))

(defun slack-ws-handle-pin-added (payload team)
  (let* ((item (plist-get payload :item))
         (message (plist-get item :message))
         (ts (plist-get message :ts))
         (channel-id (plist-get payload :channel_id)))
    (slack-if-let*
        ((room (slack-room-find channel-id team))
         (message (slack-room-find-message room ts)))
        (cl-pushnew channel-id (oref message pinned-to)
                    :test #'string=))))

(defun slack-ws-handle-pin-removed (payload team)
  (let* ((item (plist-get payload :item))
         (message (plist-get item :message))
         (ts (plist-get message :ts))
         (channel-id (plist-get payload :channel_id)))
    (slack-if-let*
        ((room (slack-room-find channel-id team))
         (message (slack-room-find-message room ts)))
        (oset message pinned-to (cl-remove-if #'(lambda (e) (string= channel-id e))
                                              (oref message pinned-to))))))

(cl-defmethod slack-ws-handle-reconnect-url ((ws slack-team-ws) payload)
  (oset ws reconnect-url (plist-get payload :url)))

(defun slack-ws-handle-user-typing (payload team)
  (slack-if-let*
      ((user-id (plist-get payload :user))
       (room (slack-room-find (plist-get payload :channel) team))
       (buf (slack-buffer-find 'slack-message-buffer room team))
       (show-typing-p (slack-buffer-show-typing-p (get-buffer
                                                   (slack-buffer-name buf)))))
      (cl-labels
          ((update-typing (user)
                          (let ((limit (+ 3 (float-time))))
                            (with-slots (typing typing-timer) team
                              (if (and typing
                                       (string= (oref room id) (oref (oref typing room) id)))
                                  (progn
                                    (slack-typing-set-limit typing limit)
                                    (slack-typing-add-user typing user limit))
                                (setq typing (slack-typing-create room limit user))
                                (setq typing-timer
                                      (run-with-timer t 1 #'slack-typing-display team)))))))
        (slack-if-let*
            ((user (slack-user-name user-id team)))
            (update-typing user)
          (slack-user-info-request
           user-id team
           :after-success
           #'(lambda ()
               (update-typing (slack-user-name user-id team))))))))

(defun slack-ws-handle-team-join (payload team)
  (let ((user (slack-decode (plist-get payload :user))))
    (cl-labels
        ((after-success ()
                        (let ((user-id (plist-get user :id)))
                          (slack-log (format "User %s Joind Team: %s"
                                             (slack-user-name user-id team)
                                             (slack-team-name team))
                                     team
                                     :level 'info))))
      (slack-user-info-request (plist-get user :id)
                               team
                               :after-success #'after-success))))

(defun slack-ws-handle-im-open (payload team)
  (let* ((channel-id (plist-get payload :channel))
         (im (slack-room-find channel-id team)))
    (cl-labels
        ((notify (im)
                 (slack-log (format "Open direct message with %s"
                                    (slack-user-name (oref im user)
                                                     team))
                            team :level 'info))
         (update (im)
                 (slack-conversations-info im team
                                           #'(lambda ()
                                               (notify im)))))
      (unless im
        (setq im (slack-room-create
                  (list :id (plist-get payload :channel)
                        :user (plist-get payload :user))
                  'slack-im))
        (push im (oref team ims)))
      (oset im is-open t)
      (update im))))

(defun slack-ws-handle-close (payload team)
  (slack-if-let* ((room-id (plist-get payload :channel))
                  (room (slack-room-find room-id team)))
      (cond
       ((slack-im-p room)
        (oset room is-open nil)
        (slack-log (format "Direct message with %s is closed"
                           (slack-user-name
                            (plist-get payload :user)
                            team))
                   team :level 'info))
       ((slack-group-p room)
        (oset team groups (cl-remove-if #'(lambda (e)
                                            (slack-equalp e room))
                                        (oref team groups)))))))

(defun slack-ws-handle-message (payload team)
  (let ((subtype (plist-get payload :subtype)))
    (cond
     ((and subtype (string= subtype "message_changed"))
      (slack-ws-change-message payload team))
     ((and subtype (string= subtype "message_deleted"))
      (slack-ws-delete-message payload team))
     ((and subtype (string= subtype "message_replied"))
      (slack-ws-handle-message-replied payload team))
     (t
      (slack-ws-update-message payload team)))))

(defun slack-ws-change-message (payload team)
  (slack-if-let* ((room-id (plist-get payload :channel))
                  (room (slack-room-find room-id team))
                  (message-payload (plist-get payload :message))
                  (ts (plist-get message-payload :ts))
                  (base (slack-room-find-message room ts))
                  (new-message (slack-message-create message-payload
                                                     team
                                                     room)))
      (progn
        (oset new-message reactions (oref base reactions))
        (slack-message-update new-message team t nil base))
    ))


(defun slack-ws-delete-message (payload team)
  (slack-if-let* ((room-id (plist-get payload :channel))
                  (room (slack-room-find room-id team))
                  (ts (plist-get payload :deleted_ts))
                  (message (slack-room-find-message room ts)))
      (slack-message-deleted message room team)))

(defun slack-ws-update-message (payload team)
  (let ((subtype (plist-get payload :subtype)))
    (if (string= subtype "bot_message")
        (slack-ws-update-bot-message payload team)
      (let ((message (slack-message-create payload team)))
        (slack-if-let* ((user (slack-user-find message team)))
            (slack-message-update message team)
          (progn
            (slack-log (format "User not found: %S"
                               (slack-message-sender-id message))
                       team :level 'debug)
            (slack-user-info-request
             (slack-message-sender-id message)
             team
             :after-success
             #'(lambda ()
                 (slack-message-update message team)))))))))

(defun slack-ws-update-bot-message (payload team)
  (let* ((bot-id (plist-get payload :bot_id))
         (username (plist-get payload :username))
         (user (plist-get payload :user))
         (bot (or (slack-find-bot bot-id team)
                  (slack-find-bot-by-name username team)
                  (slack-user--find user team)))
         (message (slack-message-create payload team)))
    (if bot
        (slack-message-update message team)
      (slack-bot-info-request bot-id
                              team
                              #'(lambda ()
                                  (slack-message-update message team))))))

(defun slack-ws-payload-pong-p (payload)
  (string= "pong" (plist-get payload :type)))

(cl-defmethod slack-ws-remove-from-resend-queue ((ws slack-team-ws) payload team)
  (unless (slack-ws-payload-pong-p payload)
    (with-slots (waiting-send) ws
      (slack-log (format "waiting-send: %s" (length waiting-send))
                 team :level 'trace)
      (setq waiting-send
            (cl-remove-if #'(lambda (e) (eq (plist-get e :id)
                                            (plist-get payload :reply_to)))
                          waiting-send))
      (slack-log (format "waiting-send: %s" (length waiting-send))
                 team :level 'trace))))

(cl-defmethod slack-ws-handle-reply ((ws slack-team-ws) payload team)
  (let ((ok (plist-get payload :ok)))
    (if (eq ok :json-false)
        (let* ((err (plist-get payload :error))
               (code (plist-get err :code))
               (msg (plist-get err :msg))
               (template "Failed to send message. Error code: %s msg: %s"))
          (slack-log (format template code msg) team :level 'error))
      (let ((message-id (plist-get payload :reply_to)))
        (when (integerp message-id)
          (slack-message-handle-reply
           (slack-message-create payload team "")
           team)
          (slack-ws-remove-from-resend-queue ws payload team))))))

(defun slack-ws-handle-reaction-added (payload team)
  (let ((user-id (plist-get payload :user)))
    (cl-labels
        ((update-message (message reaction item-type)
                         (slack-message-append-reaction message reaction item-type)
                         (slack-message-update message team t t))
         (update (payload)
                 (let* ((item (plist-get payload :item))
                        (item-type (plist-get item :type))
                        (reaction (make-instance 'slack-reaction
                                                 :name (plist-get payload :reaction)
                                                 :count 1
                                                 :users (list user-id))))
                   (cond
                    ((string= item-type "message")
                     (slack-if-let* ((room (slack-room-find (plist-get item :channel) team))
                                     (message (slack-room-find-message room (plist-get item :ts))))
                         (progn
                           (update-message message reaction item-type)
                           (let* ((user-id (plist-get payload :user))
                                  (reaction (plist-get payload :reaction))
                                  (text (format "added reaction %s" reaction))
                                  (msg (make-instance 'slack-user-message
                                                      :text text
                                                      :user user-id)))
                             (slack-message-notify msg room team)))))))))
      (if (slack-user--find user-id team)
          (update payload)
        (slack-user-info-request user-id
                                 team
                                 :after-success
                                 #'(lambda () (update payload)))))))

(defun slack-ws-handle-reaction-removed (payload team)
  (let ((user-id (plist-get payload :user)))
    (cl-labels
        ((update-message (message reaction item-type)
                         (slack-message-pop-reaction message reaction item-type)
                         (slack-message-update message team t t))
         (update (payload)
                 (let* ((item (plist-get payload :item))
                        (item-type (plist-get item :type))
                        (reaction (make-instance 'slack-reaction
                                                 :name (plist-get payload :reaction)
                                                 :count 1
                                                 :users (list user-id))))
                   (cond
                    ((string= item-type "message")
                     (slack-if-let* ((room (slack-room-find (plist-get item :channel) team))
                                     (message (slack-room-find-message room (plist-get item :ts))))
                         (progn
                           (update-message message reaction item-type)
                           (let* ((user-id (plist-get payload :user))
                                  (reaction (plist-get payload :reaction))
                                  (text (format "removed reaction %s" reaction))
                                  (msg (make-instance 'slack-user-message
                                                      :text text
                                                      :user user-id)))
                             (slack-message-notify msg room team)))))))))
      (if (slack-user--find user-id team)
          (update payload)
        (slack-user-info-request user-id
                                 team
                                 :after-success
                                 #'(lambda () (update payload)))))))

(defun slack-ws-handle-channel-created (payload team)
  (let ((channel (slack-room-create (plist-get payload :channel)
                                    'slack-channel)))
    (push channel (oref team channels))
    (slack-conversations-info channel team)
    (slack-log (format "Created channel %s"
                       (slack-room-display-name channel team))
               team :level 'info)))

(defun slack-ws-handle-room-archive (payload team)
  (let* ((id (plist-get payload :channel))
         (room (slack-room-find id team)))
    (oset room is-archived t)
    (slack-log (format "Channel: %s is archived"
                       (slack-room-display-name room team))
               team :level 'info)))

(defun slack-ws-handle-room-unarchive (payload team)
  (let* ((id (plist-get payload :channel))
         (room (slack-room-find id team)))
    (oset room is-archived nil)
    (slack-log (format "Channel: %s is unarchived"
                       (slack-room-display-name room team))
               team :level 'info)))

(defun slack-ws-handle-channel-deleted (payload team)
  (let* ((id (plist-get payload :channel))
         (room (slack-room-find id team)))
    (cond
     ((object-of-class-p room 'slack-channel)
      (with-slots (channels) team
        (setq channels (cl-delete-if #'(lambda (c) (slack-room-equal-p room c))
                                     channels)))
      (message "Channel: %s deleted"
               (slack-room-display-name room team))))))

(defun slack-ws-handle-room-rename (payload team)
  (let* ((c (plist-get payload :channel))
         (room (slack-room-find (plist-get c :id) team))
         (old-name (slack-room-name room team))
         (new-name (plist-get c :name)))
    (oset room name new-name)
    (slack-log (format "Renamed channel from %s to %s"
                       old-name
                       new-name)
               team :level 'info)))

(defun slack-ws-handle-group-joined (payload team)
  (let ((group (slack-room-create
                (plist-get payload :channel)
                'slack-group)))
    (push group (oref team groups))
    (slack-conversations-info group team)
    (slack-log (format "Joined group %s"
                       (slack-room-display-name group team))
               team :level 'info)))

(defun slack-ws-handle-channel-joined (payload team)
  (let ((channel (slack-room-find (plist-get (plist-get payload :channel) :id) team)))
    (slack-conversations-info channel team)
    (slack-log (format "Joined channel %s"
                       (slack-room-display-name channel team))
               team :level 'info)))

(defun slack-ws-handle-presence-change (payload team)
  (let* ((id (plist-get payload :user))
         (user (slack-user--find id team)))
    (cl-labels
        ((update ()
                 (let ((user (slack-user--find id team))
                       (presence (plist-get payload :presence)))
                   (plist-put user :presence presence))))
      (if user (update)
        (slack-user-info-request id
                                 team
                                 :after-success #'update)))))

(defun slack-ws-handle-bot (payload team)
  (let ((bot (plist-get payload :bot)))
    (with-slots (bots) team
      (push bot bots))))

(defun slack-ws-handle-file-created (payload team)
  (slack-if-let* ((file-id (plist-get (plist-get payload :file) :id))
                  (buffer (slack-buffer-find 'slack-file-list-buffer
                                             team)))
      (slack-file-request-info file-id 1 team
                               #'(lambda (file _team)
                                   (slack-buffer-update buffer file)))))

(defun slack-ws-handle-file-deleted (payload team)
  (let ((file-id (plist-get payload :file_id)))
    (oset team files
          (cl-remove-if #'(lambda (f) (string= file-id
                                               (oref f id)))
                        (oref team files)))))

(defun slack-ws-handle-room-marked (payload team)
  (slack-if-let* ((channel (plist-get payload :channel))
                  (room (slack-room-find channel team))
                  (ts (plist-get payload :ts))
                  (unread-count-display
                   (plist-get payload :unread_count_display))
                  (mention-count-display
                   (plist-get payload :mention_count_display)))
      (progn
        (oset room unread-count-display unread-count-display)
        (oset room last-read ts)
        (oset room mention-count-display mention-count-display)
        (slack-update-modeline)
        (slack-if-let*
            ((buffer (slack-buffer-find 'slack-message-buffer room team)))
            (slack-buffer-update-marker-overlay buffer)))))

(defun slack-ws-handle-thread-marked (payload team)
  (let* ((subscription (plist-get payload :subscription))
         (thread-ts (plist-get subscription :thread_ts))
         (channel (plist-get subscription :channel))
         (room (slack-room-find channel team))
         (parent (and room (slack-room-find-message room thread-ts))))
    (when (and parent (oref parent thread))
      (slack-thread-marked (oref parent thread) subscription))))

(defun slack-ws-handle-thread-subscribed (payload team)
  (let* ((thread-data (plist-get payload :subscription))
         (room (slack-room-find (plist-get thread-data :channel) team))
         (message (and (slack-room-find-message room (plist-get thread-data :thread_ts))))
         (thread (and message (oref message thread))))
    (when thread
      (slack-thread-marked thread thread-data))))

(defun slack-ws-handle-user-change (payload team)
  (let* ((user (plist-get payload :user))
         (id (plist-get user :id)))
    (with-slots (users) team
      (setq users
            (cons user
                  (cl-remove-if #'(lambda (u)
                                    (string= id (plist-get u :id)))
                                users))))))

(defun slack-ws-handle-member-joined-channel (payload team)
  (slack-if-let* ((user (plist-get payload :user))
                  (channel (slack-room-find (plist-get payload :channel) team)))
      (cl-pushnew user (oref channel members)
                  :test #'string=)))

(defun slack-ws-handle-member-left_channel (payload team)
  (slack-if-let* ((user (plist-get payload :user))
                  (channel (slack-room-find (plist-get payload :channel) team)))
      (oset channel members
            (cl-remove-if #'(lambda (e) (string= e user))
                          (oref channel members)))))

(defun slack-ws-handle-dnd-updated (payload team)
  (let* ((user (slack-user--find (plist-get payload :user) team))
         (updated (slack-user-update-dnd-status user (plist-get payload :dnd_status))))
    (oset team users
          (cons updated (cl-remove-if #'(lambda (user) (string= (plist-get user :id)
                                                                (plist-get updated :id)))
                                      (oref team users))))))

;; [star_added event | Slack](https://api.slack.com/events/star_added)
(defun slack-ws-handle-star-added-to-file (file-id team)
  (let ((file (slack-file-find file-id team)))
    (cl-labels
        ((update (&rest _args)
                 (slack-with-file file-id team
                   (slack-message-star-added file)
                   (slack-message-update file team))))
      (if file (update)
        (slack-file-request-info file-id 1 team #'update)))))

(defun slack-ws-handle-star-added (payload team)
  (let* ((item (plist-get payload :item))
         (item-type (plist-get item :type)))
    (cl-labels
        ((update-message (message)
                         (slack-message-star-added message)
                         (slack-message-update message team t t)))
      (cond
       ((string= item-type "file")
        (slack-ws-handle-star-added-to-file (plist-get (plist-get item :file) :id)
                                            team))
       ((string= item-type "message")
        (slack-if-let* ((room (slack-room-find (plist-get item :channel) team))
                        (ts (plist-get (plist-get item :message) :ts))
                        (message (slack-room-find-message room ts)))
            (update-message message)))))
    (slack-if-let* ((star (oref team star)))
        (slack-star-add star item team))))


;; [2018-07-25 16:30:03] (:type star_added :user U1013370U :item (:type file :file (:id FBWDT9VH8) :date_create 1532503802 :file_id FBWDT9VH8 :user_id USLACKBOT) :event_ts 1532503802.000378)
(defun slack-ws-handle-star-removed-from-file (file-id team)
  (let ((file (slack-file-find file-id team)))
    (cl-labels
        ((update (&rest _args)
                 (slack-with-file file-id team
                   (slack-message-star-removed file)
                   (slack-message-update file team))))
      (if file (update)
        (slack-file-request-info file-id 1 team #'update)))))

(defun slack-ws-handle-star-removed (payload team)
  (let* ((item (plist-get payload :item))
         (item-type (plist-get item :type)))
    (cl-labels
        ((update-message (message)
                         (slack-message-star-removed message)
                         (slack-message-update message team t t)))
      (cond
       ((string= item-type "file")
        (slack-ws-handle-star-removed-from-file (plist-get (plist-get item :file) :id)
                                                team))
       ((string= item-type "message")
        (slack-if-let* ((room (slack-room-find (plist-get item :channel) team))
                        (ts (plist-get (plist-get item :message) :ts))
                        (message (slack-room-find-message room ts)))
            (update-message message)))))

    (slack-if-let* ((star (oref team star)))
        (slack-star-remove star item team))))

(defun slack-ws-handle-app-conversation-invite-request (payload team)
  (let* ((app-user (plist-get payload :app_user))
         (channel-id (plist-get payload :channel_id))
         (invite-message-ts (plist-get payload :invite_message_ts))
         (scope-info (plist-get payload :scope_info))
         (room (slack-room-find channel-id team)))
    (if (yes-or-no-p (format "%s\n%s\n"
                             (format "%s would like to do following in %s"
                                     (slack-user-name app-user team)
                                     (slack-room-name room team))
                             (mapconcat #'(lambda (scope)
                                            (format "* %s"
                                                    (plist-get scope
                                                               :short_description)))
                                        scope-info
                                        "\n")))
        (slack-app-conversation-allow-invite-request team
                                                     :channel channel-id
                                                     :app-user app-user
                                                     :invite-message-ts invite-message-ts)
      (slack-app-conversation-deny-invite-request team
                                                  :channel channel-id
                                                  :app-user app-user
                                                  :invite-message-ts invite-message-ts))))

(cl-defun slack-app-conversation-allow-invite-request (team &key channel
                                                            app-user
                                                            invite-message-ts)
  (let ((url "https://slack.com/api/apps.permissions.internal.add")
        (params (list (cons "channel" channel)
                      (cons "app_user" app-user)
                      (cons "invite_message_ts" invite-message-ts)
                      (cons "did_confirm" "true")
                      (cons "send_ephemeral_error_message" "true"))))
    (cl-labels
        ((log-error (err)
                    (slack-log (format "Error: %s, URL: %s, PARAMS: %s"
                                       err
                                       url
                                       params)
                               team :level 'error))
         (on-success (&key data &allow-other-keys)
                     (slack-request-handle-error
                      (data "slack-app-conversation-allow-invite-request"
                            #'log-error)
                      (message "DATA: %s" data))))
      (slack-request
       (slack-request-create
        url
        team
        :type "POST"
        :params params
        :success #'on-success)))))

(cl-defun slack-app-conversation-deny-invite-request (team &key channel
                                                           app-user
                                                           invite-message-ts)
  (let ((url "https://slack.com/api/apps.permissions.internal.denyAdd")
        (params (list (cons "channel" channel)
                      (cons "app_user" app-user)
                      (cons "invite_message_ts" invite-message-ts))))
    (cl-labels
        ((log-error (err)
                    (slack-log (format "Error: %s, URL: %s, PARAMS: %s"
                                       err
                                       url
                                       params)
                               team :level 'error))
         (on-success (&key data &allow-other-keys)
                     (slack-request-handle-error
                      (data "slack-app-conversation-deny-invite-request"
                            #'log-error)
                      (message "DATA: %s" data))))
      (slack-request
       (slack-request-create
        url
        team
        :type "POST"
        :params params
        :success #'on-success)))))

(defun slack-ws-handle-commands-changed (payload team)
  (let ((commands-updated (mapcar #'slack-command-create
                                  (plist-get payload :commands_updated)))
        (commands-removed (mapcar #'slack-command-create
                                  (plist-get payload :commands_removed)))
        (commands '()))
    (cl-loop for command in (oref team commands)
             if (and (not (cl-find-if #'(lambda (e) (slack-equalp command e))
                                      commands-removed))
                     (not (cl-find-if #'(lambda (e) (slack-equalp command e))
                                      commands-updated)))
             do (push command commands))
    (cl-loop for command in commands-updated
             do (push command commands))
    (oset team commands commands)))

(defun slack-ws-handle-dialog-opened (payload team)
  (slack-if-let*
      ((dialog-id (plist-get payload :dialog_id))
       (client-token (plist-get payload :client_token))
       (valid-client-tokenp (string= (slack-team-client-token team)
                                     client-token)))
      (slack-dialog-get dialog-id team)))

(defun slack-ws-handle-room-left (payload team)
  (slack-if-let* ((room (slack-room-find (plist-get payload :channel)
                                         team)))
      (progn
        (when (slot-exists-p room 'is-member)
          (oset room is-member nil))
        (when (and (not (slack-channel-p room)) (slack-group-p room))
          (oset team groups
                (cl-remove-if #'(lambda (e)
                                  (slack-room-equal-p e room))
                              (oref team groups))))
        (slack-log (format "You left %s" (slack-room-name room team))
                   team :level 'info))))

(defun slack-ws-handle-subteam-created (payload team)
  (let ((usergroup (slack-usergroup-create (plist-get payload :subteam))))
    (push usergroup (oref team usergroups))))

(defun slack-ws-handle-subteam-updated (payload team)
  (let ((usergroup (slack-usergroup-create (plist-get payload :subteam))))
    (oset team usergroups (cons usergroup
                                (cl-remove-if #'(lambda (e)
                                                  (string= (oref e id)
                                                           (oref usergroup id)))
                                              (oref team usergroups))))))

(defun slack-ws-handle-message-replied (payload team)
  (slack-if-let* ((message-payload (plist-get payload :message))
                  (thread-ts (plist-get message-payload :thread_ts))
                  (room (slack-room-find (plist-get payload :channel)
                                         team))
                  (message (slack-room-find-message room thread-ts))
                  (thread (slack-message-get-thread message))
                  (new-thread (slack-thread-create message
                                                   message-payload)))
      (progn
        (slack-merge thread new-thread)
        (slack-message-update message team t t))
    (message "THREAD_TS: %s, ROOM: %s, MESSAGE: %s THREAD: %s, NEW_THREAD:%s"
             thread-ts
             (not (null room))
             (not (null message))
             (not (null thread))
             (not (null new-thread)))))

(provide 'slack-websocket)
;;; slack-websocket.el ends here
