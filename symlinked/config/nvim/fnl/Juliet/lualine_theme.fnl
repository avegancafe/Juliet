(local colors (require :bamboo.colors))
{:command {:a {:bg colors.yellow :fg colors.bg0 :gui :bold}
           :b {:bg colors.bg2 :fg colors.fg}
           :c {:bg colors.bg0 :fg colors.fg}
           :y {:bg colors.bg1 :fg colors.fg}
           :z {:bg colors.bg1 :fg colors.red}}
 :inactive {:a {:bg colors.bg0 :fg colors.fg :gui :bold}
            :b {:bg colors.bg2 :fg colors.fg}
            :c {:bg colors.bg0 :fg colors.fg}
            :y {:bg colors.bg1 :fg colors.fg}
            :z {:bg colors.bg1 :fg colors.red}}
 :insert {:a {:bg colors.blue :fg colors.bg0 :gui :bold}
          :b {:bg colors.bg1 :fg colors.fg}
          :c {:bg colors.bg0 :fg colors.fg}
          :y {:bg colors.bg1 :fg colors.fg}
          :z {:bg colors.bg1 :fg colors.red}}
 :normal {:a {:bg colors.green :fg colors.bg0 :gui :bold}
          :b {:bg colors.bg1 :fg colors.fg}
          :c {:bg colors.bg0 :fg colors.fg}
          :y {:bg colors.bg1 :fg colors.fg}
          :z {:bg colors.bg1 :fg colors.red}}
 :replace {:a {:bg colors.red :fg colors.bg0 :gui :bold}
           :b {:bg colors.bg1 :fg colors.fg}
           :c {:bg colors.bg0 :fg colors.fg}
           :y {:bg colors.bg1 :fg colors.fg}
           :z {:bg colors.bg1 :fg colors.red}}
 :visual {:a {:bg colors.yellow :fg colors.bg0 :gui :bold}
          :b {:bg colors.bg1 :fg colors.fg}
          :c {:bg colors.bg0 :fg colors.fg}
          :y {:bg colors.bg1 :fg colors.fg}
          :z {:bg colors.bg1 :fg colors.red}}}
