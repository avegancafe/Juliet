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

{: deepcopy}
