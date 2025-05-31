;;; touch-grass.el --- Remind yourself to go outside and touch grass -*- lexical-binding: t; -*-

;; Author: Aleksandar Simic
;; Version: 1.0.0
;; Package-Requires: ((emacs "30.1"))
;; Keywords: health, reminder, break
;; URL: https://github.com/dotemacs/touch-grass.el

;;; Commentary:

;; Touch Grass mode reminds you to take breaks and go outside at
;; configurable intervals. When the timer expires, it displays a
;; friendly reminder message encouraging you to step away from your
;; computer and touch some grass.

;; Usage:
;;   M-x touch-grass to start the mode
;;   M-x touch-grass again to stop the mode

;;; Code:

(defgroup touch-grass nil
  "Settings for touch-grass mode."
  :group 'convenience
  :prefix "touch-grass-")

(defcustom touch-grass-interval 30
  "Interval in minutes between touch grass reminders."
  :type 'integer
  :group 'touch-grass)

(defcustom touch-grass-message "Go outside and touch grass!"
  "Message to display when it's time to touch grass."
  :type 'string
  :group 'touch-grass)

(defvar touch-grass--start-time nil
  "Time when touch-grass mode was started.")

(defvar touch-grass--timer nil
  "Timer object for touch grass reminders.")

(defvar touch-grass-mode nil
  "Non-nil if touch-grass mode is enabled.")

(defun touch-grass--show-reminder ()
  "Display the touch grass reminder message."
  (message "%s" touch-grass-message)
  ;; Also show in a temporary buffer for more visibility
  (let ((buffer (get-buffer-create "*Touch Grass*")))
    (with-current-buffer buffer
      (erase-buffer)
      (insert (format "%s\n\n" touch-grass-message))
      (insert (format "Started at: %s\n"
                      (format-time-string "%Y-%m-%d %H:%M:%S" touch-grass--start-time)))
      (insert (format "Interval: %d minutes\n" touch-grass-interval))
      (insert (format "Current time: %s\n"
                      (format-time-string "%Y-%m-%d %H:%M:%S")))
      (goto-char (point-min)))
    (display-buffer buffer)))

(defun touch-grass--start-timer ()
  "Start the touch grass reminder timer."
  (when touch-grass--timer
    (cancel-timer touch-grass--timer))
  (setq touch-grass--timer
        (run-with-timer (* touch-grass-interval 60)
                        (* touch-grass-interval 60)
                        #'touch-grass--show-reminder)))

(defun touch-grass--stop-timer ()
  "Stop the touch grass reminder timer."
  (when touch-grass--timer
    (cancel-timer touch-grass--timer)
    (setq touch-grass--timer nil)))

(defun touch-grass-mode-enable ()
  "Enable touch-grass mode."
  (setq touch-grass--start-time (current-time))
  (setq touch-grass-mode t)
  (touch-grass--start-timer)
  (message "Touch grass mode enabled! Reminders every %d minutes." touch-grass-interval))

(defun touch-grass-mode-disable ()
  "Disable touch-grass mode."
  (touch-grass--stop-timer)
  (setq touch-grass-mode nil)
  (setq touch-grass--start-time nil)
  (message "Touch grass mode disabled."))

;;;###autoload
(defun touch-grass ()
  "Toggle touch-grass mode.
When enabled, displays reminders to go outside at regular intervals."
  (interactive)
  (if touch-grass-mode
      (touch-grass-mode-disable)
    (touch-grass-mode-enable)))

;; Add to mode line
(defvar touch-grass-mode-line-format
  '(:eval (when touch-grass-mode
            (format " 🌱[%dm]" touch-grass-interval))))

(add-to-list 'mode-line-misc-info touch-grass-mode-line-format)

(provide 'touch-grass)

;;; touch-grass.el ends here
