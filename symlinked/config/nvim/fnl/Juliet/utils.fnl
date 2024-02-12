(import-macros {: deepcopy} :Juliet.deepcopy)

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

(fn merge [a b]
  (local fin (deepcopy a))
  (each [k v (pairs b)] (tset fin k v))
  fin)

{: nil? : str? : num? : bool? : fn? : tbl? : ->str : ->bool : merge}
