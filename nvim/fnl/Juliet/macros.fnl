(local {: str? : nil? : merge} (require :Juliet.utils))

(lambda pack [identifier ?options]
  "A workaround around the lack of mixed tables in Fennel.
  Has special `options` keys for enhanced utility."
  (assert-compile (str? identifier) "expected string for identifier" identifier)
  (assert-compile (or (nil? ?options) (table? ?options))
                  "expected table for options" ?options)
  (let [options (or ?options {})
        options (collect [k v (pairs options)]
                  (match k
                    :require* (values :config `#(require ,v))
                    _ (values k v)))]
    (doto options (tset 1 identifier))))

(lambda key [keycode command ?desc ?options]
  (assert-compile (str? keycode) "expected string for keycode" keycode)
  (assert-compile (or (nil? ?desc) (str? ?desc)) "expected string for description" ?desc)
  (assert-compile (or (nil? ?options) (table? ?options))
                  "expected table for options" ?options)
  (let [options (or ?options {})]
    (doto options (tset 1 keycode))
    (doto options (tset 2 command))
    (merge options
           {:desc ?desc :silent (if (nil? options.silent) true options.silent)})))

{: pack : key}
