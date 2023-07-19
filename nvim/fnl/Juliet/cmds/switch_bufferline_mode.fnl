(var buffer-current-tabmode :buffers)
(fn []
  (let [setup-bufferline (require :Juliet.cmds.setup_bufferline)]
  (if (= buffer-current-tabmode :tabs)
      (do
        (print "switching to buffer mode")
        (setup-bufferline.setup :buffers)
        (set buffer-current-tabmode :buffers))
      (do
        (print "switching to tab mode")
        (setup-bufferline.setup :tabs)
        (set buffer-current-tabmode :tabs)))))
