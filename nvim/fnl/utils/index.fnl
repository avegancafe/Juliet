(fn nil? [x]
  (= nil x))

(fn str? [x]
  (= :string (type x)))

(fn num? [x]
  (= :number (type x)))

(fn bool? [x]
  (= :boolean (type x)))

(fn fn? [x]
  (= :function (type x)))

(fn tbl? [x]
  (= :table (type x)))

(fn ->str [x]
  (tostring x))

(fn ->bool [x]
  (if x true false))

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

{: nil? : str? : num? : bool? : fn? : tbl? : ->str : ->bool : deepcopy}
