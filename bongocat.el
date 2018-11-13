
;;; Code:

(defconst bongocat-directory (file-name-directory (or load-file-name buffer-file-name)))

(defconst bongocat-default-smash-delay 0.075)

(defvar bongocat-frames nil)

(defvar bongocat-current-state "up")

(defun bongocat-load-frame (state)
  "Create the frame image corresponding to the specified STATE (down/up)."
  (create-image (concat bongocat-directory
                        (format "img/default/bongocat-%s.xpm" state)) 'xpm nil :ascent 'center))

(defun bongocat-set-state (state)
  "Set the STATE of Bongo cat's paws."
  (if (eq state nil)
      (setq bongocat-current-state "up")
      (setq bongocat-current-state state))
  (bongocat-refresh-frame)
  )

(defun bongocat-refresh-frame ()
  "Re-render the current frame in the modeline."
  (when (and (featurep 'bongocat)
             (bound-and-true-p bongocat-mode))
    (force-mode-line-update)
    )
  )
  
(defun bongocat-load-frames ()
  "Load images into memory."
  (when (image-type-available-p 'xpm)
    ;; This loads the images of "up" and "down" into the list "bongocat-frames".
    ;; Thus the image indices in the list are as follows: Down = 0, Up = 1
    (setq bongocat-frames (mapcar (lambda (state)
                                    (bongocat-load-frame state))
                                  '("down" "up")))
    )
  )

(defun bongocat-get-current-frame ()
  "Get the frame to be displayed based on current state."
  (cond ((string= bongocat-current-state "down") (nth 0 bongocat-frames))
        ((string= bongocat-current-state "up") (nth 1 bongocat-frames))
        (t (nth 1 bongocat-frames)) ;; return the UP image by default
        )
  )

(defun bongocat-initialize ()
  "Create modeline string containing Bongocat!"
  (let ((modeline-string ""))
    (setq modeline-string (propertize "-" 'display (bongocat-get-current-frame)))
    )
  )

(defun bongocat-smash (&optional delay)
  "Make Bongocat smash the modeline with optional DELAY in seconds.  Otherwise default delay will be used."
  (if (string= bongocat-current-state "down")
      (bongocat-set-state "up"))

  (bongocat-set-state "down")
  (run-at-time (format "%s seconds" bongocat-default-smash-delay) nil #'bongocat-set-state "up")
  )

(defvar bongocat-initial-modeline-cdr nil)

;;;###autoload
(define-minor-mode bongocat-mode
  "Bongocat minor mode"
  :global t
  (if bongocat-mode
      (progn
        (bongocat-load-frames)
        (unless bongocat-initial-modeline-cdr
          (setq bongocat-initial-modeline-cdr (cdr mode-line-position)))
        
        (setcdr mode-line-position (cons '(:eval (list (bongocat-initialize)))
                                         (cdr bongocat-initial-modeline-cdr)))
        (add-hook 'post-self-insert-hook #'bongocat-smash))
    (setcdr mode-line-position bongocat-initial-modeline-cdr)
    )
  )

(provide 'bongocat)
;;; bongocat.el ends here
