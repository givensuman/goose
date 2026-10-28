(require "plugins/flash/flash.scm")
(keymap
  (global)
  (normal
    (s ":flash-forward")
    (S ":flash-backward")
  )
  (select
    (s ":flash-forward")
    (S ":flash-backward")
  )
)
