(var buffer-current-tabmode :buffers)
(fn []
  (if (= buffer-current-tabmode :tabs)
      (do
        (print "switching to buffer mode")
        ((. (require :cmds/setup_bufferline) :setup) :buffers)
        (set buffer-current-tabmode :buffers))
      (do
        (print "switching to tab mode")
        ((. (require :cmds/setup_bufferline) :setup) :tabs)
        (set buffer-current-tabmode :tabs))))
