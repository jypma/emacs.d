;;; telega-voip.el --- Support for VOIP calls  -*- lexical-binding:t -*-

;; Copyright (C) 2019 by Zajcev Evgeny.

;; Author: Zajcev Evgeny <zevlg@yandex.ru>
;; Created: Thu Jan 10 17:33:13 2019
;; Keywords:

;; telega is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; telega is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with telega.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; VOIP calls support for the telega

;;; Code:
(require 'cl-lib)
(require 'telega-core)
(require 'telega-tdlib)
(require 'telega-customize)
(require 'telega-ffplay)

(declare-function telega-status--set "telega-root"
                  (conn-status &optional aux-status raw))


(defconst telega-voip-protocol
  (list :@type "callProtocol"
        :udp_p2p t :udp_reflector t
        :min_layer 65 :max_layer 65
        ))
;        :library_versions (vector (telega-voip-version))))

(defsubst telega-voip--by-id (call-id)
  "Return call by CALL-ID."
  (alist-get call-id telega-voip--alist))

(defsubst telega-voip--by-user-id (user-id)
  "Return call to user defined by USER-ID."
  (cdr (cl-find user-id telega-voip--alist
                :test '= :key (lambda (el)
                                (plist-get (cdr el) :user_id)))))

(defun telega-voip-version ()
  "Return libtgvoip version compiled into telega-server."
  (let ((ts-usage (shell-command-to-string
                   (telega-server--process-command "-h"))))
    (when (string-match "with VOIP tgvoip v\\([0-9.]+\\)" ts-usage)
      (match-string 1 ts-usage))))

(defun telega-voip--call-emojis (call)
  "Return emojis string for the CALL."
  (telega--desurrogate-apply
   ;; Use `mapconcat' instead of direct `concat', because :emojis is a
   ;; vector
   (mapconcat 'identity (telega--tl-get call :state :emojis) "")))

(defun telega-voip--incoming-call ()
  "Return first incoming call that can be accepted."
  (cl-find-if (lambda (call)
                (and (not (plist-get call :is_outgoing))
                     (eq (telega--tl-type (plist-get call :state))
                         'callStatePending)))
              (mapcar 'cdr telega-voip--alist)))

(defun telega-voip--aux-status (call)
  "Update `telega--status-aux' according to active CALL."
  (telega-status--set
   nil (telega-ins--as-string
        (when call
          (let ((user-id (plist-get call :user_id))
                (state (plist-get call :state)))
            ;; server/user receive status
            (cond ((plist-get state :is_received)
                   (telega-ins telega-symbol-heavy-checkmark))
                  ((plist-get state :is_created)
                   (telega-ins telega-symbol-checkmark)))
            (telega-ins telega-symbol-phone)
            (if (plist-get call :is_outgoing)
                (telega-ins "→")
              (telega-ins "←"))

            (apply 'insert-text-button
                   (telega-user--name (telega-user-get user-id) 'name)
                   (telega-link-props 'user user-id))
            (telega-ins-fmt " %s"
              (substring (plist-get state :@type) 9))
            (cl-case (telega--tl-type state)
              (callStatePending
               ;; dot for animation
               (telega-ins "."))
              (callStateReady
               ;; key emojis
               (telega-ins " " (telega-voip--call-emojis call)))))))))


(defun telega-voip-discard (call)
  "Discard the CALL.
If called interactively then discard active call."
  (interactive (list (or telega-voip--active-call
                         (telega-voip--incoming-call)
                         (error "No active or incoming call to discard"))))
  (when (eq (plist-get call :id)
            (plist-get telega-voip--active-call :id))
    (telega-server--send (list :@command "stop") "voip"))

  (telega--discardCall (plist-get call :id)))

(defun telega-voip-active-call-p (call)
  "Return non-nil if CALL currently active.
Compare calls by `:id'."
  (eq (plist-get call :id) (plist-get telega-voip--active-call :id)))

(defun telega-voip-activate-call (call)
  "Activate the CALL, i.e. make CALL currently active.
Discard currently active call, if any."
  (when telega-voip--active-call
    (telega-voip-discard telega-voip--active-call))

  (setq telega-voip--active-call call)
  (telega-voip--aux-status telega-voip--active-call))

(defun telega-voip-call (user &optional force)
  "Call the USER.
Discard active call if any."
  (when (or force
            (not telega-voip--active-call)
            (y-or-n-p (format "Active call will be discarded, call %s? "
                              (telega-user--name user 'name))))
    (when telega-voip--active-call
      (telega-voip-discard telega-voip--active-call)
      (setq telega-voip--active-call nil))

    (telega--createCall user)))

(defun telega-voip-accept (call)
  "Accept last incoming CALL.
Discard active call if any."
  (interactive (list (telega-voip--incoming-call)))

  (unless call
    (error "No incoming call to accept"))

  ;; TODO: might be situation when we twice accept the call, it will
  ;; lead to call discard.  Check that CALL is not already active
  (telega--acceptCall (plist-get call :id))
  (telega-voip-activate-call call)

  ;; TODO: show call buffer for the CALL
  )

(defun telega-voip-buffer-show (_call)
  "Show callbuf for the CALL."
  (interactive (list telega-voip--active-call))
  (message "TODO: `telega-voip-buffer-show'"))

(defun telega-voip-list-calls (only-missed)
  "List recent calls.
If prefix arg is given then list only missed calls."
  (interactive "P")
  (let* ((ret (telega-server--call
               (list :@type "searchCallMessages"
                     :from_message_id 0
                     :limit 100
                     ;; NOTE: `:only_missed t' gives some problems :(
                     :only_missed (if (null only-missed) :false t))))
         (messages (mapcar #'identity (plist-get ret :messages))))
    (with-telega-help-win "*Telega Recent Calls*"
      (telega-ins (if only-missed "Missed" "All") " Calls\n")
      (telega-ins (make-string (- (point-max) 2) ?-) "\n")

      (dolist (call-msg messages)
        (telega-ins--with-attrs (list :align 'left
                                      :min 60
                                      :max 60
                                      :elide t)
          (telega-ins--username (plist-get call-msg :sender_user_id) 'name)
          (telega-ins ": ")
          (telega-ins--content-one-line call-msg))
        (telega-ins--with-attrs (list :align 'right :min 10)
          (telega-ins--date (plist-get call-msg :date)))
        (telega-ins "\n")))
    ))


(defun telega-voip-sounds--play-incoming (_call)
  "Incomming CALL pending."
  (unless telega-voip--active-call
    (telega-ffplay-run (telega-etc-file "sounds/call_incoming.mp3") nil
                       "-nodisp -loop 0")))

(defun telega-voip-sounds--play-outgoing (_call)
  "Outgoing CALL initiated."
  (telega-ffplay-run (telega-etc-file "sounds/call_outgoing.mp3") nil
                     "-nodisp -loop 0"))

(defun telega-voip-sounds--play-connect (_call)
  "Call ready to be used."
  (telega-ffplay-run (telega-etc-file "sounds/call_connect.mp3") nil
                     "-nodisp"))

(defun telega-voip-sounds--play-end (call)
  "CALL finished."
  (when (or (not telega-voip--active-call)
            (telega-voip-active-call-p call))
    (let* ((state (plist-get call :state))
           (reason (when (eq (telega--tl-type state) 'callStateDiscarded)
                     (telega--tl-type (plist-get state :reason))))
           (snd (if (and (plist-get call :is_outgoing)
                         (memq reason '(callDiscardReasonDeclined
                                        callDiscardReasonMissed)))
                    "sounds/call_busy.mp3"
                  "sounds/call_end.mp3")))
      (telega-ffplay-run (telega-etc-file snd) nil "-nodisp"))
    ))

(defun telega-voip-sounds-mode (&optional arg)
  "Toggle soundsToggle telega notifications on or off.
With positive ARG - enables notifications, otherwise disables.
If ARG is not given then treat it as 1."
  (interactive "p")
  (if (or (null arg) (> arg 0))
      (progn
        (add-hook 'telega-call-incoming-hook 'telega-voip-sounds--play-incoming)
        (add-hook 'telega-call-outgoing-hook 'telega-voip-sounds--play-outgoing)
        (add-hook 'telega-call-ready-hook 'telega-voip-sounds--play-connect)
        (add-hook 'telega-call-end-hook 'telega-voip-sounds--play-end))
    (remove-hook 'telega-call-incoming-hook 'telega-voip-sounds--play-incoming)
    (remove-hook 'telega-call-outgoing-hook 'telega-voip-sounds--play-outgoing)
    (remove-hook 'telega-call-ready-hook 'telega-voip-sounds--play-connect)
    (remove-hook 'telega-call-end-hook 'telega-voip-sounds--play-end)))


;; Voice Chats and Group calls
(defun telega-voice-chat-start (chat title)
  "Start voice chat in the CHAT."
  (interactive (list (or telega-chatbuf--chat (telega-chat-at (point)))
                     (read-string "Voice Chat Title: ")))
  (telega--createVoiceChat chat
    (unless (string-empty-p title)
      (lambda (group-call-id)
        (telega--setGroupCallTitle
         ;; NOTE: use faked group call to avoid
         ;; `telega-group-call-get' call
         (list :id group-call-id :can_be_managed t) title))))
  )

(defun telega-voice-chat-record-start (chat title)
  "Start recording group call associated with CHAT."
  (interactive
   (list (or telega-chatbuf--chat (telega-chat-at (point)))
         (read-string "Record with Title: ")))
  (let ((group-call (with-telega-chatbuf chat
                      (telega-chatbuf--group-call))))
    (unless (and group-call (plist-get group-call :can_be_managed))
      (user-error "Can't record"))
    (telega--startGroupCallRecording group-call title)))

(defun telega-voice-chat-record-stop (chat)
  "Start recording group call associated with CHAT."
  (interactive (list (or telega-chatbuf--chat (telega-chat-at (point)))))
  (let ((group-call (with-telega-chatbuf chat
                      (telega-chatbuf--group-call))))
    (unless (and group-call (plist-get group-call :can_be_managed))
      (user-error "Can't stop recording"))
    (telega--endGroupCallRecording group-call)))

(defun telega-voice-chat-toggle-footer (chat)
  "Toggle voice chate visibility in CHAT's footer/modeline."
  (interactive (list (or telega-chatbuf--chat (telega-chat-at (point)))))
  (with-telega-chatbuf chat
    (setq telega-chatbuf--voice-chat-hidden
          (not telega-chatbuf--voice-chat-hidden))
    (telega-chatbuf--footer-update)
    (telega-chatbuf--modeline-update)))

(defun telega-group-call--ensure (group-call)
  "Ensure GROUP-CALL is in the `telega--group-calls'.
Return GROUP-CALL."
  (when telega-debug
    (cl-assert group-call))
  (plist-put group-call :telega-call-recency (telega-time-seconds))
  (puthash (plist-get group-call :id) group-call telega--group-calls)

  (telega-root-view--update :on-group-call-update group-call)
  group-call)

(defun telega-group-call-get (group-call-id &optional callback)
  "Return group call by GROUP-CALL-ID."
  (declare (indent 1))
  (telega-debug "group-call: get %d" group-call-id)
  (let ((group-call (gethash group-call-id telega--group-calls)))
    (if (or group-call (null callback))
        (funcall (or callback #'identity) group-call)

      (cl-assert callback)
      (cl-assert (not (zerop group-call-id)))
      (telega--getGroupCall group-call-id
        (lambda (group-call)
          (telega-group-call--ensure group-call)
          (funcall callback group-call))))))

(defun telega-group-call--participant-svg-outline (svg circle
                                                       &optional speaking-p)
  "Outline resulting SVG for voice chat participant.
SPEAKING-P if participant is speaking."
  (svg-circle svg (nth 0 circle) (nth 1 circle) (nth 2 circle)
              :stroke-width (/ (nth 2 circle) (if speaking-p 5 10))
              :stroke-color (telega-color-name-as-hex-2digits
                             (face-foreground
                              (if speaking-p 'font-lock-string-face 'shadow)
                              nil t))
              :opacity 0.85
              :fill-opacity "0"))

(defun telega-group-call--participant-svg-outline-speaking (svg circle)
  (telega-group-call--participant-svg-outline svg circle 'speaking))

(defun telega-group-call--participant-create-image (speaking-p
                                                    cheight sender file)
  "Create image for SENDER participant.
SPEAKING-P if participant is speaking.
CHEIGHT - height in chars for the image."
  (telega-avatar--create-image
   sender file cheight
   (when speaking-p
     #'telega-group-call--participant-svg-outline-speaking)))

(defun telega-group-call--participant-image (participant &optional cheight
                                                         force-update)
  "Create avatar image for the PARTICIPANT.
PARTICIPANT is either \"groupCallParticipant\" or \"groupCallRecentSpeaker\".
CHEIGHT is height in chars, default is 1."
  (telega-msg-sender-avatar-image
   (telega-msg-sender
    (or (plist-get participant :speaker) ;groupCallRecentSpeaker
        (plist-get participant :participant))) ;groupCallParticipant
   (apply-partially #'telega-group-call--participant-create-image
                    (plist-get participant :is_speaking) (or cheight 1))
   force-update
   (intern (concat ":telega-avatar-vc-"
                   (when (plist-get participant :is_speaking)
                     "speaking-")
                   (int-to-string (or cheight 1))))))

(defun telega-group-call-join (_group-call)
  "Join the GROUP-CALL."
  (error "TODO: join group call")
  )

(defun telega-group-call-leave (_group-call)
  "Leave the GROUP-CALL."
  (error "TODO: leave group call")
  )

(defun telega-group-call-set-title (group-call &optional title)
  "Set GROUP-CALL's title to TITLE.
If TITLE is not specified, ask user interactively for the new title."
  (unless title
    (setq title (read-string "Group Call Title: ")))
  (telega--setGroupCallTitle group-call title))

(defun telega-describe-group-call--inserter (group-call-id)
  "Inserter for the voice chat."
  (let* ((group-call (telega-group-call-get group-call-id))
         (can-manage-p (plist-get group-call :can_be_managed)))
    (telega-ins (telega-i18n "lng_group_call_title") ": "
                (or (telega-tl-str group-call :title)
                    (propertize "No title" 'face 'shadow)))
    (telega-ins " ")
    (if (plist-get group-call :is_joined)
        (telega-ins--button "Leave"
          :value group-call
          :action #'telega-group-call-leave)
      (telega-ins--button "Join"
        :value group-call
        :action #'telega-group-call-join))

    (when can-manage-p
      (telega-ins " ")
      (telega-ins--button (telega-i18n "lng_group_call_end")
        :value group-call
        :action #'telega--discardGroupCall)
      (telega-ins " ")
      (telega-ins--button "Set Title"
        :value group-call
        :action #'telega-group-call-set-title))

    (telega-ins "\n")
    ))

(defun telega-describe-group-call (group-call)
  "Describe a GROUP-CALL."
  (with-telega-help-win "*Telegram Voice Chat*"
    (telega-describe-group-call--inserter (plist-get group-call :id))

    (setq telega--help-win-param (plist-get group-call :id))
    (setq telega--help-win-inserter #'telega-describe-group-call--inserter)))

(defun telega-describe-group-call--maybe-redisplay (group-call-id)
  "Possible redisplay \\*Telega Voice Chat\\* buffer for the GROUP-CALL-ID."
  (telega-help-win--maybe-redisplay "*Telega Voice Chat*" group-call-id))

(provide 'telega-voip)

;; On load
(when telega-voip-use-sounds
  (telega-voip-sounds-mode 1))

;;; telega-voip.el ends here