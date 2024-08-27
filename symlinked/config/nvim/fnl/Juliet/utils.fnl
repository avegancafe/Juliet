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

(local event-cache {:refresh_interval 30 :timestamp nil :value nil})

(fn current-cal-event []
  (let [now (_G.os.time)]
    (when (and event-cache.value
               (< (- now event-cache.timestamp) event-cache.refresh_interval))
      (let [___antifnl_rtn_1___ event-cache.value]
        (lua "return ___antifnl_rtn_1___")))
    (local script "set processExists to false
        tell application \"System Events\"
            set processList to name of every process
            if processList contains \"Notion Calendar\" then
                set processExists to true
            end if
        end tell
        if processExists then
          tell application \"System Events\"
            tell process \"Notion Calendar\"
              -- Get the second menu bar
              set theSecondMenuBar to menu bar 2
              -- Get all menu bar items in the second menu bar
              set menuBarItems to menu bar items of theSecondMenuBar
              -- Collect the titles or values of each menu bar item
              set menuBarItemTitles to {}
              repeat with itemIndex from 1 to count of menuBarItems
                set menuBarItemTitle to value of attribute \"AXTitle\" of item itemIndex of menuBarItems
                set end of menuBarItemTitles to menuBarItemTitle
              end repeat
            end tell
          end tell
          return menuBarItemTitles as string
        else
          return \"Open Notion Calendar to see upcoming events\"
        end if")
    (local handle (_G.io.popen (.. "osascript -e '" script "'")))
    (when (= handle nil)
      (set event-cache.value "Nothing's up")
      (set event-cache.timestamp now)
      (let [__fnl_ret_val event-cache.value]
        (lua "return __fnl_ret_val")))
    (local result (handle:read :*a))
    (handle:close)
    (set event-cache.value (result:gsub "^%s*(.-)%s*$" "%1"))
    (set event-cache.timestamp now)
    result))

{: nil? : str? : num? : bool? : fn? : tbl? : ->str : ->bool : merge : current-cal-event}
