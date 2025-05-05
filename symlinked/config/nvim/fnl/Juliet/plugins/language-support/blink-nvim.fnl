(import-macros {: pack} :Juliet.macros)

(pack :Saghen/blink.cmp
      {:lazy false
       :version :1.*
       :opts {:sources {:default [:lsp :path :snippets]}
              :completion {:menu {:border :rounded
                                  :draw {:columns [{1 :rank
                                                    2 :kind_icon
                                                    :gap 2}
                                                   {:gap 1
                                                    1 :label
                                                    2 :label_description}]
                                         :components {:rank {:highlight :BlinkCmpSource
                                                             :text (fn [ctx]
                                                                     (if (= ctx.item.source_id
                                                                            :cmdline)
                                                                         ""
                                                                         (if (<= ctx.idx
                                                                                 9)
                                                                             (.. ""
                                                                                 ctx.idx)
                                                                             " ")))}}}}
                           :documentation {:auto_show true
                                           :window {:border :rounded}}}
              :keymap {:<CR> [:select_and_accept :fallback]
                       :<C-k> [:show :show_documentation :hide_documentation]
                       :<M-1> [(fn [cmp] (cmp.accept {:index 1}))]
                       :<M-2> [(fn [cmp] (cmp.accept {:index 2}))]
                       :<M-3> [(fn [cmp] (cmp.accept {:index 3}))]
                       :<M-4> [(fn [cmp] (cmp.accept {:index 4}))]
                       :<M-5> [(fn [cmp] (cmp.accept {:index 5}))]
                       :<M-6> [(fn [cmp] (cmp.accept {:index 6}))]
                       :<M-7> [(fn [cmp] (cmp.accept {:index 7}))]
                       :<M-8> [(fn [cmp] (cmp.accept {:index 8}))]
                       :<M-9> [(fn [cmp] (cmp.accept {:index 9}))]}
              :signature {:enabled true :window {:border :rounded}}}})
