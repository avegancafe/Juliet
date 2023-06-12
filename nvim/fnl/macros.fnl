(local {: str? : nil?} (require :utils))

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

(lambda deepcopy [obj ?seen]
  (when (not= (type obj) :table) (lua "return obj"))
  (when (and ?seen (. ?seen obj))
    (let [___antifnl_rtn_1___ (. ?seen obj)]
      (lua "return ___antifnl_rtn_1___")))
  (local s (or ?seen {}))
  (local res {})
  (tset s obj res)
  (each [k v (pairs obj)] (tset res (deepcopy k s) (deepcopy v s)))
  (setmetatable res (getmetatable obj)))

{: pack : deepcopy}
